class AuthenticationNotification < Conversation
  def not_authenticated(message)
    say I18n.t(
      "messages.not_authenticated",
      :errors => message.errors.full_messages.to_sentence
    )
  end
end

