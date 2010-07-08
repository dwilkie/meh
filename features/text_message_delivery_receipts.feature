Feature: Text message delivery receipts
  In order to keep track of the status of outgoing text messages
  I want to be notified with delivery receipts when outgoing text messages are delivered or failed to be delivered

  Scenario: A text message delivery receipt is received for an existing outgoing text message
    Given an outgoing_text_message exists
    And the SMS Gateway will respond with: "OK: 0; Sent queued message ID: 86b1a945370734f4 SMSGlobalMsgID:6942744494999745"
    And the worker completes its job

    When a text message delivery receipt is received with: "{'text_message_delivery_receipt'=>{'msgid'=>'6942744494999745', 'dlrstatus'=>'DELIVRD', 'dlr_err'=>'000', 'donedate'=>'1005132312'}}"

    Then a text_message_delivery_receipt should exist with outgoing_text_message_id: the outgoing_text_message, status: "DELIVRD"

