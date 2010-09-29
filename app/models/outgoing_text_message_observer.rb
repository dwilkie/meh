class OutgoingTextMessageObserver < ActiveRecord::Observer
  def after_create(outgoing_text_message)
    payer = outgoing_text_message.payer
    if payer.message_credits - outgoing_text_message.credits < 0
      notification = GeneralNotification.new(:with => payer)
      notification.force_send = true
      notification.notify(
        I18n.t(
          "notifications.messages.built_in.you_do_not_have_enough_message_credits_left",
          :payer_name => payer.name,
          :truncated_message => outgoing_text_message.body[0..20]
        )
      ) if payer.message_credits > -1
    end
  end
end

