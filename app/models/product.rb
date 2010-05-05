class Product < ActiveRecord::Base

  composed_of :price, :class_name => "Money", :mapping => [%w(cents cents)]
  belongs_to :supplier, :class_name => "User"
  belongs_to :seller, :class_name => "User"

  validates :cents, :presence => true, :numericality => {:greater_than => 0}
  validates :external_id, :uniqueness => {:scope => :supplier_id}, :presence => true
  validates :external_id, :uniqueness => {:scope => :seller_id}
  validates :supplier_id, :presence => true
  validates :seller_id,   :presence => true
end
