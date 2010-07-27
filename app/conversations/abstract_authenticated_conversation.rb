class AbstractAuthenticatedConversation < Conversation
  class Message
    include ActiveModel::Validations
    class CorrectValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, :incorrect) unless
        value.nil? || !record.errors.empty? || record.mobile_number.valid_password?(value)
      end
    end

    attr_reader   :pin_number, :raw_message, :mobile_number

    validates :pin_number,
              :presence => true,
              :format => /^\d{4}$/,
              :correct => true,
              :allow_nil => true

    def initialize(raw_message, user)
      @raw_message = raw_message
      message_contents = @raw_message.split(" ")
      @pin_number = message_contents[1]
      @mobile_number = user.mobile_number
      message_contents
    end
  end
end

