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

