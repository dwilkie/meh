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

end

