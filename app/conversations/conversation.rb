class Conversation
  attr_accessor :user, :payer, :send_unverified,
                :no_credit_warning, :force_send

  def initialize(options = {})
    self.user = options[:user]
    self.payer = options[:payer]
    self.send_unverified = options[:send_unverified]
    self.no_credit_warning = options[:no_credit_warning]
    self.force_send = options[:force_send]
  end

  protected

    def say(something)
      if active_mobile_number = user.active_mobile_number
        self.payer = user.sellers.first if payer.nil? && user.sellers.count == 1
        outgoing_text_message = OutgoingTextMessage.new(
          :mobile_number => active_mobile_number,
          :body => something.strip,
          :payer => payer
        )
        outgoing_text_message.force_send = force_send
        outgoing_text_message.cancel_send = !send_unverified && user.cannot_text?
        outgoing_text_message.no_credit_warning = no_credit_warning
        outgoing_text_message.save!
      end
    end
end

