Given /^#{capture_model} (has|does not have) a token$/ do |name, has_token|
  token = sample_paypal_authentication_token << Factory.next(:basic).to_s if has_token == "has"
  model!(name).update_attributes!(
    :token => token
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

Given /^paypal will (not )?return an authentication token$/ do |expectation|
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri,
    :body => sample_set_auth_flow_param_response(expectation.present?)
  )
end

When /^I am redirected back from paypal with the #{capture_model}'s token$/ do |name|
  paypal_authentication = model!(name)
  visit user_paypal_authentication_path(
    paypal_authentication,
    paypal_authentication_token_query_hash(paypal_authentication.token)
  )
end

Then /^I should be redirected to sign in with Paypal$/ do
  assert_equal_to_paypal_url(current_url, Paypal.uri)
end


Then /^#{relative_job} should be to get an authentication token$/ do |index|
  Then %{the #{index.to_i}th most recent job in the queue should have a name like /GetPaypalAuthenticationTokenJob$/}
end

Then /^#{relative_job} should be to get the authentication details$/ do |index|
  Then %{the #{index.to_i}th most recent job in the queue should have a name like /GetPaypalAuthenticationDetailsJob$/}
end

Then(/^#{capture_model}'s (\w+) (should(?: not)?) be the authentication token$/) do |name, attribute, expectation|
  actual_value  = model(name).send(attribute)
  expectation   = expectation.gsub(' ', '_')
  expected = sample_paypal_authentication_token
  actual_value.to_s.send(expectation, eql(expected))
end

