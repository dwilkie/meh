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

When /^the paypal ipn is verified$/ do
  model!("paypal_ipn").update_attributes!(:verified_at => Time.now)
end

Then /^the most recent job in the queue should be to verify the paypal ipn$/ do
  last_job = Delayed::Job.last
  last_job.name.should match(
    /^PaypalIpn#verify/
  )
  Then "a job should exist with id: #{last_job.id}"
end

