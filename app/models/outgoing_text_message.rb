class OutgoingTextMessage < ActiveRecord::Base
  belongs_to :smsable, :polymorphic => true
  has_many :text_message_delivery_receipts

  after_create :send_message

  validates :gateway_message_id,
            :uniqueness => true,
            :allow_nil => true

  def self.find_by_delivery_receipt(delivery_receipt)
    gateway_message_id = SMSNotifier.connection.message_id(delivery_receipt)
    OutgoingTextMessage.where(
      ["gateway_message_id = ?", gateway_message_id]
    ).first
  end

  def recipients
    [smsable.to_s]
  end

  def send_message
    response = SMSNotifier.deliver(self)
    gateway_message_id = SMSNotifier.connection.message_id(response)
    self.update_attributes!(
      :gateway_response => response,
      :gateway_message_id => gateway_message_id
    )
  end
  handle_asynchronously :send_message
end

