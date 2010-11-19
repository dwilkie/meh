require 'devise_paypal/integration_test_helper'

Before("@devise_paypal") do

end

World(DevisePaypal::IntegrationTestHelper)

