Given /^the remote payment application for #{capture_model} is (up|down)( but)?/ do |payment_request_name, status, exception|
  uri = model!(payment_request_name).payment_application.payment_request_uri
  http_status = (status == "up" && exception.nil?) ? ["200", "OK"] : ["404", "Not Found"]
  FakeWeb.register_uri(
    :post,
    uri,
    :status => http_status
  ) unless status == "down"
end

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

When /^a notification is received for #{capture_model}$/ do |name|
  put(path_to("payment request with id: #{model!(name).id}"))
end

When /^a (verification request|notification) (?:is|was) received for an? (non)?existent #{capture_model} with:$/ do |request_type, nonexistent, payment_request_name, fields|
  id = nonexistent ? 999 : model!(payment_request_name).id
  fields = instance_eval(fields)
  request = request_type == "verification request" ? "head" : "put"
  @response = send(
    request,
    path_to("payment request with id: #{id}"),
    fields
  )
  if request == "put"
    Then "the most recent job in the queue should be to notify the payment request"
    When "the worker works off the job"
    Then "the job should be deleted from the queue"
  end
end

Then /^the most recent job in the queue should (not )?be to (create|verify|notify).+payment request$/ do |expectation, action|
  expectation = expectation ? "_not" : ""
  case action
    when "create"
      job_name = /CreateRemotePaymentRequestJob$/
    when "verify"
      job_name = /VerifyRemotePaymentRequestNotificationJob$/
    when "notify"
      job_name = /NotifyPaymentRequestJob$/
  end
  last_job = Delayed::Job.last
  last_job.name.send("should#{expectation}", match(job_name))
  Then "a job should exist with id: #{last_job.id}" if expectation.blank?
end

Then /^the time when the first attempt to contact the remote payment application occurred should be recorded$/ do
  model!("payment request").first_attempt_to_send_to_remote_application_at.should_not be_nil
end

Then /^the response should be (\d+)$/ do |response|
  @response.should == response.to_i
end

