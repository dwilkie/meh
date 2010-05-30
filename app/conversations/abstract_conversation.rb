class AbstractConversation < Conversation
  belongs_to :user, :foreign_key => "with"

  protected
    # Overridden to return the associated user
    def say(message)
      @@notification.call(user, message)
    end
end

