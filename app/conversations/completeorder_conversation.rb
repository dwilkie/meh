class CompleteorderConversation < AbstractProcessOrderConversation
  def move_along!(message)
    message = AbstractProcessOrderConversation::OrderMessage.new(message, user)
    super(message)
    unless finished?
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
    end
  end
end
