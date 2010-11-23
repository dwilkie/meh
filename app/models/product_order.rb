class ProductOrder < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller_order

  belongs_to :product

  has_one    :payment

  before_validation :link_supplier

  scope :unconfirmed, where(
    :accepted_at => nil,
    :completed_at => nil
  )

  scope :incomplete, where(:completed_at => nil)

  validates :supplier,
            :product,
            :seller_order,
            :quantity,
            :presence => true

  validates :product_id,
            :uniqueness => {:scope => :seller_order_id}

  validates :tracking_number,
            :uniqueness => {:scope => :supplier_id, :case_sensitive => false},
            :allow_nil => true

  def supplier_total
    product.supplier_price * quantity
  end

  def accepted?
    self.accepted_at
  end

  def completed?
    self.completed_at
  end

  def incomplete?
    !completed?
  end

  def unconfirmed?
    self.accepted_at.nil? && self.completed_at.nil?
  end

  def accept!
    self.update_attributes!(:accepted_at => Time.now)
  end

  def complete!
    self.update_attributes!(:completed_at => Time.now)
  end

  def status
    if !self.completed_at.nil?
      "completed"
    elsif !self.accepted_at.nil?
      "accepted"
    else
      "unconfirmed"
    end
  end

  private
    def link_supplier
      self.supplier = self.product.try(:supplier)
    end
end

