class SupplierPayment < ActiveRecord::Base

  include Paypal::Masspay

  serialize :payment_response

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

  def notification_with_type
    notification = notification_without_type
    notification.respond_to?(:type) ?
      notification.type :
      notification
  end

  alias_method_chain :notification, :type

  def payment_error
    I18n.t(
      "activerecord.errors.models.supplier_payment.payment.#{payment_error_type.to_s}",
      :seller_email => seller.email,
      :currency => amount.currency.to_s,
      :error => payment_error_message
    )
  end

  def completed?
    notification.payment_completed?
  end

  def successful?
    successful_payment?
  end

  def unclaimed?
    notification.payment_unclaimed?
  end

  after_create :pay

  private
    def pay
      payment_response = masspay(
        seller.email,
        supplier.email,
        amount.to_s,
        amount.currency.to_s,
        I18n.t(
          "supplier_payment_note",
          :supplier_order_number => supplier_order.id.to_s
        ),
        self.id.to_s
      )
      self.update_attributes!(
        :payment_response => Rack::Utils.parse_nested_query(payment_response)
      )
    end
    handle_asynchronously :pay
end

