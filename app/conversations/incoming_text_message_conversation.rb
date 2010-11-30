class IncomingTextMessageConversation < Conversation

  attr_accessor :action, :params, :message_words

  def process(incoming_text_message)
    incoming_text_message.mobile_number.activate!
    conversation = find_conversation(incoming_text_message.text)
    conversation.process
  end

  private
    def find_conversation(message_text)
      self.message_words = message_text.split
      if user.active_mobile_number.unverified?
        self.topic = nil
        self.params = message_words
        details
      else
        # assume first word is the resource
        # and the second word is the action
        resource = message_words[0]
        self.topic = resource
        self.action = message_words[1].try(:downcase)
        self.params = message_words[2..-1]
        unless topic_defined?
          # assume first character of the first word is the action
          # and the remaining characters are the resource
          self.topic = resource[1..-1]
          self.action = resource[0].try(:downcase)
          self.params = message_words[1..-1]
          unless topic_defined?
            # assume the first word is the action
            # and the second word is the resource
            self.topic = message_words[1]
            self.action = message_words[0]
            self.params = message_words[2..-1]
          end
        end
        self.params ||= []
        self.topic = resource unless topic_defined?
        details
      end
    end

    def sanitize_id(value = nil)
      sanitized_id = value.try(:gsub, /\D/, "").try(:to_i)
      sanitized_id = nil if sanitized_id == 0
      sanitized_id
    end
end

