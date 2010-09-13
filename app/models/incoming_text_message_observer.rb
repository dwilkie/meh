class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    IncomingTextMessageConversation.new(
      :with => incoming_text_message.mobile_number.user
    ).process(incoming_text_message)
  end
end

