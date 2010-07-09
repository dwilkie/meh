require 'spec_helper'

describe IncomingTextMessage do
  describe "validations" do
    # tests the factory
    it "should be valid with valid attributes" do
      incoming_text_message = Factory.build(:incoming_text_message)
      incoming_text_message.should be_valid
    end
    it "should not be valid without params" do
      incoming_text_message = Factory.build(:incoming_text_message)
      incoming_text_message.params = nil
      incoming_text_message.should_not be_valid
      incoming_text_message.errors_on(:params).should_not be_empty
    end
    it "should not be valid without a 'from' attribute" do
      incoming_text_message = Factory.build(:incoming_text_message)
      incoming_text_message.params["from"] = ""
      incoming_text_message.should_not be_valid
      incoming_text_message.errors_on(:from).should_not be_empty
    end
    # can't find a way for active record to
    # validate uniqueness of a serialized attribute
    it "should not allow two identical incoming text messages to be created" do
      incoming_text_message = Factory.create(:incoming_text_message)
      duplicate_incoming_text_message = Factory.build(:incoming_text_message)
      duplicate_incoming_text_message.params = incoming_text_message.params
      lambda {
        duplicate_incoming_text_message.save!
      }.should raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end

