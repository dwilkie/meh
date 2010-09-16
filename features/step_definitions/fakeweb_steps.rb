Then /^the last request should contain #{capture_model} params$/ do |name|
  model_instance = model!(name)
  request_params = Rack::Utils.parse_nested_query(
    FakeWeb.last_request.body
  )
  parsed_model_params = Rack::Utils.parse_nested_query(
    model_instance.params.to_query
  )
  model_name = model_instance.class.to_s.underscore
  request_params = request_params[model_name] || request_params
  request_params.merge(parsed_model_params).should == request_params
end

