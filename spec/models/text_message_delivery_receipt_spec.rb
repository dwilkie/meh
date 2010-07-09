require 'spec_helper'

describe TextMessageDeliveryReceipt do
  describe "validations" do
    # tests the factory
    it "should be valid with valid attributes" do
      text_message_delivery_receipt = Factory.build(:text_message_delivery_receipt)
      text_message_delivery_receipt.should be_valid
    end
    it "should not be valid without params" do
      text_message_delivery_receipt = Factory.build(:text_message_delivery_receipt)
      text_message_delivery_receipt.params = nil
      text_message_delivery_receipt.should_not be_valid
      text_message_delivery_receipt.errors_on(:params).should_not be_empty
    end
    it "should not be valid without an associated outgoing text message" do
      text_message_delivery_receipt = Factory.build(:text_message_delivery_receipt)
      text_message_delivery_receipt.params["msgid"] = ""
      text_message_delivery_receipt.should_not be_valid
      text_message_delivery_receipt.errors_on(
        :outgoing_text_message
      ).should_not be_empty
    end
  end
  it "should not allow two identical text message delivery receipts to be created" do
    text_message_delivery_receipt = Factory.create(
      :text_message_delivery_receipt
    )
    duplicate_text_message_delivery_receipt = Factory.build(
      :text_message_delivery_receipt
    )
    duplicate_text_message_delivery_receipt.params = text_message_delivery_receipt.params
    lambda {
      duplicate_text_message_delivery_receipt.save!
    }.should raise_error(ActiveRecord::RecordNotUnique)
  end
end

