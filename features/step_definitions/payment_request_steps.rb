# new
Given /^the remote #{capture_model} application(?: is (up|down)| .+)$/ do | payment_name, status |
  uri = model!(
    payment_name
  ).payment_request.remote_payment_application_uri
  http_status = status == "up" ? ["200", "OK"] : ["404", "Not Found"]
  FakeWeb.register_uri(
    :post, URI.join(uri, "payment_requests").to_s,
    :status => http_status
  ) unless status == "down"
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

# new
When /^a verification request is made for an? (non)?existent #{capture_model} with:$/ do |nonexistent, payment_request_name, fields|
  id = nonexistent ? 999 : model!(payment_request_name).id
  fields = instance_eval(fields)
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

# new
Then /^the most recent job in the queue should be to create a remote payment request$/ do
  last_job = Delayed::Job.last
  last_job.name.should match(
    /CreateRemotePaymentRequestJob$/
  )
  Then "a job should exist with id: #{last_job.id}"
end

# new
Then /^the time when the first attempt to contact the remote payment application occurred should be recorded$/ do
  model!("payment request").first_attempt_to_send_to_remote_application_at.should_not be_nil
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

