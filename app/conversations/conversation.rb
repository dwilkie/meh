class Conversation
  include Conversational::Conversation

  attr_accessor :user, :force_send
  alias :user :with

  self.unknown_topic_subclass = UnknownTopicConversation
  self.blank_topic_subclass = UnknownTopicConversation

  protected
    def say(something)
      outgoing_text_message = OutgoingTextMessage.new(
        :mobile_number => user.active_mobile_number,
        :body => something
      )
      outgoing_text_message.force_send = force_send
      outgoing_text_message.save!
    end
end

