class Product < ActiveRecord::Base

  composed_of :price, :class_name => "Money", :mapping => [%w(cents cents)]
  belongs_to :supplier

  validates_uniqueness_of :external_id, :allow_nil => true

end
