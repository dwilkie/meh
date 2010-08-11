class SupplierOrder < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller_order

  belongs_to :product

  has_one    :payment

  before_validation :link_supplier

  validates :supplier,
            :product,
            :seller_order,
            :status,
            :quantity,
            :presence => true

  validates :product_id,
            :uniqueness => {:scope => :seller_order_id}

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

  private
    def link_supplier
      self.supplier = self.product.try(:supplier)
    end
end

