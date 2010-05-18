class NotAuthenticatedConversation < AbstractConversation
  class UnauthenticatedMessage
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

    def initialize(raw_message, mobile_number)
      @raw_message = raw_message
      @pin_number = raw_message.split(" ")[0]
      @mobile_number = mobile_number
    end
    
    def request
      message_elements = @raw_message.split(" ")
      message_elements.delete_at(0)
      message_elements.join(" ")
    end
    
  end

  def move_along!(message)
    say not_authenticated(message)
  end
  
  private
    def not_authenticated(message)
      I18n.t(
        "messages.not_authenticated",
        :errors => message.errors.full_messages.to_sentence
      )
    end
end
