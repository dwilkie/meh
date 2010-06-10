Given /^the payment request is answered$/ do
  payment_request = model!("payment_request")
  payment_request.answered_at = Time.now
  payment_request.save!
end

Given /^the worker is about to process its job and send the payment request to "([^\"]*)"$/ do |uri|
  FakeWeb.register_uri(:post, URI.join(uri, "payment_requests").to_s, :status => ["200", "OK"])
end

When /^a payment request verification is made for (\d+)(?: with: "([^\"]*)")?$/ do |id, fields|
  fields = instance_eval(fields) if fields
  @response = head(
    path_to("payment request with id: #{id}"),
    fields
  )
end

When /^a payment request notification is received for (\d+)(?: with: "([^\"]*)")?$/ do |id, fields|
  fields = instance_eval(fields) if fields
  put(
    path_to("payment request with id: #{id}"),
    fields
  )
end

Then /^a job should exist to notify my payment application$/ do
  Delayed::Job.last.name.should match(
    /^PaymentRequest::RemotePaymentRequest#create/
  )
end

Then /^a job should exist to verify it came from my payment application$/ do
  Delayed::Job.last.name.should match(
    /^PaymentRequest::RemotePaymentRequest#verified?/
  )
end

Then /^the payment request should have been sent$/ do
  # this step is intentionally blank
end

