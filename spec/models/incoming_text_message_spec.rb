require 'spec_helper'

describe IncomingTextMessage do
  describe "validations" do
    # cant find a way for active record to
    # validate uniqueness of a serialized attribute
    describe "uniqueness" do
      before {
        Factory.create(:incoming_text_message)
      }
      it "should not allow two identical incoming text messages to be created" do
        lambda {
          Factory.create(:incoming_text_message)
        }.should raise_error
      end
    end
  end
end

