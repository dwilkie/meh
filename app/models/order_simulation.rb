class OrderSimulation < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  has_many    :suppliers

  accepts_nested_attributes_for :suppliers

end

