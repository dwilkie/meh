class AcceptorderConversation < AbstractConversation

  # A valid text message should be formatted as follows:
  # acceptorder <order_id> <quantity> <pv code>
  # e.g. "acceptorder 6788965 4 243553"
  class Message
    include ActiveModel::Validations
    
    class MatchesOrderQuantityValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, :not_matching_order_quantity) unless
        value.nil? || record.order.nil? || record.order.quantity == value
      end
    end
    
    class MatchesProductVerificationCodeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, :not_matching_product_verification_code) unless
        value.nil? || record.order.nil? || 
        record.order.product.verification_code == value
      end
    end
    
    attr_reader   :order_number, :order, :quantity,
                  :product_verification_code, :raw_message
                  
    validates :quantity,
              :presence => true,
              :matches_order_quantity => true
              
    validates :order,
              :presence => true

    validates :product_verification_code,
              :presence => true,
              :matches_product_verification_code => true
    
    def initialize(raw_message, supplier)
      @raw_message = raw_message
      message_contents = raw_message.split(" ")
      @order_number = message_contents[1].try(:to_i)
      @order = supplier.supplier_orders.where(
        :id => @order_number,
        :status => "unconfirmed"
      ).first
      @quantity = message_contents[2].try(:to_i)
      @product_verification_code = message_contents[3]
    end
  end
    
  def move_along!(message)
    if user.is?(:supplier)
      message = Message.new(message, user)
      if message.valid?
        message.order.confirm
      end
    end
    finish
  end
end
