class Order < ActiveRecord::Base
  belongs_to :supplier, :class_name => "User"
  belongs_to :seller, :class_name => "User"
  
  has_many   :supplier_orders, :foreign_key => "seller_order_id", :class_name => "Order"
  belongs_to :seller_order, :class_name => "Order"
  belongs_to :product

  has_one :paypal_ipn, :foreign_key => "customer_order_id"

  accepts_nested_attributes_for :supplier_orders

  state_machine :status, :initial => :unconfirmed do
    event :accept do
      transition :unconfirmed => :accepted
    end
    event :reject do
      transition :unconfirmed => :rejected
    end
  end
  
  def confirmed?
    !unconfirmed?
  end

end
