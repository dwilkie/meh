class AcceptorderConversation < AbstractConversation
  
  # A valid text message should be formatted as follows:
  # acceptorder <order_id> <quantity> <pv code> <new quantity>
  # e.g. acceptorder 6788965 4 243553 2
  
  def move_along!(message)
    parsed_message = parse_message(message.params[:msg])
  end
  
  private
    def parse_message(message_text)
      parsed_message = {}
      message_contents = message_text.split(" ")
      parsed_message[:order_id] = message_contents[1]
      parsed_message[:quantity] = message_contents[2]
      parsed_message[:product_verification_code] = message_contents[3]
      parsed_message[:updated_quantity] = message_contents[4]
      parsed_message
    end
end
