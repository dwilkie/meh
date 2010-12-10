class OutgoingTextMessage < ActiveRecord::Base
  class SendOutgoingTextMessageJob < Struct.new(:id)

    def outgoing_text_message
      @outgoing_text_message || @outgoing_text_message = OutgoingTextMessage.find(id)
    end

    def perform
      gateway_response = ActionSms::Base.deliver(
        outgoing_text_message,
        :filter_response => true
      )
      gateway_message_id = ActionSms::Base.message_id(gateway_response)
      raise(Exception, gateway_response) unless
        ActionSms::Base.delivery_request_successful?(gateway_response)
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
    end
  end

  attr_accessor :force_send, :cancel_send, :no_credit_warning

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

  scope :not_queued_for_sending, where(:queued_for_sending_at => nil)

  def self.find_by_delivery_receipt(delivery_receipt)
    gateway_message_id = ActionSms::Base.message_id(delivery_receipt)
    OutgoingTextMessage.where(
      ["gateway_message_id = ?", gateway_message_id]
    ).first
  end

  def recipient
    mobile_number.to_s
  end

  def enough_credits?
    payer.message_credits - credits >= 0
  end

  def queued_for_sending?
    !queued_for_sending_at.nil?
  end

  def will_send?
    force_send || (enough_credits? && !cancel_send)
  end

  def resend
    send_message unless queued_for_sending?
  end

  def no_credit_warning?
    no_credit_warning
  end

  def no_credit_warning=(value)
    self.force_send = value if value
    @no_credit_warning = value
  end

  private
    def send_message
      if will_send?
        Delayed::Job.enqueue(
          SendOutgoingTextMessageJob.new(self.id), :priority => 1
        )
        self.update_attributes!(:queued_for_sending_at => Time.now)
        payer.deduct_message_credits(credits)
      end
    end

    def calculate_credits
      message_length = body.to_s.length
      self.credits = message_length <= 160 ? 1 : 1 + (message_length - 1) / 153
    end

    def link_payer
      self.payer = mobile_number.try(:user) unless payer
    end
end

