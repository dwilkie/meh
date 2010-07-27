class AcceptorderConversation < AbstractProcessOrderConversation

  class Message < AbstractProcessOrderConversation::SupplierOrderMessage
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

    attr_reader :quantity, :product_verification_code

    validates :quantity,
              :presence => true,
              :matches_order_quantity => true

    validates :product_verification_code,
              :presence => true,
              :matches_product_verification_code => true

    def initialize(raw_message, supplier)
      message_contents = super
      @quantity = message_contents[3].try(:to_i)
      @product_verification_code = message_contents.last if
        message_contents.size >= 5
    end
  end

  def move_along(message)
    if user.is?(:supplier)
      message = Message.new(message, user)
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
    else
      say unauthorized
    end
  end
end

