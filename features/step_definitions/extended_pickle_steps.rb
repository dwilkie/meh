Given(/^no #{capture_plural_factory} exists?(?: with #{capture_fields})?$/) do |plural_factory, fields|
  find_models(plural_factory.singularize, fields).each do |instance|
    instance.destroy
  end
end

Given /^#{capture_model} was already (\w+)$/ do |name, status|
  model!(name).update_attribute("#{status}_at", Time.now)
end

Given /^#{capture_model} is not yet (\w+)$/ do |name, status|
  model!(name).update_attribute("#{status}_at", nil)
end

Given /^#{capture_model} has the following params:$/ do |name, params|
  model_instance = model!(name)
  model_instance.update_attributes!(
    :params => model_instance.params.merge(
      instance_eval(params)
    ).with_indifferent_access
  )
end

When /^#{capture_model} is created(?: with #{capture_fields})?$/ do |name, fields|
  create_model(name, fields)
end

When /^I create #{capture_model}(?: with #{capture_fields})?$/ do |name, fields|
  create_model(name, fields)
end

When /^(?:I|#{capture_model}) (?!create)(\w+) #{capture_model}$/ do |actor, action, name|
  model!(name).send("#{action.singularize}!")
end

When /^I update #{capture_model} with #{capture_fields}$/ do |name, fields|
  model!(name).update_attributes!(parse_fields(fields))
end

Then(/^#{capture_model}s (\w+) (should(?: not)?) be #{capture_value}$/) do |name, attribute, expectation, expected|
  Then "#{name}'s #{attribute} #{expectation} be #{expected}"
end

Then /^#{capture_model} should have the following params:$/ do |name, params|
  model!(name).params.should == instance_eval(params)
end

