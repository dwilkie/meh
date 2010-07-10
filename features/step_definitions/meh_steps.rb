Given /^#{capture_model} is also a (\w+)$/ do |user, role|
  user = model!(user)
  user.new_role = role
  user.save!
end

Given /^there is a payment agreement set to (\w+)(?: and to trigger when an order is (\w+))?(?: with #{capture_fields})?$/ do |payment_method, payment_trigger_on_order, fields|
  automatic = payment_method == "automatic"
  new_fields = "automatic: #{automatic}"
  new_fields = new_fields << ", payment_trigger_on_order: \"#{payment_trigger_on_order}\"" if payment_trigger_on_order
  new_fields = new_fields << ", " << fields if fields
  Given "a payment_agreement exists with #{new_fields}"
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
    "quantity"=>"#{quantity}", "verify_sign"=>"Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C",
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

