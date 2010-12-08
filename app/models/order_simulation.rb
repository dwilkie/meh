class OrderSimulation < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"


  has_one    :seller_order

  accepts_nested_attributes_for :seller

end

