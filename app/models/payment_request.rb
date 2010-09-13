class PaymentRequest < ActiveRecord::Base
  class RemotePaymentRequest # Represents the payment request on the remote side

    class AbstractRemotePaymentRequestJob < Struct.new(
      :payment_request_id, :request_uri, :body
    )
      include HTTParty

      MAX_ATTEMPTS = 8

      attr_reader :attempt_job, :response

      def before(job)
        @attempt_job = job.attempts < MAX_ATTEMPTS
      end

      def failure(job, exception)
        if job.attempts >= MAX_ATTEMPTS - 1
          payment_request.give_up!(exception.message)
        end
      end

      protected
        def payment_request
          PaymentRequest.find(payment_request_id)
        end
    end

    class CreateRemotePaymentRequestJob < AbstractRemotePaymentRequestJob
      def perform
        @response = self.class.post(request_uri, :body => body) if attempt_job
      end

      def success(job)
        response.code == 200 ? payment_request.remote_application_received! :
          payment_request.give_up!(response.message) if response
      end

      def after(job)
        payment_request.first_attempt_to_send_to_remote_application! if
          job.attempts == 0
      end
    end

    class VerifyRemotePaymentRequestNotificationJob < AbstractRemotePaymentRequestJob
      def perform
        @response = self.class.head(request_uri) if attempt_job
      end

      def success(job)
        payment_request.verify_notification! if response && response.code == 200
      end
    end

    attr_accessor :payment_request
    attr_accessor :application_uri

    def initialize(payment_request)
      @payment_request = payment_request
      @application_uri = payment_request.remote_payment_application_uri
    end

    def payment_requests_uri(id = nil)
      path = "payment_requests"
      path << "/#{id.to_s}" if id
      URI.join(application_uri, path).to_s
    end

    def create(params)
      body = {"payment_request" => params}

      Delayed::Job.enqueue(
        CreateRemotePaymentRequestJob.new(
          payment_request.id, payment_requests_uri, body
        )
      )
    end

    def verify_notification
      request_uri = URI.parse(payment_requests_uri(payment_request.remote_id))
      request_uri.query = payment_request.notification.to_query
      Delayed::Job.enqueue(
        VerifyRemotePaymentRequestNotificationJob.new(
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
    if remote_id && !completed? && remote_application_received?
      self.update_attributes!(
        :remote_id => remote_id,
        :notification => notification,
        :notified_at => Time.now
      )
      RemotePaymentRequest.new(self).verify_notification
    end
  end

  def give_up!(reason)
    self.update_attributes!(
      :failure_error => reason,
      :gave_up_at => Time.now
    )
  end

  def seller_failure_error
    I18n.t(
      "activerecord.errors.models.payment_request.gave_up",
      :uri => RemotePaymentRequest.new(self).payment_requests_uri
    )
  end

  def given_up?
    !still_trying?
  end

  def still_trying?
    self.gave_up_at.nil?
  end

  def first_attempt_to_send_to_remote_application!
    self.update_attributes!(
      :first_attempt_to_send_to_remote_application_at => Time.now
    )
  end

  def remote_application_received!
    self.update_attributes!(
      :remote_application_received_at => Time.now
    )
  end

  def remote_application_received?
    !self.remote_application_received_at.nil?
  end

  def verify_notification!
    self.update_attributes!(:notification_verified_at => Time.now)
  end

  def successful_payment?
    notification.try(
      :[], "payment_response"
    ).try(:[], "paymentExecStatus") == "COMPLETED"
  end

  def notification_errors
    if payment_response = notification.try(:[], "payment_response")
      payment_response["error(0).message"]
    elsif remote_application_error = notification.try(:[], "errors")
      payment = self.payment
      supplier = payment.supplier
      I18n.t(
        "activerecord.errors.models.payment_request.attributes.notification." <<
        remote_application_error.keys.first.to_s,
        :supplier_name => supplier.name,
        :supplier_email => supplier.email,
        :currency => payment.currency,
        :uri => remote_payment_application_uri,
      )
    end
  end

  def authorized?(params)
    merged_params = params.merge(self.params)
    merged_params == params && remote_application_received?
  end

  def notification_verified?
    !self.notification_verified_at.nil?
  end

  private
    def notified?
      !notified_at.nil?
    end

    def completed?
      remote_application_received? && notification_verified?
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

