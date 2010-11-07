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
    if connection = ActionSms::Base.connection
      puts "No SMS Gateway Adapter specified. Assuming \"#{connection.class.to_s}\". If you want to test with another adapter run scenario with 'cucumber/features/ ACTION_SMS_ADAPTER=\"your_adapter\"'"
    end
  end
end

