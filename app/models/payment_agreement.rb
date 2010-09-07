class PaymentAgreement < ActiveRecord::Base
  belongs_to :product

  belongs_to :supplier,
             :class_name => "User"

  belongs_to :seller,
             :class_name => "User"

  EVENTS = [
      "product_order_created",
      "product_order_accepted",
      "product_order_completed"
    ]

  class IsNotTheSellerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :is_the_seller) if
      record.seller.== value
    end
  end

  validates  :seller_id,
             :presence => true

  validates  :supplier_id,
             :uniqueness => {
               :scope => [
                 :product_id,
                 :seller_id
               ]
             },
             :presence => true

  validates :product_id,
            :uniqueness => true,
            :allow_nil => true

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

  before_validation :link_seller_and_supplier

  def self.for_event(seller, product)
    scope = where(:seller_id => seller.id)
    product_scope = scope.where(:product_id => product.id)
    product_scope.count > 0 ? product_scope : scope
  end

  private
    def link_seller_and_supplier
      if product
        self.seller = product.supplier
        self.supplier = product.supplier
      end
    end
end

