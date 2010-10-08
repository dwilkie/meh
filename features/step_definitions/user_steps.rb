Given /^#{capture_model}'s name is (\d+) characters long$/ do |name, num_chars|
  num_chars = num_chars.to_i
  user_name = ActiveSupport::SecureRandom.hex(num_chars/2)
  user_name << "A" if num_chars.odd?
  user = model!(name)
  user.name = user_name
  user.save!
end

Given /^#{capture_model} has (\-?\d+) message credits?$/ do |name, num_credits|
  model_instance = model!(name)
  model_instance.message_credits = num_credits
  model_instance.save!
end

Given /^#{capture_model} is also a (\w+)$/ do |user, role|
  user = model!(user)
  user.new_role = role
  user.save!
end

Then(/^"([^"]*)" should be (?:in|one of|amongst) #{capture_model}(?:'s)? (\w+)$/) do |target, owner, association|
  model!(owner).send(association).should include(target)
end

