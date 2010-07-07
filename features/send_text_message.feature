Feature: Send text message
  In order to communicate with users over sms
  I want to be able to send text messages

  Scenario: Send a text message
    Given an outgoing_text_message exists

    Then a job should exist to send the text message

    Given the SMS Gateway will respond with: "OK: 0; Sent queued message ID: 86b1a945370734f4 SMSGlobalMsgID:6942744494999745"

    When the worker completes its job

    Then the outgoing_text_message's gateway_response should be "OK: 0; Sent queued message ID: 86b1a945370734f4 SMSGlobalMsgID:6942744494999745"

