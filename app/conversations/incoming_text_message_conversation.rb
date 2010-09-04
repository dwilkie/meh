class IncomingTextMessageConversation < Conversation

  attr_accessor :action, :params

  def move_along(incoming_text_message)
    message_text = incoming_text_message.text
    message_words = message_text.split
    resource = message_words[0]
    self.topic = resource
    self.action = message_words[1].try(:downcase)
    self.params = message_words[2..-1]
    unless topic_defined?
      topic_words = topic.underscore.split("_")
      self.topic = topic_words[1..-1].join("_")
      self.action = topic_words[0]
      unless topic_defined?
        self.topic = resource[1..-1]
        self.action = resource[0]
      end
      self.params = message_words[1..-1]
    end
    conversation = details
    if topic_defined?
      if action && conversation.respond_to?(action)
        conversation.send(action) if conversation.authenticate(
          incoming_text_message
        )
      else
        conversation.invalid_action(action)
      end
    else
      self.topic = resource
      conversation.move_along
    end
  end
end

