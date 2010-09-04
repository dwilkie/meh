class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    mobile_number = incoming_text_message.mobile_number
    phoneable_user = mobile_number.user
    unless phoneable_user
      phoneable_user = User.new
    end
    incoming_text_message_conversation = IncomingTextMessageConversation.new(
      :with => phoneable_user
    )
    incoming_text_message_conversation.move_along(incoming_text_message)
  end
end

