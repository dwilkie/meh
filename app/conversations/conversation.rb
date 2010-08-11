class Conversation
  include Conversational::Conversation

  attr_accessor :user
  alias :user :with

  converse do |with, notice|
    OutgoingTextMessage.create!(
      :mobile_number => with.mobile_number,
      :body => notice
    )
  end

  self.unknown_topic_subclass = UnknownTopicConversation
  self.blank_topic_subclass = UnknownTopicConversation

end

