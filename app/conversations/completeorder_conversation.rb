class CompleteorderConversation < AbstractProcessOrderConversation
  def move_along!(message)
    if user.is?(:supplier)
      message = AbstractProcessOrderConversation::SupplierOrderMessage.new(message, user)
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
