# Usage
# rails runner setup_environment.rb
require File.expand_path(File.dirname(__FILE__) + '/lib/livetest')
Test.setup
puts "*****************************************************************"
puts "\n"
puts "Congratulations! Your development environment is set up for live testing!"
puts "\n"
puts "Boot the server: rails s"
puts "\n"
puts "Start a worker: rake jobs:work"
puts "\n"
puts "Create mobile numbers: rails runner create_mobile_numbers.rb"
puts "\n"
puts "Simulate a supplier order paypal ipn: curl -d \"#{Test.paypal_ipn_query_string}\" http://localhost:3000/paypal_ipns"
puts "\n"
puts "Simulate an incoming text message: curl -d \"#{Test.incoming_text_message_query_string}\" http://localhost:3000/incoming_text_messages"
puts "\n"
puts "Simulate a masspay ipn: curl -d \"#{Test.masspay_ipn_query_string}\" http://localhost:3000/paypal_ipns"
puts "\n"
puts "*****************************************************************"

