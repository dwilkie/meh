Given /^the url(?: does not (have|resolve).*| resolves to a valid #{capture_model})$/ do |status, name|
  if name || status == "have"
    if name
      uri = model!(name).uri
      http_status = ["200", "OK"]
    else
      uri = "http://example.com"
      http_status = ["404", "Not Found"]
    end
    uri = URI.join(uri, "payment_requests").to_s
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

