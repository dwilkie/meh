class RejectorderConversation < AbstractConfirmOrderConversation

  @@options = {
    :invalid_message_i18n_key => "messages.reject_order_invalid_message"
  }

  class RejectOrderMessage < AbstractConfirmOrderConversation::AbstractMessage
    attr_reader   :confirmed
    
    validates :confirmed,
              :format => /^confirm\!$/i,
              :allow_nil => true
    
    def initialize(raw_message, supplier)
      message_contents = super
      @confirmed = message_contents[2]
    end
    
    def confirmed?
      !confirmed.nil?
    end
  end

  def move_along!(message)
    message = RejectOrderMessage.new(message, user)
    super(message, @@options)
    unless finished?
      message.confirmed? ? message.order.reject : say(reject_order_confirmation(message))
    end
  end
  
  private
    def reject_order_confirmation(message)
      seller =  message.order.product.seller
      if seller == user
        I18n.t(
          "messages.confirm_reject_order_for_own_product",
          :supplier => user.name,
          :order_number => message.order.id
        )
      else
        I18n.t(
          "messages.confirm_reject_order_for_sellers_product",
          :supplier => user.name,
          :seller => seller.name,
          :order_number => message.order.id
        )
      end
    end
end
