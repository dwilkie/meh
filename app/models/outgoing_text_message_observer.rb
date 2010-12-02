class OutgoingTextMessageObserver < ActiveRecord::Observer
  def after_create(outgoing_text_message)
    no_credits_remaining(outgoing_text_message) unless
      outgoing_text_message.enough_credits? || outgoing_text_message.no_credit_warning?
  end

  def after_update(outgoing_text_message)
    if permanently_failed_to_send?(outgoing_text_message)
      refund_credits(outgoing_text_message)
    end
  end

  private
    def no_credits_remaining(outgoing_text_message)
      payer = outgoing_text_message.payer
      notification = GeneralNotification.new(
        :with => payer,
        :no_credit_warning => true
      )
      payer_name = payer.can_text? ? "#{payer.name}, " : ""
      notification.notify(
        I18n.t(
          "notifications.messages.built_in.no_credits_remaining",
          :payer_name => payer_name
        )
      )
    end

    def permanently_failed_to_send?(outgoing_text_message)
      outgoing_text_message.permanently_failed_to_send_at? &&
      outgoing_text_message.permanently_failed_to_send_changed? &&
      outgoing_text_message_permanently_failed_to_send_was.nil?
    end

    def refund_credits(outgoing_text_message)
      outgoing_text_message.payer.add_message_credits(
        outgoing_text_message.credits
      )
    end
end

