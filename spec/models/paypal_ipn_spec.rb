require 'spec_helper'

describe PaypalIpn do
  describe "validations" do
    # tests the factory
    it "should be valid with valid attributes" do
      paypal_ipn = Factory.build(:paypal_ipn)
      paypal_ipn.should be_valid
    end
    it "should not be valid without params" do
      paypal_ipn = Factory.build(:paypal_ipn)
      paypal_ipn.params = nil
      paypal_ipn.should_not be_valid
      paypal_ipn.errors_on(:params).should_not be_empty
    end
    it "should not be valid without an associated seller" do
      paypal_ipn = Factory.build(:paypal_ipn)
      paypal_ipn.params["receiver_email"] = ""
      paypal_ipn.should_not be_valid
      paypal_ipn.errors_on(
        :seller
      ).should_not be_empty
    end
  end
  it "should not be valid with a duplicate transaction id" do
    paypal_ipn = Factory.create(:paypal_ipn)
    duplicate_paypal_ipn = Factory.build(:paypal_ipn)
    duplicate_paypal_ipn.params["txn_id"] = paypal_ipn.params["txn_id"]
    duplicate_paypal_ipn.should_not be_valid
    duplicate_paypal_ipn.errors_on(:transaction_id).should_not be_empty
  end
end

