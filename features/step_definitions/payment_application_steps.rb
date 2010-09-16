Given /^the url( does not)? resolves?(?: to a valid #{capture_model})?$/ do |expectation, name|
  if name
    uri = model!(name).payment_request_uri
    http_status = expectation ? ["404", "Not Found"] : ["200", "OK"]
    FakeWeb.register_uri(:post, uri, :status => http_status)
  end
end

Then /^(?:the (\d+)?(?:|st |th |nd |rd ))?most recent job in the queue should be to verify the payment application$/ do |index|
  if index
    jobs = Delayed::Job.all
    job = jobs[jobs.size - index.to_i]
  else
    job = Delayed::Job.last
  end
  job.name.should match(/VerifyPaymentApplicationJob$/)
  Then "a job should exist with id: #{job.id}"
end

