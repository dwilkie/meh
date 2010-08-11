class UnknownTopicConversation < Conversation
  def move_along(message)
    user.new_record? ? say(welcome) : say(invalid_command(message))
  end

  private
    def welcome
      I18n.t("messages.welcome")
    end

    def invalid_command(message_text)
      I18n.t(
        "messages.invalid_command",
        :user => user.name,
        :topic => self.topic,
        :message_text => message_text
      )
    end
end

