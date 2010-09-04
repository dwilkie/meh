class OutgoingTextMessage < ActiveRecord::Base
  belongs_to :mobile_number
  has_many :text_message_delivery_receipts

  after_create :send_message

  validates :gateway_message_id,
            :uniqueness => true,
            :allow_nil => true

  validates :mobile_number,
            :presence => true

  def self.find_by_delivery_receipt(delivery_receipt)
    gateway_message_id = SMSNotifier.connection.message_id(delivery_receipt)
    OutgoingTextMessage.where(
      ["gateway_message_id = ?", gateway_message_id]
    ).first
  end

  def recipients
    [mobile_number.to_s]
  end

  def user_field
    Rails.application.config.secret_token
  end

  def send_message
    gateway_response = SMSNotifier.deliver(self)
    gateway_message_id = SMSNotifier.connection.message_id(gateway_response)
    self.update_attributes(
      :gateway_response => gateway_response,
      :gateway_message_id => gateway_message_id
    )
  end
  handle_asynchronously :send_message
end

