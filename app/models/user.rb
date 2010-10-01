class User < ActiveRecord::Base

  ROLES = %w[seller supplier]

  scope :with_role, lambda { |role|
    where("roles_mask & #{2**ROLES.index(role.to_s)} > 0 ")
  }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  # this is a white list of attributes that are permitted to be mass assigned
  # all others have to be assigned using writer methods
  attr_accessible :email, :password, :password_confirmation

  # General Associations

  has_one    :active_mobile_number,
             :foreign_key => "active",
             :class_name => "MobileNumber"

  has_many   :mobile_numbers

  # Seller Associations

  # seller has many products for sale
  # this adds user.selling_products
  has_many   :selling_products,
             :foreign_key => "seller_id",
             :class_name => "Product"

  # a seller is supplied by many suppliers
  # this adds user.suppliers
  has_many   :suppliers,
             :through => :selling_products,
             :uniq => true,
             :readonly => false

  has_many   :seller_orders,
             :foreign_key => "seller_id"

  has_many   :notifications,
             :foreign_key => "seller_id"

  has_many   :tracking_number_formats,
             :foreign_key => "seller_id"

  has_many   :outgoing_supplier_payments,
             :foreign_key => "seller_id",
             :class_name => "SupplierPayment"

  has_many   :outgoing_text_messages_paid_for,
             :foreign_key => "payer_id",
             :class_name => "OutgoingTextMessage"

  # this sets up seller.payment_agreements_with_suppliers
  # the foreign key should be seller_id because its on the seller's side
  # of the association
  has_many   :payment_agreements_with_suppliers,
             :foreign_key => "seller_id",
             :class_name => "PaymentAgreement"

  # and this sets up seller.suppliers_with_payment_agreements
  has_many   :suppliers_with_payment_agreements,
             :through => :payment_agreements_with_suppliers

  # Supplier Associations

  # a supplier has many products to supply
  # this adds user.supplying_products
  has_many   :supplying_products,
             :foreign_key => "supplier_id",
             :class_name => "Product"

  # a supplier supplies many sellers
  # this adds user.sellers
  has_many   :sellers,
             :through => :supplying_products,
             :uniq => true,
             :readonly => false

  has_many   :supplier_orders,
             :foreign_key => "supplier_id"

  has_many   :incoming_payments,
             :foreign_key => "supplier_id",
             :class_name => "SupplierPayment"

  # this sets up supplier.payment_agreements_with_sellers
  # the foreign key should be supplier_id because its on the supplier's side
  # of the association
  has_many   :payment_agreements_with_sellers,
             :foreign_key => "supplier_id",
             :class_name => "PaymentAgreement"

  # and this sets up supplier.sellers_with_payment_agreements
  has_many   :sellers_with_payment_agreements,
             :through => :payment_agreements_with_sellers

  validates :name, :presence => true

  validates :password_confirmation,
            :presence => true,
            :if => :password_required?

  def can_text?
    active_mobile_number = self.active_mobile_number
    active_mobile_number && active_mobile_number.verified?
  end

  def cannot_text?
    !can_text?
  end

  def add_message_credits(credits)
    self.message_credits += credits
    self.save
  end

  def deduct_message_credits(credits)
    self.message_credits -= credits
    self.save
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def new_role=(role)
    self.roles = roles << role.to_s
  end

  def roles
    self.class.roles(roles_mask)
  end

  def is?(role)
    roles.include?(role.to_s)
  end

  def self.roles(roles_mask)
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  private
    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end

