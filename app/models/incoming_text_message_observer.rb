class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    mobile_number = incoming_text_message.mobile_number
    phoneable = (mobile_number.phoneable || mobile_number.phoneable = User.new)
    message_text = incoming_text_message.params[:msg]
    Conversation.new(
      :with => phoneable,
      :topic => message_text.try(:split, " ").try(:[], 0)
    ).details.move_along(message_text)
  end
end

