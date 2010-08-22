class Product < ActiveRecord::Base

  composed_of :supplier_price,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)]

  belongs_to  :supplier,
              :class_name => "User"

  belongs_to  :seller,
              :class_name => "User"

  has_many    :supplier_orders,
              :class_name => "Order"

  has_many    :notifications

  has_one     :payment_agreement

  validates :cents,
            :presence => true,
            :numericality => {
              :only_integer => true,
              :greater_than_or_equal_to => 0
            }

  validates :number, :name, :verification_code,
            :uniqueness => {:scope => :seller_id},
            :presence => true

  validates :supplier_id,
            :presence => true

  validates :seller_id,
            :presence => true

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
end

