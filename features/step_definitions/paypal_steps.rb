Given /^paypal (did not send|sent) the IPN$/ do |fraudulent|
  body = fraudulent =~ /sent/ ? "VERIFIED" : "INVALID"
  FakeWeb.register_uri(
    :post, Paypal::Ipn.postback_uri, :body => body
  )
end

Given /^the paypal ipn's payment status is: "([^\"]*)"$/ do |payment_status|
  paypal_ipn = model!("paypal_ipn")
  paypal_ipn.update_attribute(:payment_status, payment_status)
end

When /^a paypal ipn is received$/ do
  post path_to("create paypal ipn")
end

When /^a paypal ipn is received with:$/ do |params|
  params = instance_eval(params)
  post(path_to("create paypal ipn"), params)
  Then "the most recent job in the queue should be to create the paypal ipn"
  When "the worker works off the job"
  Then "the job should be deleted from the queue"
end

When /^the #{capture_model} is verified$/ do |name|
  model!(name).update_attributes!(:verified_at => Time.now)
end

Then /^(?:the (\d+)?(?:|st |th |nd |rd ))?most recent job in the queue should (not )?be to (create|verify) the paypal ipn$/ do |job_number, expectation, action|
  job = Delayed::Job.all[-1-job_number.to_i]
  expectation = expectation ? "_not" : ""
  job_name = action == "create" ? /CreatePaypalIpnJob$/ : /PaypalIpn#verify/
  if job
    job.name.send("should#{expectation}", match(job_name))
    Then "a job should exist with id: #{job.id}"
  end
end

