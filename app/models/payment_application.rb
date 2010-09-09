class PaymentApplication < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  validates  :seller,
             :presence => true

  validates  :uri,
             :presence => true
             # add format here

  def verified?
    !unverified?
  end

  def unverified?
    verified_at.nil?
  end

end

