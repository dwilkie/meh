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
      I18n.t(
        "notifications.messages.built_in.valid_message_commands_are",
        :user_name => user.name
      )
    end
end

