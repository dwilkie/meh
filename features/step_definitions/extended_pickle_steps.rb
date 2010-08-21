Given(/^no #{capture_plural_factory} exists?(?: with #{capture_fields})?$/) do |plural_factory, fields|
  find_models(plural_factory.singularize, fields).each do |instance|
    instance.destroy
  end
end

Given /^#{capture_model} has the following params: "([^\"]*)"$/ do |name, params|
  model_instance = model!(name)
  model_instance.update_attributes!(
    :params => model_instance.params.merge(
      instance_eval(params)
    ).with_indifferent_access
  )
end

When(/^#{capture_model} is created(?: with #{capture_fields})?$/) do |name, fields|
  create_model(name, fields)
end

When /^(?:I|the \w+) (\w+) #{capture_model}$/ do |transition, name|
  model!(name).send(transition.singularize) unless transition == "dreams_about"
end

