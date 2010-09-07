Given /^#{capture_model} is also a (\w+)$/ do |user, role|
  user = model!(user)
  user.new_role = role
  user.save!
end

