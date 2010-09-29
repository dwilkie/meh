Given /^#{capture_model}'s name is (\d+) characters long$/ do |name, num_chars|
  num_chars = num_chars.to_i
  user_name = ActiveSupport::SecureRandom.base64(num_chars).tr(
    '+/=', '-_ '
  ).strip.delete("\n")
  user = model!(name)
  user.name = user_name
  user.save!
end

Given /^#{capture_model} has (\d+) message credits?$/ do |name, num_credits|
  model_instance = model!(name)
  model_instance.message_credits = num_credits
  model_instance.save!
end

