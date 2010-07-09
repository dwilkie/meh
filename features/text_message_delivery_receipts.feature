Feature: Text message delivery receipts
  In order to keep track of the status of outgoing text messages
  I want to be notified with delivery receipts when outgoing text messages are delivered or fail to be delivered

  Scenario: A text message delivery receipt is received for an existing outgoing text message
    Given an outgoing_text_message exists
    And the SMS Gateway will respond with: "OK: 0; Sent queued message ID: 86b1a945370734f4 SMSGlobalMsgID:6942744494999745"
    And the worker completes its job

    When a text message delivery receipt is received with: "{'text_message_delivery_receipt'=>{'msgid'=>'6942744494999745', 'dlrstatus'=>'DELIVRD', 'dlr_err'=>'000', 'donedate'=>'1005132312'}}"

    Then a text_message_delivery_receipt should exist with outgoing_text_message_id: the outgoing_text_message, status: "DELIVRD"

  Scenario: A text message delivery receipt is received for a non existing outgoing text message
    When a text message delivery receipt is received with: "{'text_message_delivery_receipt'=>{'msgid'=>'6942744494999745', 'dlrstatus'=>'DELIVRD', 'dlr_err'=>'000', 'donedate'=>'1005132312'}}"

    Then a text_message_delivery_receipt should not exist

  Scenario: A duplicate text message delivery receipt is received
    Given a sent_outgoing_text_message exists with gateway_message_id: "SMSGlobalMsgID:6942744494999745"
    And a text_message_delivery_receipt exists with outgoing_text_message: the sent_outgoing_text_message
    And the text_message_delivery_receipt has the following params: "{'msgid'=>'6942744494999745', 'dlrstatus'=>'DELIVRD', 'dlr_err'=>'000', 'donedate'=>'1005132312'}"

    When a text message delivery receipt is received with: "{'text_message_delivery_receipt'=>{'msgid'=>'6942744494999745', 'dlrstatus'=>'DELIVRD', 'dlr_err'=>'000', 'donedate'=>'1005132312'}}"

    Then 1 text_message_delivery_receipts should exist

