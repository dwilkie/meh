Given /^the sms gateway is (?:up|down)$/ do
  # This is deliberately blank
end

Given /^there are (not )?enough credits available in the sms gateway$/ do |expectation|
  register_outgoing_text_message_uri(:for_failure => expectation)
end

When /^(?:|I )text "([^\"]*)" from "([^\"]*)"$/ do |message, sender|
  params = {
    "incoming_text_message" => {
      "to"=>"61447100308",
      "from"=> sender,
      "msg"=> message,
      "userfield"=> ENV["SMS_AUTHENTICATION_KEY"],
      "date"=>"2010-05-13 23:59:58"
    }
  }
  post path_to("create incoming text message"), params
  Then "the most recent job in the queue should be to create the incoming text message"
  When "the worker works off the job"
  Then "the job should be deleted from the queue"
end

When /^a text message delivery receipt is received$/ do
  post path_to("create text message delivery receipt")
end

When /^a (duplicate )?text message delivery receipt is received with:$/ do |duplicate, params|
  expectation = duplicate ? " not" : ""
  params = instance_eval(params)
  post(
    path_to("create text message delivery receipt"),
    params
  )
  Then "the most recent job in the queue should be to create the text message delivery receipt"
  When "the worker works off the job"
  Then "the job should#{expectation} be deleted from the queue"
end

When /^an incoming text message is received$/ do
  post path_to("create incoming text message")
end

When /^an (authentic )?((?:but )duplicate )?incoming text message is received with:$/ do |authentic, duplicate, params|
  expectation = duplicate ? " not" : ""
  params = instance_eval(params)
  params["incoming_text_message"].merge!(
    "userfield" => ENV["SMS_AUTHENTICATION_KEY"]
  ) if authentic
  post(path_to("create incoming text message"), params)
  Then "the most recent job in the queue should be to create the incoming text message"
  When "the worker works off the job"
  Then "the job should#{expectation} be deleted from the queue"
end

When /^#{capture_model} (\d+) characters long is created(?: with #{capture_fields})?$/ do |name, num_chars, fields|
  num_chars = num_chars.to_i
  body = ActiveSupport::SecureRandom.hex(num_chars/2)
  body << "A" if num_chars.odd?
  step = "#{name} exists with body: \"#{body}\""
  step << ", #{fields}" if fields
  Given step
end

Then /^(?:the (\d+)?(?:|st |th |nd |rd ))?most recent job in the queue should (not )?be to send the text message$/ do |job_index, expectation|
  job = Delayed::Job.all[-1-job_index.to_i]
  expectation = expectation ? "_not" : ""
  if job
    job.name.send("should#{expectation}", match(/SendOutgoingTextMessageJob$/))
    Then "a job should exist with id: #{job.id}" if expectation.blank?
  end
end

Then /^the most recent job in the queue should be to create the (incoming text message|text message delivery receipt)$/ do |resource|
  job_name = resource == "incoming text message" ?
    /CreateIncomingTextMessageJob$/ :
    /CreateTextMessageDeliveryReceiptJob$/
  last_job = Delayed::Job.last
  last_job.name.should match(job_name)
  Then "a job should exist with id: #{last_job.id}"
end

Then /^a new outgoing text message should be created destined for #{capture_model}$/ do |destination|
  mobile_number = model!(destination)
  outgoing_text_message = mobile_number.outgoing_text_messages.last
  id = outgoing_text_message.nil? ? 0 : outgoing_text_message.id
  Then "an outgoing_text_message should exist with id: \"#{id}\""
end

Then /^(?:the (\d+)?(?:|st |th |nd |rd )?most recent #{capture_model} destined for #{capture_model}|#{capture_model}) should (not )?be$/ do |text_message_index, name, mobile_number, text_message, expectation, expected_text|
  text_message = find_text_message(
    :text_message_index => text_message_index,
    :mobile_number => mobile_number,
    :text_message => text_message,
    :name => name
  )
  expectation = expectation ? "_not" : ""
  text_message.body.send("should#{expectation}") == expected_text
  if expectation.blank?
    puts "\n"
    puts text_message.body
    puts "\n"
  end
end

Then /^the (\d+)?(?:|st |th |nd |rd )?most recent #{capture_model} destined for #{capture_model} should (not )?be #{capture_model}$/ do |text_message_index, name, mobile_number, expectation, text_message|
  recent_text_message = find_text_message(
    :text_message_index => text_message_index,
    :mobile_number => mobile_number,
    :name => name
  )
  expectation = expectation ? "_not" : ""
  recent_text_message.send("should#{expectation}") == model!(text_message)
end

Then /^(?:the (\d+)?(?:|st |th |nd |rd )?most recent #{capture_model} destined for #{capture_model}|#{capture_model}) should (not )?(be|include)( a translation of)? "([^\"]*)"(?: in "([^\"]*)"(?: \(\w+\))?)?(?: where #{capture_fields})?$/ do |text_message_index, name, mobile_number, text_message, expectation, exact_or_includes, translate, expected_text, language, interpolations|
  text_message = find_text_message(
    :text_message_index => text_message_index,
    :mobile_number => mobile_number,
    :text_message => text_message,
    :name => name
  )
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
  if exact_or_includes == "be"
     unless expectation
       text_message.body.should == message
     else
       text_message.body.should_not == message
     end
  else
    unless expectation
      text_message.body.should include(message)
    else
      text_message.body.should_not include(message)
    end
  end
  if expectation.blank?
    puts "\n"
    puts text_message.body
    puts "\n"
  end
end

