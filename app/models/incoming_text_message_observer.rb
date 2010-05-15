class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    if smsable = incoming_text_message.smsable
      message_text = incoming_text_message.params[:msg]
      topic = message_text.split(" ").first
      Conversation.create!(
        :with => smsable.phoneable,
        :topic => topic
      ).details.move_along!(message_text)
    end
  end
end
