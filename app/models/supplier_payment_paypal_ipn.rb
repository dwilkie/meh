class SupplierPaymentPaypalIpn < PaypalIpn

  include Paypal::Ipn::Masspay

  has_one :supplier_payment, :as => :notification

  after_update  :link_payment

  validate :payment_exists

  def self.transaction_id(params)
    masspay_txn_id(params)
  end

  private
    def find_payment
      SupplierPayment.find_by_id(unique_id)
    end

    def payment_exists
      errors[:base] << "Payment must exist" unless
      params.nil? || find_payment
    end

    def link_payment
      self.supplier_payment = find_payment if
        verified_at_changed? && verified? &&
        verified_at_was.nil? && payment_completed?
    end
end

