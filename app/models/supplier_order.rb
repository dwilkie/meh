class SupplierOrder < ActiveRecord::Base

  belongs_to :seller_order

  belongs_to :supplier,
             :class_name => "User"

  has_many   :line_items

  has_one    :payment

  validates :seller_order,
            :supplier,
            :presence => true

  validates :supplier_id,
            :uniqueness => {:scope => :seller_order_id}

  validates :tracking_number,
            :uniqueness => {:scope => :supplier_id, :case_sensitive => false},
            :allow_nil => true

  def self.find_or_create_for!(supplier)
    record = where(:supplier_id => supplier.id).first
    record = scoped.create!(:supplier => supplier) unless record
    record
  end
end

