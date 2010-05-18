class AbstractConversation < Conversation
  belongs_to :user, :foreign_key => "with"

  protected
    # Overridden to return the associated user and finish the conversation
    def say(message)
      @@notification.call(user, message)
      finish # no multi part conversations for this app
    end
end

