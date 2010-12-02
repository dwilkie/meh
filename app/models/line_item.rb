class LineItem < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :supplier_order

  belongs_to :seller_order

  belongs_to :product

  before_validation :link_supplier

  scope :unconfirmed, where(:confirmed_at => nil)

  validates :supplier,
            :product,
            :seller_order,
            :supplier_order,
            :quantity,
            :seller_order_index,
            :supplier_order_index,
            :presence => true

  validates :product_id,
            :uniqueness => {:scope => :seller_order_id}

  validates :product_id,
            :uniqueness => {:scope => :supplier_order_id}

  validates :seller_order_index,
            :uniqueness => {:scope => :seller_order_id}

  validates :supplier_order_index,
            :uniqueness => {:scope => :supplier_order_id}

  def supplier_payment_amount
    product.supplier_payment_amount * quantity
  end

  def confirmed?
    !unconfirmed?
  end

  def unconfirmed?
    self.confirmed_at.nil?
  end

  def confirm!
    self.update_attributes!(:confirmed_at => Time.now)
  end

  def status
    self.confirmed_at.nil? ? "unconfirmed" : "confirmed"
  end

  private
    def link_supplier
      self.supplier = self.product.try(:supplier)
    end
end

