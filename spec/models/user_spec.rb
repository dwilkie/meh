require 'spec_helper'

describe User do
  context "a seller" do
    subject { Factory.build(:seller) }
    it "should not be valid without an email address" do
      subject.email = nil
      subject.should_not be_valid
    end
  end
  context "a supplier" do
    subject { Factory.build(:supplier) }
    context "with an email address" do
      before {subject.email = "someone@example.com"}
      it "should be valid without a mobile number" do
        subject.mobile_number = nil
        subject.should be_valid
      end
    end
    context "without an email address" do
      it "should be valid with a mobile number" do
        subject.mobile_number = mock_model(MobileNumber)
        subject.should be_valid
      end
      it {should_not be_valid}
    end
  end
end
