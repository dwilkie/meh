class TextMessageDeliveryReceipt < ActiveRecord::Base
  belongs_to :outgoing_text_message
  serialize :params

  validates :outgoing_text_message,
            :params,
            :presence => true

  before_save :set_status

  before_validation(:on => :create) do
    self.outgoing_text_message = OutgoingTextMessage.find_by_delivery_receipt(self.params)
  end

  private
    def set_status
      self.status = SMSNotifier.connection.status(self.params)
    end
end

