class MobileNumberObserver < ActiveRecord::Observer
  def after_save(mobile_number)
    request_verification(mobile_number) unless
      mobile_number.number_was == mobile_number.number
    send_unqueued_messages(mobile_number) if been_verified?(mobile_number)
  end

  private

    def request_verification(mobile_number)
      if user = mobile_number.user
        notifier = GeneralNotification.new(:with => user)
        notifier.send_unverified = true
        notifier.notify(
          I18n.t(
            "notifications.messages.built_in.verify_your_mobile_number"
          )
        )
      end
    end

    def send_unqueued_messages(mobile_number)
      mobile_number.outgoing_text_messages.not_queued_for_sending.each do |message|
        message.resend
      end
    end

    def been_verified?(mobile_number)
      mobile_number.verified? &&
      mobile_number.verified_at_changed? &&
      mobile_number.verified_at_was.nil?
    end
end

