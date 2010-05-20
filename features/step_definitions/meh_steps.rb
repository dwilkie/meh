Given /^#{capture_model} is also a (\w+)$/ do |user, role|
  user = model!(user)
  user.new_role = role
  user.save!
end

When(/^#{capture_model} is created(?: with #{capture_fields})?$/) do |name, fields|
  create_model(name, fields)
end

When /^(?:I|the \w+) (\w+) #{capture_model}$/ do |transition, name|
  model!(name).send(transition)
end

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

When /^a customer successfully purchases(?: (\d+) of)? #{capture_model} through paypal$/ do |quantity, product|
  product = model!(product)
  seller = product.seller
  quantity ||= "1"
  params = {
    "mc_gross"=>"54.00",
    "protection_eligibility"=>"Eligible",
    "for_auction"=>"true",
    "address_status"=>"confirmed",
    "item_number1"=>"#{product.external_id}",
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
    "business"=>"#{seller.email}",
    "num_cart_items"=>"1",
    "address_country"=>"United States",
    "address_city"=>"city",
    "quantity"=>"#{quantity}",
    "verify_sign"=>"Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C",
    "payer_email"=>"mehbuy_1272942317_per@gmail.com",
    "txn_id"=>"45D21472YD1820048",
    "payment_type"=>"instant",
    "last_name"=>"User",
    "item_name1"=>"Yet another piece of mank",
    "address_state"=>"WA",
    "receiver_email"=>"#{seller.email}",
    "payment_fee"=>"2.41",
    "quantity1"=>"#{quantity}",
    "insurance_amount"=>"0.00",
    "receiver_id"=>"8AYM8ZN48AARJ",
    "txn_type"=>"web_accept",
    "item_name"=>"Yet another piece of mank",
    "mc_currency"=>"USD",
    "item_number"=>"#{product.external_id}",
    "residence_country"=>"AU",
    "test_ipn"=>"1",
    "transaction_subject"=>"Yet another piece of mank",
    "payment_gross"=>"54.00",
    "shipping"=>"20.00"
  }
  post path_to("create paypal ipn"), params
end


When /^(?:|I )text "([^\"]*)" from "([^\"]*)"$/ do |message, sender|
  params = {
    "to"=>"61447100308",
    "from"=> sender,
    "msg"=> message,
    "userfield"=>"123456",
    "date"=>"2010-05-13 23:59:58"
  }
  post path_to("create incoming text message"), params
end

Then /^a new outgoing text message should be created destined for #{capture_model}$/ do |destination|
  mobile_number = model!(destination)
  outgoing_text_message = OutgoingTextMessage.where(:smsable_id => mobile_number.id).last
  id = outgoing_text_message.nil? ? 0 : outgoing_text_message.id
  Then "an outgoing_text_message should exist with id: \"#{id}\""
end

Then /^#{capture_model} should (be|include)( a translation of)? "([^\"]*)"(?: in "([^\"]*)"(?: \(\w+\))?)?(?: where #{capture_fields})?$/ do |text_message, exact_or_includes, translate, expected_text, language, interpolations|
  text_message = model!(text_message)
  if translate
    i18n_key = translation_key(expected_text)
    language = "en" if language.blank?
    locale = language.to_sym
    interpolations_hash = {:locale => locale}
    if interpolations
      interpolations.split(",").each do |interpolation|
        key_value_pair = interpolation.split(":")
        key_value_pair[0].strip!
        key_value_pair[1].strip!
        key_value_pair[1].gsub!("\"", "")
        interpolations_hash.merge!({key_value_pair[0] => key_value_pair[1]})
      end
    end
    interpolations_hash.symbolize_keys!
    message = I18n.t(i18n_key, interpolations_hash)
  else
    message = expected_text
  end
  if exact_or_includes == "be"
    text_message.message.should == message
  else
    text_message.message.should include(message)
  end
end
