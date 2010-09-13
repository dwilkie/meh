class IncomingTextMessageConversation < Conversation

  attr_accessor :action, :params

  def process(incoming_text_message)
    incoming_text_message.mobile_number.activate!
    conversation = find_conversation(incoming_text_message.text)
    conversation.process unless require_verified_mobile_number?(conversation)
  end

  private
    def find_conversation(message_text)
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
          self.action = resource[0].try(:downcase)
        end
        self.params = message_words[1..-1]
      end
      self.topic = resource unless topic_defined?
      details
    end

    def require_verified_mobile_number?(conversation)
      if conversation.require_verified_mobile_number? &&
        user.active_mobile_number.unverified?
        say I18n.t(
          "notifications.messages.built_in.you_must_verify_your_mobile_number_to_use_this_feature"
        )
      end
    end

end

