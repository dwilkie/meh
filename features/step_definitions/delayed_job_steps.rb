When /^the worker completes its job$/ do
  Delayed::Worker.new.work_off
end

Then /^there should be no jobs in the queue$/ do
  Delayed::Job.count.should == 0
end

