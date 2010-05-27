class Order < ActiveRecord::Base
  
  # Seller Order Associations

  belongs_to :seller,
             :class_name => "User"

  has_many   :supplier_orders,
             :foreign_key => "seller_order_id",
             :class_name => "Order"

  has_one    :paypal_ipn,
             :foreign_key => "customer_order_id"

  # Supplier Order Associations
  belongs_to :supplier,
             :class_name => "User"
  
  belongs_to :seller_order,
             :class_name => "Order"
             
  belongs_to :product
  
  has_one    :payment,
             :foreign_key => "supplier_order_id"

  accepts_nested_attributes_for :supplier_orders

  state_machine :status, :initial => :unconfirmed do
    event :accept do
      transition :unconfirmed => :accepted
    end
    event :reject do
      transition :unconfirmed => :rejected
    end
    event :complete do
      transition :accepted => :completed
    end
  end
  
  def supplier_total
    product.supplier_price * quantity
  end
end
