class PaymentRequest < ActiveRecord::Base
  class RemotePaymentRequest # Represents the payment request on the remote side
    include HTTParty

    attr_accessor :application_uri

    def initialize(application_uri)
      @application_uri = application_uri
    end

    def create(params)
      request_uri = URI.join(application_uri, "payment_requests").to_s
      self.class.post(request_uri, :body => params)
    end
    handle_asynchronously :create
  end

  after_create :request_remote_payment
  before_create :build_params
  belongs_to :payment

  serialize   :params

  validates :application_uri,
            :presence => true
            #:format => # add format here

  validates :payment,
            :presence => true

  validates :payment_id,
            :uniqueness => true

  def response=(response)
    response
  end

  def authorized?(params)
    merged_params = params.merge(self.params)
    merged_params == params && !answered?
  end

  private
    def answered?
      !answered_at.nil?
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
      request_params = self.params.merge({:external_id => self.id})
      RemotePaymentRequest.new(application_uri).create(request_params)
    end
end

