Given /^paypal sent the IPN$/ do
  request_uri = URI.parse(APP_CONFIG["paypal_ipn_postback_uri"])
  request_uri.scheme = "https"
  FakeWeb.register_uri(
    :post,
    request_uri.to_s,
    :body => "VERIFIED"
  )
end

When /^a paypal ipn is received with: "([^\"]*)"$/ do |params|
  params = instance_eval(params)
  begin
    post(
      path_to("create paypal ipn"),
      params
    )
  rescue ActiveRecord::RecordInvalid
  end
end

Then /^a job should exist to verify the ipn came from paypal$/ do
  Delayed::Job.last.name.should match(
    /^PaypalIpn#verify/
  )
end

Then /^the paypal_ipn should (not)?be marked as verified$/ do |unverified|
  condition = unverified ? "" : "_not"
  model!("paypal_ipn").verified_at.send("should#{condition}", be_nil)
end

