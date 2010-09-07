Given /^#{capture_model} has the following message:$/ do |notification, message|
  notification = model!(notification)
  notification.update_attributes!(:message => message)
end

