class TextMessageDeliveryReceipt < ActiveRecord::Base
  class CreateTextMessageDeliveryReceiptJob < Struct.new(:params)
    attr_reader :attempt_job

    MAX_ATTEMPTS = 1

    def before(job)
      @attempt_job = job.attempts < MAX_ATTEMPTS
    end

    def perform
      TextMessageDeliveryReceipt.create(params) if attempt_job
    end
  end

  belongs_to :outgoing_text_message
  serialize :params, Hash

  validates :params,
            :presence => true,
            :uniqueness => true

  validates :outgoing_text_message,
            :presence => true

  before_save :set_status

  before_validation(:on => :create) do
    self.outgoing_text_message = OutgoingTextMessage.find_by_delivery_receipt(
      params
    ) if params
  end

  def self.create_later(params)
    Delayed::Job.enqueue(
      CreateTextMessageDeliveryReceiptJob.new(params)
    )
  end

  private
    def set_status
      self.status = SMSNotifier.connection.status(params)
    end
end

