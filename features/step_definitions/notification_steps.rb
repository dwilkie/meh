Given /^#{capture_model} message includes all available attributes$/ do |name|
  notification = model!(name)
  notification_attributes = Notification::EVENTS[notification.event.to_sym][:notification_attributes]
  message = ""
  notification_attributes.keys.each do |attribute_name|
    message << " " << "<" << attribute_name.to_s << ">"
  end
  notification.update_attributes!(:message => message.strip)
end

Given /^#{capture_model} should have a message which is a translation of: "([^\"]*)"(?: in "([^\"]*)"(?: \(\w+\))?)?(?: where #{capture_fields})?$/ do |notification, expected_text, language, interpolations|
  notification = model!(notification)
  i18n_key = translation_key(expected_text)
  language = "en" if language.blank?
  locale = language.to_sym
  interpolations_hash = parse_fields(interpolations)
  interpolations_hash.merge!({:locale => locale})
  interpolations_hash.symbolize_keys!
  message = I18n.t(i18n_key, interpolations_hash)
  message.should_not include("translation missing")
  notification.message.should_not include("translation missing")
  notification.message.should == message
end

