class Payment < ActiveRecord::Base

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

  has_one     :payment_request

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


end

