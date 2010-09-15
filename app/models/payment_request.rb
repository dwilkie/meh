class PaymentRequest < ActiveRecord::Base

  class AbstractRemotePaymentRequestJob < Struct.new(:payment_request_id)
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
      @response = self.class.post(payment_request.remote_uri) if
        attempt_job
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

  class VerifyPaymentRequestNotificationJob < AbstractRemotePaymentRequestJob
    def perform
      @response = self.class.head(payment_request.remote_uri) if attempt_job
    end

    def success(job)
      payment_request.verify_notification! if response && response.code == 200
    end
  end

  class NotifyPaymentRequestJob < Struct.new(:id, :params)
    attr_reader :attempt_job

    MAX_ATTEMPTS = 1

    def before(job)
      @attempt_job = job.attempts < MAX_ATTEMPTS
    end

    def perform
      payment_request = PaymentRequest.find_by_id(id)
      payment_request.notify!(params) if attempt_job && payment_request
    end
  end

  belongs_to :payment
  belongs_to :payment_application

  before_create :build_params
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

  def self.notify_later(id, params)
    Delayed::Job.enqueue(
      NotifyPaymentRequestJob.new(id, params)
    )
  end

  def notify!(notification)
    remote_id = notification.try(:delete, "id")
    if remote_id && !completed? && remote_application_received?
      self.update_attributes!(
        :remote_id => remote_id,
        :notification => notification,
        :notified_at => Time.now
      )
      Delayed::Job.enqueue(
        VerifyPaymentRequestNotificationJob.new(self.id)
      )
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
      :uri => payment_application.payment_requests_uri
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

  def remote_uri
    payment_application.payment_request_uri(
      :remote_id => remote_id,
      :params => {
        "payment_request" => params.merge({"id" => self.id})
      }
    )
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
      Delayed::Job.enqueue(
        CreateRemotePaymentRequestJob.new(self.id)
      )
    end

    def verified_payment_application
      errors.add(
        :payment_application,
        :unverified
      ) if payment_application && payment_application.unverified?
    end
end

