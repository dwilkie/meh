class PaypalIpn < ActiveRecord::Base
  include Paypal::Ipn

  class CreatePaypalIpnJob < Struct.new(:params)
    attr_reader :attempt_job

    MAX_ATTEMPTS = 1

    def before(job)
      @attempt_job = job.attempts < MAX_ATTEMPTS
    end

    def perform
      if attempt_job
        paypal_ipn_class = PaypalIpn.type(params)
        transaction_id = paypal_ipn_class.transaction_id(params)
        paypal_ipn = paypal_ipn_class.find_or_initialize_by_transaction_id(transaction_id)
        unless paypal_ipn.payment_completed?
          paypal_ipn.update_attributes(
            :params => params,
            :verified_at => nil,
            :fraudulent => nil
          )
        end
      end
    end
  end

  serialize  :params

  before_save :set_payment_status
  after_save  :verify_ipn_later

  validates :params,
            :presence => true

  validates :transaction_id,
            :presence => true,
            :uniqueness => true

  def self.create_later(params)
    Delayed::Job.enqueue(
      CreatePaypalIpnJob.new(params)
    )
  end

  def self.type(params)
    masspay_transaction?(params) ?
      SupplierPaymentPaypalIpn :
      SellerOrderPaypalIpn
  end

  def type
    self.becomes(self.class.type(params))
  end

  def verified?
    verified_at
  end

  def verify_ipn_later
    verify_ipn if !verified? && !fraudulent? && payment_completed?
  end

  def verify_ipn
    verify ?
      self.update_attributes!(:verified_at => Time.now) :
      self.update_attributes!(:fraudulent => true)
  end
  handle_asynchronously :verify_ipn

  private
    def set_payment_status
      self.payment_status = payment_status
    end
end

