class AcceptorderConversation < AbstractProcessOrderConversation

  # A valid text message should be formatted as follows:
  # acceptorder <order_id> <quantity> x <pv code>
  # Examples of valid messages:
  # "acceptorder 6788965 4 x 243553"
  # "acceptorder 135 4 haye532"
  # "acceptorder 3456 1x 34223hdx"

  # Examples of invalid messages:
  # "acceptorder x2345 4 x 2345677" # Order not found
  # "acceptorder 23445 0 x 3456766" # Quantity isn't 0
  # "acceptorder 21321 1 x"         # pv code isn't x
  # "acceptorder"                   # All errors
  # "acceptorder 21243"             # Quantity is blank, pv code can't be blank
  # "acceptorder 23324 1"           # pv code can't be blank

  class AcceptOrderMessage < AbstractProcessOrderConversation::OrderMessage
    class MatchesOrderQuantityValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        order = record.order
        record.errors.add(attribute, :not_matching_order_quantity) unless
        value.nil? || order.nil? || order.quantity == value
      end
    end
    
    class MatchesProductVerificationCodeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        order = record.order
        record.errors.add(
          attribute,
          :not_matching_product_verification_code
        ) unless
        value.nil? || order.nil? || 
        order.product.verification_code == value
      end
    end
    
    attr_reader   :quantity, :product_verification_code

    validates :quantity,
              :presence => true,
              :matches_order_quantity => true

    validates :product_verification_code,
              :presence => true,
              :matches_product_verification_code => true
    
    def initialize(raw_message, supplier)
      message_contents = super
      @quantity = message_contents[2].try(:to_i)
      @product_verification_code = message_contents.last if
        message_contents.size >= 4
    end
  end
  
  def move_along!(message)
    message = AcceptOrderMessage.new(message, user)
    super(message)
    unless finished?
      processed = "accepted"
      if message.valid?
        order = message.order
        if order.unconfirmed?
          order.accept
        else 
          say cannot_process(order)
        end
      else
        say invalid(message, processed)
      end
    end
  end
end
