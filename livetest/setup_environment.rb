# Usage
# rails runner setup_environment.rb
require File.expand_path(File.dirname(__FILE__) + '/lib/livetest')

def get_name(role)
  default_name = Test::PARAMS["#{role.to_s}_name".to_sym]
  puts "Enter the #{role.to_s.upcase}'S name. Type: 'd' for default: '#{default_name}'"
  response = gets.chomp
  response == "d" ? default_name : response
end

def clear_mobile_numbers?
  puts "Do you want to clear out existing mobile numbers from the db? y/n"
  response = gets.chomp
  response == "y"
end

clear_mobile_numbers = clear_mobile_numbers?
seller_name = get_name(:seller)
supplier_name = get_name(:supplier)

Test.setup(
  :seller_name => seller_name,
  :supplier_name => supplier_name,
  :clear_mobile_numbers => clear_mobile_numbers
)

if clear_mobile_numbers
  require File.expand_path(File.dirname(__FILE__) + '/create_mobile_numbers')
end

puts "*****************************************************************"
puts "\n"
puts "Congratulations! Your development environment is set up for live testing!"
puts "\n"
puts "Push db state to heroku: heroku db:push --remote staging"
puts "\n"
puts "Turn on a worker: heroku workers 1 --remote staging"
puts "\n"
puts "Turn off workers: heroku workers 0 --remote staging"
puts "\n"
puts "Boot the server: rails s"
puts "\n"
puts "Start a worker: rake jobs:work"
puts "\n"
puts "Create mobile numbers: rails runner create_mobile_numbers.rb"
puts "\n"
puts "Simulate a supplier order paypal ipn: curl -d \"#{Test.paypal_ipn_query_string}\" https://meh-notifier-staging.appspot.com/paypal_ipns"
puts "\n"
puts "Simulate an incoming text message: curl -d \"#{Test.incoming_text_message_query_string}\" https://localhost:3000/incoming_text_messages"
puts "\n"
puts "Simulate a masspay ipn: curl -d \"#{Test.masspay_ipn_query_string}\" https://meh-notifier-staging.appspot.com/paypal_ipns"
puts "\n"
puts "*****************************************************************"

