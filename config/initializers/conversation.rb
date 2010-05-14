# Uncomment the following to configure Conversation to use Mail
#Conversation.converse do |with, notice|
#  Mail.deliver do
#    to with
#    from "someone@example.com"
#    subject notice
#    body notice
#  end
#end

# Or you can use Conversation with whatever you like
Conversation.converse do |with, notice|
#  notification_method = with.preferred_notification_method
#  if notification_method == "both" || notification_method == "email"
#    # send by email...
#  end
#  if notification_method == "both" || notification_method == "mobile"
#    OutgoingTextMessage.create!(:smsable => with.mobile_number, :message => notice)
#  end
  OutgoingTextMessage.create!(:smsable => with.mobile_number, :message => notice) unless with.mobile_number.nil?
end

# Configure finishing keywords
# Conversation.finishing_keywords = ["cancel"]

# Configure Unknown Topic Subclass
# Conversation.unknown_topic_subclass = UnknownTopicConversation

# Configure Blank Topic Subclass
# Conversation.blank_topic_subclass = BlankTopicConversation
