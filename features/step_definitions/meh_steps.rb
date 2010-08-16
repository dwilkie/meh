Given /^#{capture_model} is also a (\w+)$/ do |user, role|
  user = model!(user)
  user.new_role = role
  user.save!
end

Given /^there is a payment agreement set to (\w+)(?: and to trigger when an order is (\w+))?(?: with #{capture_fields})?$/ do |payment_method, payment_trigger_on_order, fields|
  automatic = payment_method == "automatic"
  new_fields = "automatic: #{automatic}"
  new_fields = new_fields << ", payment_trigger_on_order: \"#{payment_trigger_on_order}\"" if payment_trigger_on_order
  new_fields = new_fields << ", " << fields if fields
  Given "a payment_agreement exists with #{new_fields}"
end

