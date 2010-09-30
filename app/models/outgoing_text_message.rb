class OutgoingTextMessage < ActiveRecord::Base
  class SendOutgoingTextMessageJob < Struct.new(:id)

    def outgoing_text_message
      @outgoing_text_message || @outgoing_text_message = OutgoingTextMessage.find(id)
    end

    def perform
      gateway_response = SMSNotifier.deliver(outgoing_text_message)
      gateway_message_id = SMSNotifier.connection.message_id(gateway_response)
      raise(Exception, gateway_response) unless
        SMSNotifier.connection.delivery_request_successful?(gateway_response)
      outgoing_text_message.update_attributes(
        :gateway_response => gateway_response,
        :gateway_message_id => gateway_message_id,
        :sent_at => Time.now
      )
    end

    def failure(job, exception)
      outgoing_text_message.update_attributes(
        :last_failed_to_send_at => Time.now
      )
    end

    def on_permanent_failure
      outgoing_text_message.update_attributes(
        :permanently_failed_to_send_at => Time.now
      )
      outgoing_text_message.payer.add_message_credits(
        outgoing_text_message.credits
      )
    end
  end

  attr_accessor :force_send

  belongs_to :mobile_number
  belongs_to :payer, :class_name => "User"
  has_many :text_message_delivery_receipts

  before_validation :link_payer, :calculate_credits, :on => :create
  after_create :send_message

  validates :gateway_message_id,
            :uniqueness => true,
            :allow_nil => true

  validates :mobile_number,
            :presence => true

  validates :payer,
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

  def should_send?
    @should_send || @should_send = (
      force_send || payer.message_credits - credits >= 0
    )
  end

  private
    def calculate_credits
      message_length = body.to_s.length
      self.credits = message_length <= 160 ? 1 : 1 + (message_length - 1) / 153
    end

    def link_payer
      self.payer = mobile_number.user unless payer
    end

    def send_message
      if should_send?
        Delayed::Job.enqueue(
          SendOutgoingTextMessageJob.new(self.id), 1
        )
        self.update_attributes!(:queued_for_sending_at => Time.now)
        payer.deduct_message_credits(credits)
      end
    end
end

