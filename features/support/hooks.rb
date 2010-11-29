Before do
  FakeWeb.clean_registry
end

Before("@action_sms") do
  if adapter = ENV["ACTION_SMS_ADAPTER"]
    ActionSms::Base.establish_connection(
      :adapter => adapter,
      :environment => Rails.env
    )
    connection = ActionSms::Base.connection
    connection.configuration = connection.configuration.merge(
      connection.sample_configuration(
        :authentication_key => true
      )
    )
  else
    connection = ActionSms::Base.connection
    puts "No SMS Gateway Adapter specified. Assuming \"#{connection.class.to_s}\". If you want to test with another adapter run scenario with 'cucumber/features/ ACTION_SMS_ADAPTER=your_adapter'"
  end
end

Before("@devise_paypal") do
  paypal_response = setup_auth_flow_response
  @token = paypal_response[:token]
  FakeWeb.register_uri(
    :post, Paypal.nvp_uri, :body => paypal_response[:body]
  )
end

