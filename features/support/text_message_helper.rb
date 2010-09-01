module TextMessageHelper
  def find_text_message(options = {})
    if options[:mobile_number]
      mobile_number = model!(options[:mobile_number])
      text_messages = mobile_number.outgoing_text_messages.all
      if options[:text_message_index]
        text_message = text_messages[
          text_messages.size - options[:text_message_index].to_i
        ]
      else
        text_message = mobile_number.outgoing_text_messages.last
      end
    else
      text_message = model!(options[:text_message])
    end
  end
end

World(TextMessageHelper)

