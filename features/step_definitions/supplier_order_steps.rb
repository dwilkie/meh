Given /^#{capture_model} was already (\w+)$/ do |name, status|
  model!(name).update_attribute("#{status}_at", Time.now)
end

Then /^#{capture_model} should be (\w+)$/ do |name, status|
  model!(name).send("#{status}_at").should_not be_nil
end

Then /^#{capture_model} should not be (\w+)$/ do |name, status|
  model!(name).send("#{status}_at").should be_nil
end

