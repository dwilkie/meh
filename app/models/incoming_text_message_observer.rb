class IncomingTextMessageObserver < ActiveRecord::Observer
  def after_create(incoming_text_message)
    mobile_number = incoming_text_message.mobile_number
    phoneable = (mobile_number.phoneable || mobile_number.phoneable = User.new)
    message_text = incoming_text_message.params[:msg]
    Conversation.new(
      :with => phoneable,
      :topic => message_text.try(:split, " ").try(:[], 0)
    )
  end
end

#        unauthenticated_message = AuthenticationNotification::Message.new(
#          message_text,
#          smsable
#        )
#        if unauthenticated_message.valid?
#          message_text = unauthenticated_message.request
#          topic = message_text.split(" ")[0]
#          Conversation.new(
#            :with => smsable.phoneable,
#            :topic => topic
#          ).details.move_along!(message_text)
#        else
#          AuthenticationNotification.new(
#            :with => smsable.phoneable
#          ).not_authenticated(unauthenticated_message)
#        end

