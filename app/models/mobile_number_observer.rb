class MobileNumberObserver < ActiveRecord::Observer
  def after_save(mobile_number)
    request_verification(mobile_number) unless
      mobile_number.number_was == mobile_number.number
  end

  private

    def request_verification(mobile_number)
      if user = mobile_number.user
        notifier = GeneralNotification.new(:with => user)
        notifier.force_send = true
        notifier.notify(
          I18n.t(
            "notifications.messages.built_in.verify_your_mobile_number"
          )
        )
      end
    end
end

