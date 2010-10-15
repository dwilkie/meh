class PaypalIpn < ActiveRecord::Base
  include Paypal::Ipn

  class CreatePaypalIpnJob < Struct.new(:params)
    attr_reader :attempt_job

    MAX_ATTEMPTS = 1

    def before(job)
      @attempt_job = job.attempts < MAX_ATTEMPTS
    end

    def perform
      logfile = File.new("#{Rails.root}/log/worker.log", 'w')
      logfile.puts "attempt_job: #{attempt_job.to_s}"
      if attempt_job
        paypal_ipn_class = PaypalIpn.type(params)
        logfile.puts "paypal_ipn_class: #{paypal_ipn_class.to_s}"
        new_paypal_ipn = paypal_ipn_class.new(:params => params)
        paypal_ipn = paypal_ipn_class.find_or_initialize_by_transaction_id(
          new_paypal_ipn.transaction_id
        )
        logfile.puts "paypal_ipn: #{paypal_ipn.inspect}"
        logfile.puts "passing_check: #{(paypal_ipn.payment_completed? || new_paypal_ipn.payment_status == paypal_ipn.payment_status) && paypal_ipn.verified?}"
        unless (paypal_ipn.payment_completed? ||
        new_paypal_ipn.payment_status == paypal_ipn.payment_status) &&
        paypal_ipn.verified?
          paypal_ipn.update_attributes(
            :params => params,
            :verified_at => nil,
            :fraudulent => nil
          )
          logfile.puts "paypal_ipn_after_save: #{paypal_ipn.inspect}"
        end
      end
      logfile.close
    end
  end

  serialize  :params

  before_save :set_payment_status
  after_save  :verify_ipn_later
  before_validation :set_transaction_id

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
    verify_ipn if !verified? && !fraudulent?
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

    def set_transaction_id
      self.transaction_id = transaction_id
    end
end

