class GeneralNotification < Conversation
  def notify(notification, options = {})
    say notification.parse_message(options)
  end
end

