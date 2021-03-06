When /^the worker (?:tries (\d+) times to |(permanently) fails to )?works? off #{capture_model}(?: again)?$/ do |attempts, permanent, job|
  job = model!(job)
  attempts ||= 1
  attempts = Delayed::Worker.max_attempts if permanent
  attempts.to_i.times do
    Delayed::Worker.new.run(job)
  end
end

Then /^there should be no jobs in the queue$/ do
  Delayed::Job.count.should == 0
end

Then /^#{capture_model} should be deleted from the queue$/ do |job_name|
  begin
    job = model!(job_name)
  rescue ActiveRecord::RecordNotFound
  end
  job.should be_nil
end

Then /^#{capture_model} should not be deleted from the queue$/ do |job|
  model!(job)
end

Then /^#{relative_job} should (not )?have a name like \/([^\/]*)\/$/ do |job_number, expectation, job_name|
  job_number ||= 1
  job = Delayed::Job.all[0-job_number.to_i]
  expectation = expectation ? "_not" : ""
  if job
    job.name.send("should#{expectation}", match(job_name))
    Then "a job should exist with id: #{job.id}"
  end
end

