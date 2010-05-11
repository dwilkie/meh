class Order < ActiveRecord::Base
  belongs_to :supplier, :class_name => "User"
  belongs_to :seller, :class_name => "User"
  
  has_many   :supplier_orders, :foreign_key => "seller_order_id", :class_name => "Order"
  belongs_to :seller_order, :class_name => "Order"

  has_one :line_item,  :foreign_key => "supplier_order_id"
  has_one :paypal_ipn, :foreign_key => "customer_order_id"

  accepts_nested_attributes_for :supplier_orders
  accepts_nested_attributes_for :line_item

  state_machine :status, :initial => :unconfirmed do
  end

end
