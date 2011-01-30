Given /^the sms gateway is (?:up|down)$/ do
  # This is deliberately blank
end

Given /^there are (not )?enough credits available in the sms gateway$/ do |expectation|
  register_outgoing_text_message_uri(:for_failure => expectation)
end

Given /^a sent outgoing text message for message id: "([^"]*)" exists$/ do |msg_id|
  message_id = ActionSms::Base.sample_message_id(:message_id => msg_id)
  delivery_response = ActionSms::Base.sample_delivery_response_with_message_id(
    msg_id
  )
  Given %{a sent outgoing text message exists with gateway_message_id: "#{message_id}", gateway_response: "#{delivery_response}"}
end

When /^(?:|I )text "([^\"]*)" from "([^\"]*)"$/ do |message, sender|
  params = ActionSms::Base.sample_incoming_sms(
    :message => message,
    :from => sender
  )
  params = { "incoming_text_message" => params }
  post path_to("create incoming text message"), params
  Then "the most recent job in the queue should be to create the incoming text message"
  When "the worker works off the job"
  Then "the job should be deleted from the queue"
end

When /^#{capture_model} permanently fails to send$/ do |name|
  Then %{the most recent job in the queue should be to send the text message}
  When "the worker permanently fails to work off the job"
  Then "the job should be deleted from the queue"
end

When /^a text message delivery receipt is received$/ do
  post path_to("create text message delivery receipt")
end

When /^a text message delivery receipt is received for message id: "([^\"]*)"(?: with the following params: "([^\"]*)")?$/ do |msg_id, receipt_params|
  params = ActionSms::Base.sample_delivery_receipt(
    :message_id => msg_id
  )
  params.merge!(instance_eval(receipt_params)) if receipt_params
  params = { "text_message_delivery_receipt" => params }
  post(
    path_to("create text message delivery receipt"),
    params
  )
  Then "the most recent job in the queue should be to create the text message delivery receipt"
  When "the worker works off the job"
  Then "the job should be deleted from the queue"
end

When /^a? text message delivery receipt is received for message id: "([^\"]*)" with the following params:$/ do |msg_id, message_params|
  When %{a text message delivery receipt is received for message id: "#{msg_id}" with the following params: "#{message_params}"}
end

When /^an incoming text message is received$/ do
  post path_to("create incoming text message")
end

When /^an? (authentic )?text message from "([^\"]*)" is received(?: with the following params: "([^\"]*)")?$/ do |authentic, from, message_params|
  params = ActionSms::Base.sample_incoming_sms(
    :from => from,
    :authentic => !authentic.nil?
  )
  params.merge!(instance_eval(message_params)) if message_params
  params = { "incoming_text_message" => params }
  post(path_to("create incoming text message"), params)
  Then "the most recent job in the queue should be to create the incoming text message"
  When "the worker works off the job"
  Then "the job should be deleted from the queue"
end

When /^an? (authentic )?text message from "([^\"]*)" is received with the following params:$/ do |authentic, from, message_params|
  When %{a #{authentic.to_s}text message from "#{from}" is received with the following params: "#{message_params}"}
end

When /^#{capture_model} (\d+) characters long is created(?: with #{capture_fields})?$/ do |name, num_chars, fields|
  num_chars = num_chars.to_i
  body = ActiveSupport::SecureRandom.hex(num_chars/2)
  body << "A" if num_chars.odd?
  step = "#{name} exists with body: \"#{body}\""
  step << ", #{fields}" if fields
  Given step
end

Then /^#{relative_job} should (not )?be to send the text message$/ do |job_index, expectation|
  Then %{the #{job_index}th most recent job in the queue should #{expectation}have a name like /SendOutgoingTextMessageJob$/}
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

Then /^#{relative_outgoing_text_message} #{capture_model}$/ do |text_message_index, name, mobile_number, expectation, text_message|
  recent_text_message = find_text_message(
    :text_message_index => text_message_index,
    :mobile_number => mobile_number,
    :name => name
  )
  expectation = expectation ? "_not" : ""
  recent_text_message.send("should#{expectation}") == model!(text_message)
end

Then /^#{relative_outgoing_text_message}$/ do |text_message_index, name, mobile_number, expectation, exact_or_includes, translation, expected_text|
   Then %{the #{text_message_index || 1}st most recent #{name} destined for #{mobile_number} should #{expectation}#{exact_or_includes}#{translation} "#{expected_text}"}
end

Then /^#{relative_outgoing_text_message} "([^\"]*)"(?: where #{capture_fields})?$/ do |text_message_index, name, mobile_number, expectation, exact_or_includes, translation, expected_text, fields|
  text_message = find_text_message(
    :text_message_index => text_message_index,
    :mobile_number => mobile_number,
    :text_message => text_message,
    :name => name
  )
  body = text_message.body
  if translation
    fields = parse_fields(fields).symbolize_keys!
    expected_text = translate(expected_text, fields)
    expected_text.should_not include("translation missing")
  end
  expectation = "_not" if expectation
  exact_or_includes == "be" ?
    body.send(
      "should#{expectation}", eql(expected_text)
    ) :
    body.send(
      "should#{expectation}", include(expected_text)
    )
  puts("\n" << body << "\n") if expectation.blank?
end

