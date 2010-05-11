class LineItem < ActiveRecord::Base
  belongs_to :supplier_order, :class_name => "Order"
  belongs_to :product
end
