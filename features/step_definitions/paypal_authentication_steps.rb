Given /^I want to sign up with paypal$/ do
  body = "TOKEN=HA%2dH3Y5NAC5XV9LS&TIMESTAMP=2010%2d10%2d04T13%3a11%3a55Z&CORRELATIONID=37ccb34856012&ACK=Success&VERSION=2%2e3&BUILD=1516003"
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri, :body => body
  )
end

Then /^I should be redirected to sign in with paypal$/ do
  # read oauth docs to see how to check the redirect
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

