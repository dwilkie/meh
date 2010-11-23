class SupplierOrder < ActiveRecord::Base

  belongs_to :seller_order

  belongs_to :supplier,
             :class_name => "User"

  has_many   :product_orders

  validates :seller_order,
            :supplier,
            :presence => true

  validates :supplier_id,
            :uniqueness => {:scope => :seller_order_id}

  def self.find_or_create_for!(supplier)
    record = where(:supplier_id => supplier_id)
    scoped.create!(:supplier => supplier) unless record
    record
  end
end

