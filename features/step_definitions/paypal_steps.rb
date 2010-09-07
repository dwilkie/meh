Given /^paypal (did not send|sent) the IPN$/ do |fraudulent|
  body = fraudulent =~ /sent/ ? "VERIFIED" : "INVALID"
  request_uri = URI.parse(APP_CONFIG["paypal_ipn_postback_uri"])
  request_uri.scheme = "https"
  FakeWeb.register_uri(
    :post,
    request_uri.to_s,
    :body => body
  )
end

Given /^the paypal ipn's payment status is: "([^\"]*)"$/ do |payment_status|
  paypal_ipn = model!("paypal_ipn")
  paypal_ipn.update_attribute(:payment_status, payment_status)
end

When /^a paypal ipn is received with:$/ do |params|
  params = instance_eval(params)
  begin
    post(
      path_to("create paypal ipn"),
      params
    )
  rescue ActiveRecord::RecordInvalid
  end
end

When /^the paypal_ipn is verified$/ do
  model!("paypal_ipn").update_attributes!(:verified_at => Time.now)
end

Then /^a job should exist to verify the ipn came from paypal$/ do
  Delayed::Job.last.name.should match(
    /^PaypalIpn#verify/
  )
end

Then /^the paypal_ipn should (not )?be marked as verified$/ do |unverified|
  condition = unverified ? "" : "_not"
  model!("paypal_ipn").verified_at.send("should#{condition}", be_nil)
end

