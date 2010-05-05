When /^a customer purchases a product on ebay with item id: "([^\"]*)"$/ do |ebay_item_id|
  require "rexml/document"
  file = File.new(File.dirname(__FILE__) + '/../support/get_item_transactions.xml')
  document = REXML::Document.new file
  post path_to("create order"), document.to_s, {"Content-type" => "text/xml"}
end
