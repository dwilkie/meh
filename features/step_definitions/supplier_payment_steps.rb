Given /^the seller (has|does not have) sufficient funds to pay the supplier$/ do |expectation|
  body = expectation =~ /has/ ?
  "VERIFIED" :
  "INVALID"
  request_uri = Paypal::Masspay.request_uri
  request_uri.scheme = "https"
  FakeWeb.register_uri(
    :post,
    request_uri.to_s,
    :body => body
  )
end

Then /^the most recent job in the queue should (not )?be to send the supplier payment$/ do |expectation|
  last_job = Delayed::Job.last
  expectation = expectation ? "_not" : ""
  job_name = /^SupplierPayment#pay/
  if last_job
    last_job.name.send("should#{expectation}", match(job_name))
    Then "a job should exist with id: #{last_job.id}"
  end
end

