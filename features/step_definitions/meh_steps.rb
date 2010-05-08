When /^a customer purchases a product on ebay from #{capture_model} with item id: "([^\"]*)"$/ do |seller, ebay_item_id|
  require "rexml/document"
  GET_ITEM_TRANSACTIONS_FILE = File.dirname(__FILE__) +
                               '/../support/get_item_transactions.xml.original'

  seller_email = model!(seller).email

  modified_file_name = GET_ITEM_TRANSACTIONS_FILE.gsub(/\.original/, "")

  FileUtils.copy GET_ITEM_TRANSACTIONS_FILE, modified_file_name

  # this is a bit of a hack because it requires unique fields in the xml
  File.open(modified_file_name, 'r+') do |f|
    out = ""
    f.each do |line|
      # modifies the paypal email address
      replaced_line = line.gsub(/\<PaypalEmailAddress\>\w+\<\/PaypalEmailAddress\>/, "<PaypalEmailAddress>#{seller_email}</PaypalEmailAddress>")
      # modifies the item id
      replaced_line = line.gsub(/\<ItemID\>\d+\<\/ItemID\>/, "<ItemID>#{ebay_item_id}</ItemID>")
      out << replaced_line
    end
    f.pos = 0
    f.print out
    f.truncate(f.pos)
  end

  document = nil
  File.open(modified_file_name, "r") do |current_file|
    document = REXML::Document.new current_file
  end
  post path_to("create order"), document.to_s, {"Content-type" => "text/xml"}
end


When /^a buyer successfully purchases the product through paypal with external_id: "([^\"]*)"$/ do |external_id|
  params = {
    "mc_gross"=>"54.00",
    "protection_eligibility"=>"Eligible",
    "for_auction"=>"true",
    "address_status"=>"confirmed",
    "item_number1"=>"110045294536",
    "payer_id"=>"T23XXY2DVKA6J",
    "tax"=>"0.00",
    "address_street"=>"address",
    "payment_date"=>"08:30:40 May 06, 2010 PDT",
    "payment_status"=>"Completed",
    "charset"=>"windows-1252",
    "auction_closing_date"=>"08:27:08 Jun 05, 2010 PDT",
    "address_zip"=>"98102",
    "first_name"=>"Test",
    "auction_buyer_id"=>"testuser_mehbuyer",
    "mc_fee"=>"2.41",
    "address_country_code"=>"US",
    "address_name"=>"Test User",
    "notify_version"=>"2.9",
    "custom"=>"",
    "payer_status"=>"verified",
    "business"=>"mehsel_1273155831_biz@gmail.com",
    "num_cart_items"=>"1",
    "address_country"=>"United States",
    "address_city"=>"city",
    "quantity"=>"1",
    "verify_sign"=>"Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C",
    "payer_email"=>"mehbuy_1272942317_per@gmail.com",
    "txn_id"=>"45D21472YD1820048",
    "payment_type"=>"instant",
    "last_name"=>"User",
    "item_name1"=>"Yet another piece of mank",
    "address_state"=>"WA",
    "receiver_email"=>"mehsel_1273155831_biz@gmail.com",
    "payment_fee"=>"2.41",
    "quantity1"=>"1",
    "insurance_amount"=>"0.00",
    "receiver_id"=>"8AYM8ZN48AARJ",
    "txn_type"=>"web_accept",
    "item_name"=>"Yet another piece of mank",
    "mc_currency"=>"USD",
    "item_number"=>"110045294536",
    "residence_country"=>"AU",
    "test_ipn"=>"1",
    "transaction_subject"=>"Yet another piece of mank",
    "payment_gross"=>"54.00",
    "shipping"=>"20.00"
  }
  params["item_number"] = external_id
  post path_to("create paypal ipn"), params
end

