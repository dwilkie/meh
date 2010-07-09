class TextMessageDeliveryReceipt < ActiveRecord::Base
  belongs_to :outgoing_text_message
  serialize :params, Hash

  validates :params,
            :presence => true,
            :uniqueness => true

  validates :outgoing_text_message,
            :presence => true

  before_save :set_status

  before_validation(:on => :create) do
    self.outgoing_text_message = OutgoingTextMessage.find_by_delivery_receipt(self.params) if self.params
  end

  private
    def set_status
      self.status = SMSNotifier.connection.status(self.params)
    end
end

