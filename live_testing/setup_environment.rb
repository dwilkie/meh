# Usage
# rails runner setup_environment.rb
require File.expand_path(File.dirname(__FILE__) + '/live_testing')
puts "This script will help you simulate some live tests. The tests may trigger text messages to be sent which WILL COST MONEY. Type yes to continue"
response = gets
if response.chomp.downcase == "yes" && Test.setup
  puts "*****************************************************************"
  puts "Congratulations! Your development environment is set up for live testing!"
  puts "\n"
  puts "Boot the server: rails s"
  puts "\n"
  puts "Start a worker: rake jobs:work"
  puts "\n"
  puts "Simulate a paypal ipn: curl -d \"#{Test.paypal_ipn_query_string}\" http://localhost:3000/paypal_ipns"
  puts "\n"
  puts "*****************************************************************"
end

