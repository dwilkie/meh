class User < ActiveRecord::Base

  ROLES = %w[seller supplier]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :paypal_authable,
         :paypal_authentication_class => "PaypalAuthentication"

  # General Associations

  belongs_to :active_mobile_number,
             :class_name => "MobileNumber"

  has_many   :mobile_numbers

  accepts_nested_attributes_for :mobile_numbers

  # Seller Associations

  # seller has many products for sale
  # this adds user.selling_products

  has_many   :order_simulations,
             :foreign_key => "seller_id"

  has_many   :supplier_partnerships,
             :foreign_key => "seller_id",
             :class_name => "Partnership"

  has_many   :suppliers,
             :through => :supplier_partnerships,
             :uniq => true,
             :readonly => false

  has_many   :selling_products,
             :foreign_key => "seller_id",
             :class_name => "Product"

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

  has_many   :seller_partnerships,
             :foreign_key => "supplier_id",
             :class_name => "Partnership"

  has_many   :sellers,
             :through => :seller_partnerships,
             :uniq => true,
             :readonly => false

  has_many   :supplier_orders,
             :foreign_key => "supplier_id"

  has_many   :line_items,
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

  validates :email,
            :presence => true,
            :if => :email_required?

  validates :active_mobile_number_id,
            :uniqueness => true,
            :allow_nil => true

  validate  :has_at_least_one_mobile_number

  attr_accessible :email, :name, :mobile_numbers_attributes

  def self.with_mobile(number)
    joins(:mobile_numbers) & MobileNumber.with_number(number)
  end

  def self.with_role(role)
    where("roles_mask & #{2**ROLES.index(role.to_s)} > 0 ")
  end

  def self.roles(roles_mask)
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def self.find_for_paypal_auth(paypal_user_params, request_params)
    if paypal_user_params
      user = self.find_or_initialize_by_email(paypal_user_params[:email])
      if user.new_record?
        user.attributes = request_params[:user]
        user.name = paypal_user_params[:first_name].capitalize
        stub_password(user)
      end
    else
      user = self.new
    end
    user.new_role = :seller
    user.save
    user
  end

  def self.stub_password(user)
    stubbed_password = Devise.friendly_token[0..password_length.max-1]
    user.password = stubbed_password
    user.password_confirmation = stubbed_password
  end

  def can_text?
    active_mobile_number = self.active_mobile_number
    active_mobile_number && active_mobile_number.verified?
  end

  def human_active_mobile_number
    active_mobile_number ? active_mobile_number.humanize : ""
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

  def supplier_partnership_with(supplier)
    supplier_partnerships.where(:supplier_id => supplier).first
  end

  def stub_password
    self.class.stub_password(self)
  end

  private

  def email_required?
    self.is?(:seller)
  end

  def has_at_least_one_mobile_number
    errors.add(
      :mobile_numbers,
      :blank
    ) if mobile_numbers.empty?
  end

end

