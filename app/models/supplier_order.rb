class SupplierOrder < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller_order

  belongs_to :product

  has_one    :payment,
             :foreign_key => "supplier_order_id"

  validates :supplier,
            :seller_order,
            :product,
            :status,
            :quantity,
            :presence => true

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

