# Simulates an incoming text message
require File.expand_path(File.dirname(__FILE__) + '/lib/livetest')
puts "Enter your text message and press 'ENTER'"
message = gets.chomp
default_seller_number = Test::PARAMS["seller_mobile_number".to_sym]
default_supplier_number = Test::PARAMS["seller_mobile_number".to_sym]
puts "Enter the number to send from: Type: '1' for: '#{default_seller_number}' or '2' for: #{default_supplier_number}"
number = gets.chomp
case number
  when '1'
    number = default_seller_number
  when '2'
    number = default_supplier_number
end
#exec("curl", "-D "

