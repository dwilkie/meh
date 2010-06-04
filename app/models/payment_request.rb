class PaymentRequest < ActiveRecord::Base
  class RemotePaymentRequest # Represents the payment request on the remote side
    include HTTParty

    attr_accessor :application_uri

    def initialize(application_uri)
      @application_uri = application_uri
    end

    def create(params)
      request_uri = URI.join(application_uri, "payment_requests/create").to_s
      response = self.class.post(request_uri, :body => params)
    end
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
  
  validates :status,
            :presence => true

  state_machine :status, :initial => :requested do
    event :complete do
      transition :requested => :completed
    end
  end

  private
    def build_params
      self.params = {
        :to => payment.supplier.email,
        :amount => payment.amount.to_s,
        :currency => payment.amount.currency.to_s,
        :id => self.id.to_s
      }
    end
  
    def request_remote_payment
      RemotePaymentRequest.new(application_uri).create(self.params)
    end
end
