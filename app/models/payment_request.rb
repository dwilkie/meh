class PaymentRequest < ActiveRecord::Base
  class RemotePaymentRequest # Represents the payment request on the remote side

    class AbstractRemotePaymentRequestJob < Struct.new(
      :payment_request_id, :request_uri, :body
    )
      include HTTParty

      MAX_ATTEMPTS = 8

      attr_reader :attempt_job

      def before(job)
        @attempt_job = job.attempts < MAX_ATTEMPTS
      end

      def failure(job, exception)
        if job.attempts >= MAX_ATTEMPTS - 1
          payment_request.give_up!(exception, job.attempts)
        end
      end

      protected
        def payment_request
          PaymentRequest.find(payment_request_id)
        end
    end

    class CreateRemotePaymentRequestJob < AbstractRemotePaymentRequestJob
      def perform
        self.class.post(request_uri, :body => body) if attempt_job
      end

      def after(job)
        payment_request.mark_first_attempt_to_send_to_remote_application! if
          job.attempts == 0
      end
    end

    class VerifyRemotePaymentRequestJob < AbstractRemotePaymentRequestJob
      def perform
        if attempt_job
          self.class.head(request_uri).code == 200 ?
            payment_request.notification_verified! :
            payment_request.mark_as_fraudulent!
        end
      end
    end

    attr_accessor :payment_request
    attr_accessor :application_uri

    def initialize(payment_request)
      @payment_request = payment_request
      @application_uri = payment_request.remote_payment_application_uri
    end

    def create(params)
      request_uri = URI.join(application_uri, "payment_requests").to_s
      body = {"payment_request" => params}

      Delayed::Job.enqueue(
        CreateRemotePaymentRequestJob.new(payment_request.id, request_uri, body)
      )
    end

    def verify
      request_uri = URI.join(
        application_uri, "payment_requests/#{payment_request.remote_id}"
      )
      request_uri.query = payment_request.notification.to_query
      Delayed::Job.enqueue(
        VerifyRemotePaymentRequestJob.new(
          payment_request.id,
          request_uri.to_s
        )
      )
    end
  end

  attr_accessor :payment_application

  belongs_to :payment

  before_create :build_params, :set_remote_payment_application_uri
  after_create :request_remote_payment

  serialize   :params
  serialize   :notification

  validates :payment,
            :presence => true

  validates :payment_id,
            :uniqueness => true

  validates :payment_application,
            :presence => true,
            :on => :create

  validate :verified_payment_application, :on => :create

  def notify!(notification)
    remote_id = notification.try(:delete, "id")
    if remote_id
      self.update_attributes!(
        :remote_id => remote_id,
        :notification => notification,
        :notified_at => Time.now
      )
      RemotePaymentRequest.new(self).verify
    else
      mark_as_fraudulent!
    end
  end

  def give_up!(exception, number_of_attempts)
    self.update_attributes!(
      :failure_error => exception.message,
      :gave_up_at => Time.now
    )
  end

  def mark_first_attempt_to_send_to_remote_application!
    self.update_attributes!(
      :first_attempt_to_send_to_remote_application_at => Time.now
    )
  end

  def notification_verified!
    self.update_attributes!(:notification_verified_at => Time.now)
  end

  def successful?
    notification["payment_response"].try(:[], "paymentExecStatus") == "COMPLETED"
  end

  def error
    if payment_response = notification["payment_response"]
      payment_response["error(0).message"]
    elsif remote_application_error = notification["errors"]
      payment = self.payment
      I18n.t(
        "activerecord.errors.models.payment_request.attributes.notification." <<
        remote_application_error.keys.first.to_s,
        :supplier => payment.supplier.name,
        :currency => payment.currency,
        :application_uri => remote_payment_application_uri
      )
    end
  end

  def mark_as_fraudulent!
    self.update_attributes!(:fraudulent => true)
  end

  def authorized?(params)
    merged_params = params.merge(self.params)
    merged_params == params && !notified?
  end

  private
    def notified?
      !notified_at.nil?
    end

    def build_params
      receiver = payment.supplier.email
      amount = payment.amount.to_s
      currency = payment.currency.to_s
      self.params = {
        "payee" => {
          "email" => receiver,
          "amount" => amount,
          "currency" => currency
        },
        "payment" => {
          "senderEmail" => payment.seller.email,
          "receiverList.receiver(0).email" => receiver,
          "receiverList.receiver(0).amount" => amount,
          "currencyCode" => currency
        }
      }
    end

    def request_remote_payment
      request_params = self.params.merge({"id" => self.id})
      RemotePaymentRequest.new(self).create(request_params)
    end

    def verified_payment_application
      errors.add(
        :payment_application,
        :unverified
      ) if payment_application && payment_application.unverified?
    end

    def set_remote_payment_application_uri
      self.remote_payment_application_uri = payment_application.uri
    end
end

