class AbstractConversation < Conversation
  has_many :incoming_text_messages, :foreign_key => "conversation_id"
  has_many :outgoing_text_messages, :foreign_key => "conversation_id"
  belongs_to :mobile_number, :foreign_key => "with"

  protected
    # Overridden to return the associated mobile number
    def say(message)
      @@notification.call(mobile_number, message, self)
    end
end

