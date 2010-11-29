# see also http://github.com/dwilkie/action_sms
# for more configuration options and details on how to make your own adapter

# Built In Adapters

## Sms Global

# ActionSms::Base.establish_connection(
#   :adapter => "sms_global",
#   :user => ENV['SMS_GLOBAL_USER'],
#   :password => ENV['SMS_GLOBAL_PASSWORD'],
#   :authentication_key => ENV['SMS_AUTHENTICATION_KEY'],
#   :use_ssl => true,
#   :environment => Rails.env
# )

## Tropo

ActionSms::Base.establish_connection(
  :adapter => "tropo",
  :outgoing_token => ENV['TROPO_OUTGOING_TOKEN'],
  :authentication_key => ENV['SMS_AUTHENTICATION_KEY'],
  :use_ssl => true,
  :environment => Rails.env
)

# Custom Adapters

# ActionSms::Base.establish_connection(
#   :adapter => "your_adapter"
#   # adapter specific configuration...
# )

# Incoming Message Authentication

# Using an authentication key in conjunction with a secure connection helps protect you against someone faking incoming messages to your server.

# ActionSms::Base.establish_connection(
#   :use_ssl => true,
#   :authentication_key => "my_secret"
# )

# Testing

# Setting: `:environment => "test"` gives you get some additional test helpers useful for testing

# ActionSms::Base.establish_connection(
#   :environment => "test"
# )

