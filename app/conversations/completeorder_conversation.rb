class CompleteorderConversation < AbstractProcessOrderConversation

  class Message < AbstractProcessOrderConversation::Message
    attr_reader   :tracking_number

    validates :tracking_number,
              :presence => true,
              :format => /^cp|re\d{9}th$/i,
              :allow_blank => true

    def initialize(raw_message, supplier)
      message_contents = super
      @tracking_number = message_contents[3]
    end
  end

  def move_along(message)
    if user.is?(:supplier)
      message = Message.new(message, user)
      processed = "completed"
      if message.valid?
        order = message.order
        if order.accepted?
          order.complete
          say successfully(processed, order)
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

