class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    if smsable = incoming_text_message.smsable
      topic = incoming_text_message.params[:msg].split(" ").first
      Conversation.create!(
        :with => smsable.phoneable,
        :topic => topic
      ).details.move_along!(incoming_text_message)
    end
  end
end
