require 'spec_helper'

describe PaymentApplication do
  describe "#validations" do
    let(:payment_application) { Factory.build(:payment_application) }
    it "should be valid with valid attributes" do
      payment_application.should be_valid
    end
    it "should not be valid without a uri" do
      payment_application.uri = nil
      payment_application.should_not be_valid
    end
    it "should not be valid without a valid uri" do
      payment_application.uri = "http://something.example_app.com"
      payment_application.should_not be_valid
    end
    it "should not be valid without a seller" do
      payment_application.seller = nil
      payment_application.should_not be_valid
    end
  end
end

