Given /^I want to sign up with paypal$/ do
  body = "TOKEN=HA%2dH3Y5NAC5XV9LS&TIMESTAMP=2010%2d10%2d04T13%3a11%3a55Z&CORRELATIONID=37ccb34856012&ACK=Success&VERSION=2%2e3&BUILD=1516003"
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri, :body => body
  )
end

Given /^I have a paypal account(?: with #{capture_fields})?$/ do |fields|
  body_template = "PAYERID=RK7XZT4AUY79C&TIMESTAMP=2010%2d10%2d07T10%3a08%3a44Z&CORRELATIONID=83dfe25684ced&ACK=Success&VERSION=2%2e3&BUILD=1545724"
  paypal_credentials = parse_fields(fields)
  parsed_paypal_credentials = {}
  paypal_credentials.each do |key, value|
    parsed_paypal_credentials[key.classify.upcase] = value
  end
  paypal_credentials = parsed_paypal_credentials
  paypal_response = Rack::Utils.parse_nested_query(body_template)
  paypal_response.merge!(paypal_credentials)
  response_body = Rack::Utils.build_nested_query(paypal_response)
  paypal_credentials = parse_fields(fields)
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri, :body => response_body
  )
end

Given /^I sign into paypal and grant the required permissions$/ do
  # this step is intentionally blank
end

When /^I am redirected back to the application from paypal$/ do
  When "I go to the paypal permissions callback page"
end

Then /^I should be redirected to sign in with paypal$/ do
  Then %{I should be at "#{Paypal.uri}"}
  Then %{I should have the following query string:}, table(%{
    | _cmd  | _access-permission-login |
    | token | HA-H3Y5NAC5XV9LS         |
  })
end

Then /^permission should be requested to grant access to the masspay api$/ do
  request_body = Rack::Utils.parse_nested_query(FakeWeb.last_request.body)
  permission_key = "L_REQUIREDACCESSPERMISSIONS"
  i = 0
  begin
    permission = request_body[permission_key + i.to_s]
    i += 1
  end until permission.nil? || permission == "MassPay"
  permission.should == "MassPay"
end

