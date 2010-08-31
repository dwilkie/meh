class AbstractAuthenticatedConversation < IncomingTextMessageConversation
  def authenticate
    pin_number = params.slice!(0)
    if user.mobile_number.valid_password?(pin_number)
      true
    else
      say I18n.t(
        "notifications.messages.built_in.your_pin_number_is_incorrect",
        :topic => self.topic,
        :action => self.action
      )
      false
    end
  end
end

