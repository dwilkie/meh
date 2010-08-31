class UnknownTopicConversation
  def move_along
    user.new_record? ? say(welcome) : say(invalid_command(message))
  end

  private
    def welcome
      I18n.t("messages.welcome")
    end

    def invalid_command
      I18n.t(
        "messages.invalid_command",
        :user => user.name,
        :topic => self.topic
      )
    end
end

