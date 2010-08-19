Given /^#{capture_model} message includes all available attributes$/ do |name|
  notification = model!(name)
  notification_attributes = Notification::EVENTS[notification.event.to_sym][:notification_attributes]
  message = ""
  notification_attributes.keys.each do |attribute_name|
    message << " " << "<" << attribute_name.to_s << ">"
  end
  notification.update_attributes!(:message => message.strip)
end

