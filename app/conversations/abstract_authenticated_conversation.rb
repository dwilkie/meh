class AbstractAuthenticatedConversation < IncomingTextMessageConversation
  def authenticate(incoming_text_message)
    if incoming_text_message.authenticated?
      true
    else
      say I18n.t(
        "notifications.messages.built_in.incoming_text_message_was_not_authenticated",
        :topic => self.topic,
        :action => self.action
      )
      false
    end
  end
end

