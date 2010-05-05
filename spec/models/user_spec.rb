require 'spec_helper'
describe User do
  context "who is a seller" do
    subject { seller = Factory.build(:seller) }
    context "without an email address" do
      before { subject.email = nil }
      context "but with a mobile number" do
        before { subject.mobile_number = mock_model(MobileNumber).as_null_object }
        it { should_not be_valid }
      end
    end
  end
  context "who is a supplier" do
    subject { supplier = Factory.build(:supplier) }
    context "with an email address" do
      it { should be_valid }
    end
    context "without an email address" do
      before { subject.email = nil }
      it { should_not be_valid }
      context "but with a mobile number" do
        before { subject.mobile_number = mock_model(MobileNumber).as_null_object }
        it { should be_valid }
      end
    end
  end
end
