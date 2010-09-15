# Usage
# rails runner create_mobile_numbers.rb
require File.expand_path(File.dirname(__FILE__) + '/lib/livetest')

def create_mobile_number(role)
  default_number = Test::PARAMS["#{role.to_s}_mobile_number".to_sym]
  puts "Enter the #{role.to_s.upcase}'S number or press 'ENTER'. Type: 'd' for default: '#{default_number}'"
  response = gets.chomp
  number = response == "d" ? default_number : response
  number = Test.create_mobile_number(role, String.new(number)) unless number.blank?
end

puts "This script will create mobile numbers which may trigger text messages to be sent. THIS WILL COST MONEY. Type 'yes' to continue..."
response = gets
if response.chomp.downcase == "yes"
  create_mobile_number(:seller)
  create_mobile_number(:supplier)
end

