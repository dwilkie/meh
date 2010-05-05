class Supplier < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  has_one :mobile_number, :as => :phoneable
  #has_many :products, :dependent => :destroy

  validates :mobile_number, :presence => true
  
  validates :email, :uniqueness => true,
                    :format => { :with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i },
                    :allow_blank => true

  validates :password, :presence => true, :confirmation => true,
                       :length => {:within => 6..20},
                       :allow_blank => true

end

