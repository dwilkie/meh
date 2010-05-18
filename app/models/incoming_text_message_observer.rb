class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    if smsable = incoming_text_message.smsable
      message_text = incoming_text_message.params[:msg]
      unauthenticated_message = NotAuthenticatedConversation::UnauthenticatedMessage.new(message_text, smsable)
      if unauthenticated_message.valid?
        message_text = unauthenticated_message.request
        topic = message_text.split(" ")[0]
        Conversation.create!(
          :with => smsable.phoneable,
          :topic => topic
        ).details.move_along!(message_text)
      else
        NotAuthenticatedConversation.create!(
          :with => smsable.phoneable,
          :topic => "not_authenticated"
        ).move_along!(unauthenticated_message)
      end
    end
  end
end
