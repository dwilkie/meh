require 'spec_helper'
describe User do
  context "who is a seller" do
    subject { seller = Factory.build(:seller) }
    context "without an email address" do
      before { subject.email = nil }
      it { should_not be_valid }
    end
  end

  context "who is a supplier" do
    subject { supplier = Factory.build(:supplier) }
    context "without an email address" do
      it { should be_valid }
    end
  end

  context "who is a supplier already exists" do
    before do
      Factory.create(:supplier)
    end

    context "a new supplier" do
      subject {supplier = Factory.build(:supplier) }
      it { should be_valid }
    end
  end

  context "who is a supplier with email: 'mara@example.com' already exists" do
    before do
      Factory.create(:supplier, :email => "mara@example.com")
    end

    context "a new supplier with the same email" do
      subject {supplier = Factory.build(:supplier, :email => "mara@example.com") }
      it { should_not be_valid }
    end
  end


end

