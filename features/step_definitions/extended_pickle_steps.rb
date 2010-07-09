Given /^#{capture_model} has the following params: "([^\"]*)"$/ do |name, params|
  model_instance = model!(name).update_attributes!(
    :params => instance_eval(params).with_indifferent_access
  )
end

