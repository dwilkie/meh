class IncomingTextMessageConversation < Conversation

  attr_accessor :action, :params

  def move_along(incoming_text_message)
    activate(incoming_text_message.mobile_number)
    conversation = find_conversation(incoming_text_message.text)
    unless require_user?(conversation)
      unless require_verified_mobile_number?(conversation)
        if topic_defined?
          (action && conversation.respond_to?(action)) ?
            conversation.send(action) :
            conversation.invalid_action(action)
        else
          self.topic = resource
          conversation.move_along
        end
      end
    end
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
          self.action = resource[0]
        end
        self.params = message_words[1..-1]
      end
      details
    end

    def activate(mobile_number)
      unless mobile_number == user.active_mobile_number
        user.active_mobile_number = mobile_number
        user.save! unless mobile_number.unverified?
      end
    end

    def require_user?(conversation)
      if conversation.require_user? && user.new_record?
        say I18n.t
        (
          "notifications.messsages.built_in.you_must_register_to_use_this_service"
        )
      end
    end

    def require_verified_mobile_number?(conversation)
      if conversation.require_verified_mobile_number? &&
        user.active_mobile_number.unverified?
        say I18n.t
        (
          "notifications.messsages.built_in.you_must_verify_your_mobile_number_to_use_this_service"
        )
      end
    end

end

