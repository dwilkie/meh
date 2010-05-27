class Product < ActiveRecord::Base

  composed_of :supplier_price,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)]

  belongs_to :supplier, :class_name => "User"
  belongs_to :seller, :class_name => "User"
  has_many   :supplier_orders, :class_name => "Order"

  validates :cents,
            :numericality => {:only_integer => true, :greater_than => 0},
            :allow_nil => true

  validates :currency,
            :presence => true,
            :unless => Proc.new { |product| product.cents.nil? }

  validates :external_id, :verification_code,
            :uniqueness => {:scope => :seller_id},
            :presence => true
            
  validates :supplier_id,
            :presence => true
            
  validates :seller_id,
            :presence => true
end
