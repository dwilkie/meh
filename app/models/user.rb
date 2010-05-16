class User < ActiveRecord::Base

  ROLES = %w[seller supplier]

  scope :with_role, lambda { |role| where("roles_mask & #{2**ROLES.index(role.to_s)} > 0 ") }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  has_one    :mobile_number, :as => :phoneable, :dependent => :destroy
  
  # seller has many products for sale
  # this adds user.selling_products
  has_many   :selling_products, :foreign_key => "seller_id", :class_name => "Product"
  # a seller is supplied by many suppliers
  # this adds user.suppliers
  has_many   :suppliers, :through => :selling_products
  # a supplier has many products to supply
  # this adds user.supplying_products
  has_many   :supplying_products, :foreign_key => "supplier_id", :class_name => "Product"
  # a supplier supplies many sellers
  # this adds user.sellers
  has_many   :sellers, :through => :supplying_products
  
  has_many   :customer_orders, :foreign_key => "seller_id", :class_name => "Order"
  has_many   :supplier_orders, :foreign_key => "supplier_id", :class_name => "Order"

  has_many   :conversations, :foreign_key => "with"

  #preference :notification_method, :string, :default => 'email'

  validates :name, :presence => true

  #validate :check_notification_method_preference
  
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def new_role=(role)
    self.roles = self.roles << role.to_s
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end
  
  private
    def check_notification_method_preference
      errors.add(:preferred_notification_method, "customize") if email.nil? && preferred_notification_method == "email"
        errors.add(:preferred_notification_method, "customize") if mobile_number.nil? && preferred_notification_method == "mobile"
        errors.add(:preferred_notification_method, "customize") if (email.nil? || mobile_number.nil?) && preferred_notification_method == "both"
    end
end

