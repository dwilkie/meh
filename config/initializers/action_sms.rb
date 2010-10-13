# see http://github.com/dwilkie/action_sms_gateways
# for preconfigured sms gateways and more details on how to make your own adapter

# Then uncomment the following code and replace :adapter with your adapter

ActionSms::Base.establish_connection(
  :adapter => "sms_global",
  :user => ENV['SMS_GLOBAL_USER'],
  :password => ENV['SMS_GLOBAL_PASSWORD'],
  :authentication_key => ENV['SMS_AUTHENTICATION_KEY'],
  :use_ssl => true,
  :environment => Rails.env
)

