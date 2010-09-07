class UnknownTopicConversation < Conversation
  def process

  end

  def require_user?
    false
  end

  def require_verified_mobile_number?
    false
  end

end

