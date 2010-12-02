class UnknownTopicConversation < IncomingTextMessageConversation

  def process
    user.active_mobile_number.unverified? ? verify : say(invalid_command)
  end

  private

    class VerifyMobileNumberMessage
      include ActiveModel::Validations

      attr_reader :name

      validates :name,
                :presence => true

      validate :name_is_correct

      def initialize(users_actual_name, incoming_name)
        @users_actual_name = users_actual_name
        @name = incoming_name
      end

      private
        def name_is_correct
          errors.add(
            :name,
            :incorrect
          ) unless name.blank? || name.downcase == @users_actual_name.downcase
        end
    end

    class InvalidMessage
      include ActiveModel::Validations

      attr_reader :message_text

      validates :message_text,
                :presence => true

      validate :command_is_valid

      def initialize(message_text)
        @message_text = message_text
      end

      private
        def command_is_valid
          errors.add(
            :message_text,
            :invalid
          ) unless message_text.blank?
        end
    end

    def verify
      message = VerifyMobileNumberMessage.new(user.name, params.join(" "))
      if message.valid?
        say your_mobile_number_is_verified
        user.active_mobile_number.verify!
      else
        say invalid_verification(message)
      end
    end

    def your_mobile_number_is_verified
      I18n.t(
        "notifications.messages.built_in.your_mobile_number_is_verified",
        :user_name => user.name
      )
    end

    def invalid_verification(message)
      I18n.t(
        "notifications.messages.built_in.your_name_is_incorrect_or_missing",
        :errors => message.errors.full_messages.to_sentence
      )
    end

    def invalid_command
      message = InvalidMessage.new(message_words.join(" "))
      message.valid?
      I18n.t(
        "notifications.messages.built_in.invalid_message_command",
        :user_name => user.name,
        :errors => message.errors.full_messages.to_sentence
      )
    end
end

