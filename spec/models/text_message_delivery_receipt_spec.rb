require 'spec_helper'

describe TextMessageDeliveryReceipt do
  describe "validations" do
    it "should not be valid without an associated outgoing text message" do
      text_message_delivery_receipt = Factory.build(:text_message_delivery_receipt)
      text_message_delivery_receipt.outgoing_text_message = nil
      text_message_delivery_receipt.should_not be_valid
    end
    it "should not be valid without params" do
      text_message_delivery_receipt = Factory.build(:text_message_delivery_receipt)
      text_message_delivery_receipt.params = nil
      text_message_delivery_receipt.should_not be_valid
    end
  end
end

