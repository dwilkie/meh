class AbstractConversation < Conversation
  class Message
    attr_reader :text, :elements, :command

    def initialize(message_text)
      @text = message_text
      @elements = @text.split
      @command = @elements[0]
    end
  end

  protected
    def check_pin_number(message_command_format, pin_number)
      if message_command_format.pin_number_required? &&
        !user.valid_password?(pin_number)
        notify(
          "invalid_pin_number",
          message_command_format.seller,
        )
        false
      else
        true
      end
    end

    def notify(event, seller, options = {})
      notifications = seller.notifications.for_event(
        event,
        :product => options[:product],
        :supplier => options[:supplier]
      )
      general_notification = GeneralNotification.new(:with => user)
      notifications.each do |notification|
        general_notification.notify(
          notification,
          options.merge(:user => user)
        )
      end
   end
end

