class UnknownTopicConversation < Conversation
  def process
    user_name = user.active_mobile_number.verified? ? " #{user.name}" : ""
    self.payer = user.outgoing_text_messages_payer
    say I18n.t(
      "notifications.messages.built_in.valid_message_commands_are",
      :user_name => user_name
    )
  end

  def require_verified_mobile_number?
    false
  end

end

