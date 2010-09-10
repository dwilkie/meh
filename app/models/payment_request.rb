class PaymentRequest < ActiveRecord::Base
  class RemotePaymentRequest # Represents the payment request on the remote side
    include HTTParty

    attr_accessor :application_uri

    def initialize(application_uri)
      @application_uri = application_uri
    end

    def create(params)
      request_uri = URI.join(application_uri, "payment_requests").to_s
      self.class.post(request_uri, :body => {"payment_request" => params})
    end
    handle_asynchronously :create

    def verify(payment_request)
      request_uri = URI.join(
        application_uri, "payment_requests/#{payment_request.remote_id}"
      )
      request_uri.query = payment_request.notification.to_query
      if self.class.head(request_uri.to_s).code == 200
        payment_request.update_attribute(:notification_verified_at, Time.now)
      else
        payment_request.mark_as_fraudulent
      end
    end
    handle_asynchronously :verify
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
      RemotePaymentRequest.new(
        remote_payment_application_uri
      ).verify(self)
    else
      self.mark_as_fraudulent
    end
  end

  def successful?
    self.notification["payment_response"].try(:[], "paymentExecStatus") == "COMPLETED"
  end

  def error
    if payment_response = self.notification["payment_response"]
      payment_response["error(0).message"]
    elsif remote_application_error = self.notification["errors"]
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

  def mark_as_fraudulent
    self.update_attribute(:fraudulent, true)
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
      RemotePaymentRequest.new(
        remote_payment_application_uri
      ).create(request_params)
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

