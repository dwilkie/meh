class RejectorderConversation < AbstractProcessOrderConversation

  class RejectOrderMessage < AbstractProcessOrderConversation::OrderMessage
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
    super(message)
    unless finished?
      processed = "rejected"
      if message.valid?
        order = message.order
        if order.unconfirmed?
          if message.confirmed?
            order.reject
            say successfully(processed, order)
          else
            say confirm_reject(order)
          end
        else
          say cannot_process(order)
        end
      else
        say invalid(message, processed)
      end
    end
  end
  
  private
    def confirm_reject(order)
      I18n.t(
          "messages.confirm_reject_order",
          :supplier => user.name,
          :order_number => order.id
        )
    end
end
