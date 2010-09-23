Given /^the seller (has|does not have) sufficient funds to pay the supplier$/ do |expectation|
  body = expectation =~ /has/ ?
  "TIMESTAMP=2010%2d09%2d23T01%3a54%3a55Z&CORRELATIONID=afb9f64bb4633&ACK=Success&VERSION=2%2e3&BUILD=1518114" :
  "TIMESTAMP=2010%2d09%2d23T01%3a48%3a24Z&CORRELATIONID=f4bf9617ef440&ACK=Failure&VERSION=2%2e3&BUILD=1518114&L_ERRORCODE0=10321&L_SHORTMESSAGE0=Insufficient%20funds&L_LONGMESSAGE0=The%20account%20does%20not%20have%20sufficient%20funds%20to%20do%20this%20masspay&L_SEVERITYCODE0=Error"
  FakeWeb.register_uri(:post, Paypal.nvp_uri, :body => body)
end

Given /^the seller has not permitted supplier payments$/ do
  body = "TIMESTAMP=2010%2d09%2d23T02%3a09%3a30Z&CORRELATIONID=85290d89bc9de&ACK=Failure&VERSION=2%2e3&BUILD=1518114&L_ERRORCODE0=10002&L_SHORTMESSAGE0=Authentication%2fAuthorization%20Failed&L_LONGMESSAGE0=You%20do%20not%20have%20permissions%20to%20make%20this%20API%20call&L_SEVERITYCODE0=Error"
  FakeWeb.register_uri(:post, Paypal.nvp_uri, :body => body)
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

