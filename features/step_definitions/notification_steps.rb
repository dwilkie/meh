Given /^#{capture_model} message includes all available attributes for #{capture_model}$/ do |name, event_object|
  attributes = Notification::EVENTS[model!(name).event]

end

