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
      payer = outgoing_text_message.payer
      payer.update_attributes(
        :message_credits => payer.message_credits - outgoing_text_message.credits
      ) if SMSNotifier.connection.delivery_request_successful?(gateway_response)
    end
  end

  belongs_to :mobile_number
  belongs_to :payer
  has_many :text_message_delivery_receipts

  before_create :link_payer, :calculate_credits
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

  private
    def calculate_credits
      message_length = message_text.to_s.length
      credits = message_length <= 160 ? 1 : 1 + (message_length - 1) / 153
    end

    def link_payer
      payer = self.mobile_number.user unless payer
    end

    def send_message
      Delayed::Job.enqueue(
        SendOutgoingTextMessageJob.new(self.id), 1
      ) if payer.message_credits >= credits
    end
end

