class User < ActiveRecord::Base

  ROLES = %w[seller supplier]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  has_one    :mobile_number, :as => :phoneable, :dependent => :destroy
  has_many   :products, :dependent => :destroy
  has_many   :suppliers, :class_name => "User", :foreign_key => "seller_id"
  belongs_to :seller, :class_name => "User"

  validates :email, :uniqueness => true,
            :format => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i,
            :allow_nil => true

  validates_presence_of :email,
                        :if => Proc.new {
                                 |user| user.is?(:seller) || user.mobile_number.nil?
                               }

  validates :password, :presence => true,
            :confirmation => true,
            :length => {:within => 6..20}

  validates :mobile_number, :presence => true,
            :if => Proc.new { |user| user.email.nil? }

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end
end

