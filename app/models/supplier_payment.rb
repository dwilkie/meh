class SupplierPayment < ActiveRecord::Base

  include Paypal::Masspay

  composed_of :amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |cents, currency|
                Money.new(cents || 0, currency || Money.default_currency)
              }

  belongs_to  :supplier,
              :class_name => "User"

  belongs_to  :seller,
              :class_name => "User"

  belongs_to  :supplier_order

  belongs_to  :notification, :polymorphic => true

  validates :amount,
            :presence => true,
            :numericality => {:greater_than => 0}

  validates :supplier_order,
            :presence => true

  validates :supplier_order_id,
            :uniqueness => true

  validates :seller,
            :presence => true

  validates :supplier,
            :presence => true

  after_create :pay

  private
    def pay
      payment_response = masspay(
        seller.email,
        supplier.email,
        amount.to_s,
        amount.currency.to_s,
        I18n.t(
          "activerecord.payment.note",
          :supplier_order_number => supplier_order.id.to_s
        ),
        self.id.to_s
      )
      self.update_attributes!(:payment_response => payment_response)
    end
    handle_asynchronously :pay
end

