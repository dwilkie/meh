class TextMessageDeliveryReceipt < ActiveRecord::Base
  belongs_to :outgoing_text_message
  serialize :params

  validate :outgoing_text_message,
           :presence => true

  before_create :find_outgoing_text_message, :set_status

  private
    def set_status
      self.status = SMSNotifier.connection.status(self.params)
    end

    def find_outgoing_text_message
      self.outgoing_text_message = OutgoingTextMessage.find_by_delivery_receipt(self.params)
    end
end

