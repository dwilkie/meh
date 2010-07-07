Given /^the payment request already received a notification$/ do
  payment_request = model!("payment_request")
  payment_request.update_attribute(:notified_at, Time.now)
end

Given /^(?:the worker is about to process its job and send the payment request|the payment request has been sent) to: "([^\"]*)"$/ do |uri|
  FakeWeb.register_uri(
    :post, URI.join(uri, "payment_requests").to_s,
    :status => ["200", "OK"]
  )
end

Given /^the remote application for this payment request (sent|did not send) the notification$/ do |app_sent|
   @notification_verification_response = app_sent == "sent" ? ["200", "OK"] :
     ["404", "Not Found"]
end

Given /^the worker is about to process its job and verify the notification came from the remote application for this payment request$/ do
  payment_request = model!("payment_request")
  uri = URI.join(
    payment_request.application_uri,
    "payment_requests/#{payment_request.remote_id}"
  )
  uri.query = payment_request.notification.to_query
  FakeWeb.register_uri(:head, uri.to_s, :status => @notification_verification_response)
end

Given /^the payment request got the following notification: "([^"]*)"$/ do |notification|
  model!("payment_request").update_attributes!(
    :notification => instance_eval(notification)
  )
end

When /^a payment request verification is made for (\d+)(?: with: "([^\"]*)")?$/ do |id, fields|
  fields = instance_eval(fields) if fields
  @response = head(
    path_to("payment request with id: #{id}"),
    fields
  )
end

When /^a payment request notification (?:is|was) received for (\d+)(?: with: "([^\"]*)")?$/ do |id, fields|
  fields = instance_eval(fields) if fields
  put(
    path_to("payment request with id: #{id}"),
    fields
  )
end

When /^the notification gets verified$/ do
  model!("payment_request").update_attribute(:notification_verified_at, Time.now)
end

Then /^a job should exist to notify my payment application$/ do
  Delayed::Job.last.name.should match(
    /^PaymentRequest::RemotePaymentRequest#create/
  )
end

Then /^a job should (not )?exist to verify it came from the remote application for this payment request$/ do |no_job|
  condition = no_job ? "_not" : ""
  last_job = Delayed::Job.last
  last_job.name.send("should#{condition}", match(
    /^PaymentRequest::RemotePaymentRequest#verify/
  )) if last_job || no_job.blank?
end

Then /^the payment request notification should( not)? be verified$/ do |unverified|
  condition = unverified ? "" : "_not"
  model!("payment_request").notification_verified_at.send("should#{condition}", be_nil)
end

Then /^the response should be (\d+)$/ do |response|
  @response.should == response.to_i
end

