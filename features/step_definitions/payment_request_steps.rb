# new
Given /^the remote payment application for #{capture_model} is (up|down)( but)?/ do |payment_request_name, status, exception|
  uri = model!(payment_request_name).remote_payment_application_uri
  http_status = (status == "up" && exception.nil?) ? ["200", "OK"] : ["404", "Not Found"]
  FakeWeb.register_uri(
    :post,
    URI.join(uri, "payment_requests").to_s,
    :status => http_status
  ) unless status == "down"
end

# new
Given /^the remote payment application for #{capture_model} (sent|did not send) the notification (?:(?:and|but) is currently (up|down))$/ do |payment_request_name, genuine, status|
  payment_request = model!(payment_request_name)
  uri = URI.join(
    payment_request.remote_payment_application_uri,
    "payment_requests/#{payment_request.remote_id}"
  )
  uri.query = payment_request.notification.to_query
  http_status = genuine == "sent" ? ["200", "OK"] : ["404", "Not Found"]
  FakeWeb.register_uri(
    :head,
    uri.to_s,
    :status => http_status
  ) unless status == "down"
end

Given /^the payment request got the following notification: "([^"]*)"$/ do |notification|
  model!("payment_request").update_attributes!(
    :notification => instance_eval(notification)
  )
end

# new
When /^a (verification request|notification) (?:is|was) received for an? (non)?existent #{capture_model} with:$/ do |request_type, nonexistent, payment_request_name, fields|
  id = nonexistent ? 999 : model!(payment_request_name).id
  fields = instance_eval(fields)
  request = request_type == "verification request" ? "head" : "put"
  @response = send(
    request,
    path_to("payment request with id: #{id}"),
    fields
  )
end

When /^the notification gets verified$/ do
  model!("payment_request").update_attribute(:notification_verified_at, Time.now)
end

# new
Then /^the most recent job in the queue should (not )?be to (create|verify).+payment request$/ do |expectation, action|
  expectation = expectation ? "_not" : ""
  job_name = action.split.first == "create" ? /CreateRemotePaymentRequestJob$/ :
    /VerifyRemotePaymentRequestNotificationJob$/
  last_job = Delayed::Job.last
  last_job.name.send("should#{expectation}", match(job_name))
  Then "a job should exist with id: #{last_job.id}" if expectation.blank?
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

Then /^the response should be (\d+)$/ do |response|
  @response.should == response.to_i
end

