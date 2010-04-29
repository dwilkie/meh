class Supplier < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  has_one :mobile_number, :as => :phoneable
  #has_many :products, :dependent => :destroy

  validates_presence_of :mobile_number

  validates_uniqueness_of :email, :allow_blank => true
  validates_format_of     :email,
                          :with  => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i,
                          :allow_blank => true

  validates_presence_of     :password
  validates_confirmation_of :password
  validates_length_of       :password, :within => 6..20, :allow_blank => true
end

