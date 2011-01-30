module TextMessageHelper
  def find_text_message(options = {})
    if options[:mobile_number]
      mobile_number = model!(options[:mobile_number])
      text_messages = mobile_number.outgoing_text_messages.all
      options[:text_message_index] ||= 1
        text_message = text_messages[
          0 - options[:text_message_index].to_i
        ]
    else
      text_message = model!(options[:text_message])
    end
    options[:name] ||= options[:text_message]
    find_model!(options[:name], :id => text_message.id)
    text_message
  end
end

World(TextMessageHelper)

