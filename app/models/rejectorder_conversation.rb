class RejectorderConversation < AbstractConfirmOrderConversation

  @@options = {
    :invalid_message_i18n_key => "messages.reject_order_invalid_message"
  }

  class RejectOrderMessage < AbstractConfirmOrderConversation::AbstractMessage
    attr_reader   :confirmation
    
    validates :confirmation,
              :format => /^confirm\!$/i,
              :allow_nil => true
    
    def initialize(raw_message, supplier)
      message_contents = super
      @confirmation = message_contents[2]
    end
    
    def confirmed?
      !confirmation.nil?
    end
  end

  def move_along!(message)
    message = RejectOrderMessage.new(message, user)
    super(message, @@options)
    unless finished?
      if message.confirmed?
        message.order.reject
        say successfully_rejected_order(message)
      else
        say reject_order_confirmation(message)
      end
    end
  end
  
  private
    def reject_order_confirmation(message)
      seller = message.order.product.seller
      if seller == user
        I18n.t(
          "messages.reject_order_for_own_product_confirmation",
          :supplier => user.name,
          :order_number => message.order.id
        )
      else
        I18n.t(
          "messages.reject_order_for_sellers_product_confirmation",
          :supplier => user.name,
          :seller => seller.name,
          :order_number => message.order.id
        )
      end
    end
    def successfully_rejected_order(message)
      I18n.t(
        "messages.successfully_rejected_order",
        :supplier => user.name,
        :order_number => message.order.id
      )
    end
end
