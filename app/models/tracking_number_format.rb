class TrackingNumberFormat < ActiveRecord::Base
  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  belongs_to :supplier,
             :class_name => "User"

  validates  :format,
             :presence => true,
             :if => Proc.new { |t|
               t.required?
             }

  validates  :seller_id,
             :uniqueness => {
               :scope => [
                 :product_id,
                 :supplier_id
               ]
             },
             :presence => true

  validates  :required,
             :inclusion => {:in => [true, false]}

  before_validation(:on => :create) do
    self.format = "\\w+" if self.format.nil?
    self.required = true if self.required.nil?
  end

  def self.find_for(options = {})
    product_scope = where(:product_id => options[:product].id) if options[:product]
    supplier_scope = where(:supplier_id => options[:supplier].id) if options[:supplier]
    if product_scope && product_scope.count > 0
      product_scope
    elsif supplier_scope && supplier_scope.count > 0
      supplier_scope
    else
      scoped
    end
  end
end

