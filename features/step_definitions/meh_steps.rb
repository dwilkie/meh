Given /^#{capture_model} has an (\w+) payment application(?: with #{capture_fields})?$/ do |seller, application_status, fields|
  pickle_step = "a payment_application exists with seller: #{seller}, status: \"#{application_status}\""
  pickle_step << ", #{fields}" if fields
  Given pickle_step
  payment_application = model!("payment_application")
  FakeWeb.register_uri(
    :post,
    URI.join(
      payment_application.uri,
      "payment_requests"
    ).to_s,
  :status => ["200", "OK"]
  ) if application_status == "active"
end

Given(/^no #{capture_plural_factory} exists?(?: with #{capture_fields})?$/) do |plural_factory, fields|
  find_models(plural_factory.singularize, fields).each do |instance|
    instance.destroy
  end
end

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

When(/^#{capture_model} is created(?: with #{capture_fields})?$/) do |name, fields|
  create_model(name, fields)
end

When /^(?:I|the \w+) (\w+) #{capture_model}$/ do |transition, name|
  model!(name).send(transition.singularize)
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

When /^a payment request verification is made for (\d+)(?: with #{capture_fields})?$/ do |id, fields|
  @response = head(
    path_to("get payment request with id: #{id}"),
    parse_fields(fields)
  )
end

Then /^a new outgoing text message should be created destined for #{capture_model}$/ do |destination|
  mobile_number = model!(destination)
  outgoing_text_message = OutgoingTextMessage.where(:smsable_id => mobile_number.id).last
  id = outgoing_text_message.nil? ? 0 : outgoing_text_message.id
  Then "an outgoing_text_message should exist with id: \"#{id}\""
end

Then /^#{capture_model} should (not )?(be|include)( a translation of)? "([^\"]*)"(?: in "([^\"]*)"(?: \(\w+\))?)?(?: where #{capture_fields})?$/ do |text_message, reverse, exact_or_includes, translate, expected_text, language, interpolations|
  text_message = model!(text_message)
  if translate
    i18n_key = translation_key(expected_text)
    language = "en" if language.blank?
    locale = language.to_sym
    interpolations_hash = parse_fields(interpolations)
    interpolations_hash.merge!({:locale => locale})
    interpolations_hash.symbolize_keys!
    message = I18n.t(i18n_key, interpolations_hash)
    message.should_not include("translation missing")
  else
    message = expected_text
  end
  text_message.message.should_not include("translation missing")
  puts "\n"
  puts text_message.message
  puts "\n"
  if exact_or_includes == "be"
     unless reverse
       text_message.message.should == message
     else
       text_message.message.should_not == message
     end
  else
    unless reverse
      text_message.message.should include(message)
    else
      text_message.message.should_not include(message)
    end
  end
end

Then /^there should be no more than (\d+) outgoing text messages? destined for #{capture_model}$/ do |count, destination|
  mobile_number = model!(destination)
  OutgoingTextMessage.where(:smsable_id => mobile_number.id, :smsable_type => "mobile_number").count.should <= count.to_i
end

Then /^the response should be (\d+)$/ do |response|
   @response.should == response.to_i
end

