Given /^I am logged in with #{capture_fields}$/ do |fields|
  Given %{a seller exists with #{fields}}
  user = model!("the seller")
  password = parse_fields(fields)["password"]
  And %{I am on the login page}
  And %{I fill in "Email" with "#{user.email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Sign in"}
  Then %{I should be on the overview page}
end

Given /^I am not logged in$/ do
  # intentionally blank
end

Given /^I signed up(?: with #{capture_fields})?$/ do |fields|
  mobile_number = parse_fields(fields)["mobile_number"] || "+121244411221"
  Given %{I am on the signup page}
  And %{I fill in "Mobile Number" with "#{mobile_number}"}
  When %{I press "Sign Up"}
  Then %{a paypal authentication should exist}
end

