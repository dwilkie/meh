class OutgoingTextMessage < ActiveRecord::Base
  belongs_to :smsable, :polymorphic => true

  after_create :send_message

  def recipients
    [smsable.to_s]
  end

  def send_message
    response = SMSNotifier.deliver(self)
    self.update_attribute(:gateway_response, response)
  end
  handle_asynchronously :send_message
end

