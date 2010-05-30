class PaymentApplication < ActiveRecord::Base
  
  belongs_to :seller,
             :class_name => "User"
  
  validates  :seller,
             :presence => true
             
  validates  :status,
             :presence => true
  
  validates  :uri,
             :presence => true
             # add format here

  state_machine :status, :initial => :unconfirmed do
    event :confirm do
      transition :unconfirmed => :active
    end
    event :unconfirm do
      transition [:inactive, :active] => :unconfirmed
    end
    event :activate do
      transition :inactive => :active
    end
    event :deactivate do
      transition :active => :inactive
    end
  end
end
