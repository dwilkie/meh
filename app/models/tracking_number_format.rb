class TrackingNumberFormat < ActiveRecord::Base
  belongs_to :seller,
             :class_name => "User"

  belongs_to :supplier,
             :class_name => "User"

  validates  :format,
             :presence => true,
             :if => Proc.new { |t|
               t.required?
             }

  validates  :seller_id,
             :uniqueness => {:scope => :supplier_id},
             :presence => true

  validates  :required,
             :inclusion => {:in => [true, false]}

  before_validation(:on => :create) do
    self.format = "\\w+" if self.format.nil?
    self.required = true if self.required.nil?
  end

  def self.find_for(options = {})
    scope = where(
      :supplier_id => options[:supplier].id
    ) if options[:supplier]
    (scope && scope.count > 0) ? scope : scoped.where(:supplier_id => nil)
  end
end

