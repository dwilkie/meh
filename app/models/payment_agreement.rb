class PaymentAgreement < ActiveRecord::Base

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller,
             :class_name => "User"

  EVENTS = [
      "supplier_order_created",
      "supplier_order_confirmed",
      "supplier_order_completed"
    ]

  class IsNotTheSellerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :is_the_seller) if
      record.seller == value
    end
  end

  validates  :supplier_id,
             :uniqueness => { :scope => :seller_id },
             :presence => true

  validates :supplier,
            :is_not_the_seller => true,
            :allow_nil => true

  validates  :enabled,
             :inclusion => {:in => [true, false]}

  validates  :event,
             :inclusion => {:in => EVENTS},
             :allow_nil => true

  before_validation(:on => :create) do
    self.enabled = true if self.enabled.nil?
  end

  def self.for_event(event, supplier)
    where(:event => event, :supplier_id => supplier.id)
  end
end

