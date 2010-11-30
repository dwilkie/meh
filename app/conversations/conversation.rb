class Conversation
  include Conversational::Conversation

  attr_accessor :user, :force_send, :payer
  alias :user :with

  self.unknown_topic_subclass = UnknownTopicConversation
  self.blank_topic_subclass = UnknownTopicConversation

  protected

    def say(something)
      if active_mobile_number = user.active_mobile_number
        self.payer = user.sellers.first if payer.nil? && user.sellers.count == 1
        outgoing_text_message = OutgoingTextMessage.new(
          :mobile_number => active_mobile_number,
          :body => something.strip,
          :payer => payer
        )
        outgoing_text_message.force_send = force_send
        outgoing_text_message.cancel_send = user.cannot_text?
        outgoing_text_message.save!
      end
    end
end

