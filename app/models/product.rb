class Product < ActiveRecord::Base

  composed_of :price, :class_name => "Money", :mapping => [%w(cents cents)]
  belongs_to :supplier

  validates :cents, :presence => true, :numericality => {:greater_than => 0}
  validates :external_id, :uniqueness => true, :allow_nil => true
  validates :state, :inclusion => {:in => ["unverified", "active", "inactive"] }
end
