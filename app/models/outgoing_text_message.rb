class OutgoingTextMessage < ActiveRecord::Base
  class SendOutgoingTextMessageJob < Struct.new(:id)
    def perform
      outgoing_text_message = OutgoingTextMessage.find(id)
      gateway_response = SMSNotifier.deliver(outgoing_text_message)
      gateway_message_id = SMSNotifier.connection.message_id(gateway_response)
      outgoing_text_message.update_attributes(
        :gateway_response => gateway_response,
        :gateway_message_id => gateway_message_id,
        :sent_at => Time.now
      )
    end
  end

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

  def recipient
    mobile_number.to_s
  end

  def send_message
     Delayed::Job.enqueue(
      SendOutgoingTextMessageJob.new(self.id), 1
    )
  end
end

