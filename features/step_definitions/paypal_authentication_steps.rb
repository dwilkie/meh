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

Then /^I should be redirected to sign in with paypal$/ do
  assert_equal_to_paypal_url(current_url, Paypal.uri)
end

