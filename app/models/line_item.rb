class LineItem < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :supplier_order

  belongs_to :product

  before_validation :link_supplier

  scope :unconfirmed, where(:confirmed_at => nil)

  validates :supplier,
            :product,
            :supplier_order,
            :quantity,
            :presence => true

  validates :product_id,
            :uniqueness => {:scope => :supplier_order_id}

  def supplier_subtotal
    product.supplier_price * quantity
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

