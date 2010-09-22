Paypal.setup do |config|
  config.environment = Rails.env.production? ? "live" : "sandbox"
  config.api_username = ENV['PAYPAL_API_USERNAME']
  config.api_password = ENV['PAYPAL_API_PASSWORD']
  config.api_signature = ENV['PAYPAL_API_SIGNATURE']
end

