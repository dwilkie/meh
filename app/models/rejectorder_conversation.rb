class RejectorderConversation < AbstractConfirmOrderConversation

  @@options = {
    :confirm_order_action => "reject",
    :confirm_order_action_human_name => "reject orders",
    :invalid_message_i18n_key => "messages.reject_order_invalid_message"
  }

  class RejectOrderMessage < AbstractConfirmOrderConversation::AbstractMessage
  end

  def move_along!(message)
    super(RejectOrderMessage.new(message, user), @@options)
  end
end
