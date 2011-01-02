Given(/^no #{capture_plural_factory} exists?(?: with #{capture_fields})?$/) do |plural_factory, fields|
  find_models(plural_factory.singularize, fields).each do |instance|
    instance.destroy
  end
end

Given /^#{capture_model} (is not yet|was already) (\w+)$/ do |name, status, attribute|
  model_instance = model!(name)
  timestamp = "#{attribute}_at"
  value = (status == "was already") ? Time.now : nil
  model_instance.update_attribute(timestamp, value)
end

Given /^#{capture_model} (?:also )?has the following params:$/ do |name, params|
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
  resource = model!(name)
  fields = parse_fields(fields)
  fields.each do |method, value|
    resource.send("#{method}=", value)
  end
  resource.save!
end

Then(/^#{capture_model}s (\w+) (should(?: not)?) be #{capture_value}$/) do |name, attribute, expectation, expected|
  Then "#{name}'s #{attribute} #{expectation} be #{expected}"
end

Then /^#{capture_model} should (have|include) the following params:$/ do |name, exact, params|
  exact = exact == "have"
  resource_params = model!(name).params
  expected_params = instance_eval(params)
  exact ?
    resource_params.should == expected_params :
    resource_params.should(include(expected_params))
end

Then /^#{capture_model} should (not )?be marked as (\w+)$/ do |name, expectation, predicate|
  expectation = expectation ? "" : "_not"
  model!(name).send("#{predicate}_at").send("should#{expectation}", be_nil)
end

