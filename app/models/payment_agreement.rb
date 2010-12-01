class PaymentAgreement < ActiveRecord::Base

  composed_of :fixed_amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |cents, currency|
                Money.new(cents || 0, currency || Money.default_currency)
              }

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller,
             :class_name => "User"

  EVENTS = [
      "supplier_order_confirmed",
      "supplier_order_completed"
    ]

  class IsNotTheSellerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :is_the_seller) if
      record.seller == value
    end
  end

  validates :supplier_id,
            :uniqueness => { :scope => :seller_id },
            :presence => true

  validates :supplier,
            :is_not_the_seller => true,
            :allow_nil => true

  validates :fixed_amount,
            :presence => true,
            :numericality => {:greater_than_or_equal_to => 0}

  validates :enabled,
            :inclusion => {:in => [true, false]}

  validates :event,
            :inclusion => {:in => EVENTS},
            :allow_nil => true

  attr_accessible :fixed_amount, :currency

  before_validation(:on => :create) do
    self.enabled = true if self.enabled.nil?
  end

  def fixed_amount=(value)
    self.cents = Money.parse(value).cents
  end

  def payment_amount(external_amount = nil)
    if external_amount.nil? || fixed_amount.nonzero?
      fixed_amount
    else
      Money.add_rate(external_amount.currency, fixed_amount.currency, 1)
      external_amount.exchange_to(fixed_amount.currency)
    end
  end

  def self.for_event(event, supplier)
    where(:event => event, :supplier_id => supplier.id)
  end
end

