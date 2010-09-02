class TrackingNumberFormat < ActiveRecord::Base
  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  belongs_to :supplier,
             :class_name => "User"

  validates  :seller, :format,
             :presence => true

  def self.find_for(options = {})
    scope = where(:product_id => options[product].id) if options[:product]
    if scope && scope.count > 0

    end
  end
end

