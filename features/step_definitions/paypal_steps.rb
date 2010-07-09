When /^a paypal ipn is received with: "([^\"]*)"$/ do |params|
  params = instance_eval(params)
  begin
    post(
      path_to("create paypal ipn"),
      params
    )
  rescue ActiveRecord::RecordInvalid
  end
end

