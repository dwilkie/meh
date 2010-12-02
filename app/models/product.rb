class Product < ActiveRecord::Base

  composed_of :supplier_payment_amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)],
              :constructor => Proc.new { |cents, currency|
                Money.new(cents || 0, currency || Money.default_currency)
              }

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller,
             :class_name => "User"

  has_many   :line_items

  has_many   :notifications

  has_one    :payment_agreement

  validates :supplier_payment_amount,
            :presence => true,
            :numericality => {:greater_than_or_equal_to => 0}

  validates :number, :name,
            :uniqueness => {:scope => :seller_id, :case_sensitive => false},
            :presence => true

  validates :supplier_id,
            :presence => true

  validates :seller_id,
            :presence => true

  attr_accessible :supplier_payment_amount, :number, :name

  def self.with_number_and_name(number, name)
    where(
      "products.number = ?",
      number
    ).where(
      "products.name = ?",
      name
    )
  end

  def self.with_number_or_name(number, name)
    where(
      "products.number = ? OR products.name = ?",
      number, name
    )
  end

  def supplier_payment_amount=(value)
    self.cents = Money.parse(value).cents
  end
end

