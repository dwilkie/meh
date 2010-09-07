class PaymentApplication < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  validates  :seller,
             :presence => true

  validates  :uri,
             :presence => true
             # add format here
end

