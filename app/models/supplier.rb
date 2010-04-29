class Supplier < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  has_one :mobile_number, :as => :phoneable
  #has_many :products, :dependent => :destroy

#  validates_presence_of :mobile_number
end

