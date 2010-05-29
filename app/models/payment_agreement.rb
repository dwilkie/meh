class PaymentAgreement < ActiveRecord::Base
  belongs_to :product
  
  belongs_to :supplier,
             :class_name => "User"
  
  belongs_to :seller,
             :class_name => "User"


  class IsNotTheSellerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :is_the_seller) if
      record.seller.== value
    end
  end
  
  class HasAnotherSupplierValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :supplied_by_seller) if
      value.seller.== value.supplier
    end
  end
  
  class IsNilValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :is_not_nil) unless
      value.nil?
    end
  end

  validates :product,
            :presence => true,
            :has_another_supplier => true,
            :allow_nil => true,
            :unless => Proc.new { |payment_agreement|
              payment_agreement.supplier ||
              payment_agreement.seller
            }
              
  validates :product,
            :is_nil => true,
            :if => Proc.new { |payment_agreement|
              payment_agreement.supplier ||
              payment_agreement.seller
            }
  
  validates :product_id,
            :uniqueness => true,
            :allow_nil => true
  
  validates :seller, :supplier,
            :presence => true,
            :unless => Proc.new { |payment_agreement|
              payment_agreement.product
            }

  validates :supplier_id,
            :uniqueness => {:scope => :seller_id},
            :allow_nil => true

  validates :supplier,
            :is_not_the_seller => true,
            :allow_nil => true

 end
