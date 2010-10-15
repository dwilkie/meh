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

def test_locally?
  puts "Are you testing on your development machine? y/n"
  response = gets.chomp
  response == "y"
end

test_locally = test_locally?
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
if test_locally
  host = "http://localhost:3000"
  puts "Boot the server: rails s"
  puts "\n"
  puts "Start a worker: rake jobs:work"
  puts "\n"
  puts "Simulate an incoming text message: curl -d \"#{Test.incoming_text_message_query_string(:normalized => test_locally)}\" #{host}/incoming_text_messages"
  puts "\n"
  puts "Simulate a masspay ipn: curl -d \"#{Test.masspay_ipn_query_string(:normalized => test_locally)}\" #{host}/paypal_ipns"
else
  host = "https://meh-notifier-staging.appspot.com"
  puts "Push db state to heroku: heroku db:push --remote staging"
  puts "\n"
  puts "Turn on a worker: heroku workers 1 --remote staging"
  puts "\n"
  puts "Turn off workers: heroku workers 0 --remote staging"
end
puts "\n"
puts "Simulate a supplier order paypal ipn: curl -d \"#{Test.paypal_ipn_query_string(:normalized => test_locally)}\" #{host}/paypal_ipns"
puts "\n"
puts "*****************************************************************"

