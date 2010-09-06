class GeneralNotification < Conversation
  def notify(notification, options = {})
    if notification.is_a?(Notification)
      say notification.parse_message(options)
    elsif notification.is_a?(String)
      say notification
    end
  end
end

