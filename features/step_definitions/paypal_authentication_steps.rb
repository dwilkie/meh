Given /^I signed up with mobile number: "([^"]*)"$/ do |number|
  @user_params = {
    :user => {
      "mobile_numbers_attributes"=>{
        "0"=>{
          "number"=>"#{number}"
        }
      }
    }
  }
end

Given /^#{capture_model} has a token$/ do |name|
  model!(name).update_attributes(
    :token => sample_paypal_authentication_token << Factory.next(:basic)
  )
end

Given /^I have a paypal account(?: with #{capture_fields})?$/ do |fields|
  @paypal_user_details = parse_fields(fields)
end

Given /^I successfully signed in with paypal$/ do
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri, :body => get_user_details_response(@paypal_user_details)
  )
end

Given /^I did not sign in with paypal$/ do
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri, :body => get_user_details_response(
      @paypal_user_details, :unauthorized => true
    )
  )
end

When /^I am redirected back to the application from paypal$/ do
  When "I go to the paypal authable callback page"
end

Then /^I should be redirected to sign in with Paypal$/ do
  assert_equal_to_paypal_url(current_url, Paypal.uri)
end

