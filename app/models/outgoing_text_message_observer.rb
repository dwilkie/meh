class OutgoingTextMessageObserver < ActiveRecord::Observer
  def after_create(outgoing_text_message)
    payer = outgoing_text_message.payer
    not_enough_credits(payer, outgoing_text_message) unless
      outgoing_text_message.enough_credits?
  end

  private
    def not_enough_credits(payer, outgoing_text_message)
      if payer.message_credits > -1
        notification = GeneralNotification.new(:with => payer)
        notification.force_send = true
        payer_name = payer.can_text? ? " #{payer.name}" : ""
        receiver_name = outgoing_text_message.mobile_number.user.name
        receiver_name = I18n.t(
          "notifications.messages.built_in.words.you"
        ) if receiver_name == payer.name
        notification.notify(
          I18n.t(
            "notifications.messages.built_in.you_do_not_have_enough_message_credits_left",
            :payer_name => payer_name,
            :truncated_message => outgoing_text_message.body.to_s[0..20],
            :receiver_name => receiver_name
          )
        )
      end
    end
end

