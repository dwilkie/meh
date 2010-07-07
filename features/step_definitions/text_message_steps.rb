Given /^the SMS Gateway will respond with: "([^\"]*)"$/ do |body|
  register_outgoing_text_message_uri(:body => body)
end

When /^(?:|I )text "([^\"]*)" from "([^\"]*)"$/ do |message, sender|
  params = {
    "incoming_text_message" => {
      "to"=>"61447100308",
      "from"=> sender,
      "msg"=> message,
      "userfield"=>"123456",
      "date"=>"2010-05-13 23:59:58"
    }
  }
  post path_to("create incoming text message"), params
end

Then /^a job should exist to send the text message$/ do
  Delayed::Job.last.name.should match(/^OutgoingTextMessage#send_message/)
end

Then /^a new outgoing text message should be created destined for #{capture_model}$/ do |destination|
  mobile_number = model!(destination)
  outgoing_text_message = OutgoingTextMessage.where(:smsable_id => mobile_number.id).last
  id = outgoing_text_message.nil? ? 0 : outgoing_text_message.id
  Then "an outgoing_text_message should exist with id: \"#{id}\""
  register_outgoing_text_message_uri
  When "the worker completes its job"
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
  text_message.body.should_not include("translation missing")
  puts "\n"
  puts text_message.body
  puts "\n"
  if exact_or_includes == "be"
     unless reverse
       text_message.body.should == message
     else
       text_message.body.should_not == message
     end
  else
    unless reverse
      text_message.body.should include(message)
    else
      text_message.body.should_not include(message)
    end
  end
end

