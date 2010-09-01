Given /^#{capture_model} was already (\w+)$/ do |name, status|
  model!(name).update_attribute("#{status}_at", Time.now)
end

