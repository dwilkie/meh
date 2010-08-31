class SupplierOrder < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller_order

  belongs_to :product

  has_one    :payment

  before_validation :link_supplier

  scope :unconfirmed, where(
    :accepted_at => nil,
    :rejected_at => nil,
    :completed_at => nil
  )

  private
    def self.not_completed
      where(:completed_at => nil)
    end

    def self.not_rejected
      where(:rejected_at => nil)
    end

  public

  scope :incomplete, not_completed.not_rejected

  validates :supplier,
            :product,
            :seller_order,
            :quantity,
            :presence => true

  validates :product_id,
            :uniqueness => {:scope => :seller_order_id}

  def supplier_total
    product.supplier_price * quantity
  end

  def complete?
    self.completed_at || self.rejected_at
  end

  def incomplete?
    !complete?
  end

  def unconfirmed?
    self.accepted_at.nil? && self.rejected_at.nil? && self.completed_at.nil?
  end

  def accept
    self.update_attributes!(:accepted_at => Time.now)
  end

  def status
    if !self.completed_at.nil?
      "completed"
    elsif !self.accepted_at.nil?
      "accepted"
    elsif !self.rejected_at.nil?
      "rejected"
    else
      "unconfirmed"
    end
  end

  private
    def link_supplier
      self.supplier = self.product.try(:supplier)
    end
end

