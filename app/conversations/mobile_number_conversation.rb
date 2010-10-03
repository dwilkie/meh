class MobileNumberConversation < IncomingTextMessageConversation

  def process
    if action == "verify" || action == "v"
      verify
    else
      invalid_action
    end
  end

  def require_verified_mobile_number?
    false
  end

  private

    class VerifyMobileNumberMessage
      include ActiveModel::Validations

      attr_reader :name

      validates :name,
                :presence => true

      validate :name_is_correct

      def initialize(user_name, params)
        @user_name = user_name
        @name = params[0]
      end

      private
        def name_is_correct
          errors.add(
            :name,
            :incorrect
          ) unless name.nil? || name.downcase == @user_name.downcase
        end
    end

    def verify
      message = VerifyMobileNumberMessage.new(user.name, params)
      if message.valid?
        user.active_mobile_number.verify!
        say I18n.t(
          "notifications.messages.built_in.you_successfully_verified_your_mobile_number",
          :name_supplied => message.name
        )
      else
        say I18n.t(
          "notifications.messages.built_in.the_name_is_missing_or_incorrect",
          :errors => message.errors.full_messages.to_sentence,
          :topic => topic,
          :action => action
        )
      end
    end

    def invalid_action
      if action
        say I18n.t(
          "notifications.messages.built_in.invalid_action_for_mobile_number",
          :topic => topic,
          :action => action
        )
      else
        say I18n.t(
          "notifications.messages.built_in.no_action_for_mobile_number",
          :topic => topic
        )
      end
    end

    def say(message)
      self.payer = user.outgoing_text_messages_payer
      super(message)
    end
end

