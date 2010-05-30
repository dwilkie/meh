class PaymentRequest < ActiveRecord::Base
  class RemotePaymentRequest # Represents the payment request on the remote side
    include HTTParty

    attr_accessor :application_uri

    def initialize(application_uri)
      @application_uri = application_uri
    end

    def create!(params)
      request_uri = URI.join(application_uri, "payment_requests/create").to_s
      response = self.class.post(request_uri, params)
    end
  end
  
  after_create :request_payment
  belongs_to :payment
  
  validates :application_uri,
            :presence => true
            #:format => # add format here
            
  validates :payment,
            :presence => true
            
  validates :status,
            :presence => true

  state_machine :status, :initial => :new do
  end

  private
    def request_payment
      RemotePaymentRequest.new(application_uri).create!(
        :to => payment.supplier.email,
        :amount => payment.amount.to_s,
        :currency => payment.amount.currency
      )
    end
end
