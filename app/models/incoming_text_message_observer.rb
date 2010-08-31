class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    mobile_number = incoming_text_message.mobile_number
    phoneable = mobile_number.phoneable
    unless phoneable
      phoneable = User.new
      phoneable.mobile_number = mobile_number
    end
    message_text = incoming_text_message.text
    incoming_text_message_conversation = IncomingTextMessageConversation.new(
      :with => phoneable
    )
    incoming_text_message_conversation.move_along(message_text)
  end
end

