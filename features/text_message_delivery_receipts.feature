Feature: Text message delivery receipts
  In order to keep track of the status of outgoing text messages
  I want to be notified with delivery receipts when outgoing text messages are delivered or fail to be delivered

  Scenario: A text message delivery receipt is received
    When a text message delivery receipt is received
    Then the most recent job in the queue should be to create the text message delivery receipt

  Scenario: A text message delivery receipt is received for an existing outgoing text message
    Given a sent outgoing text_message exists with gateway_message_id: "SMSGlobalMsgID:6942744494999745"

    When a text message delivery receipt is received with:
    """
    {
      'text_message_delivery_receipt' => {
        'msgid'=>'6942744494999745',
        'dlrstatus'=>'DELIVRD',
        'dlr_err'=>'000',
        'donedate'=>'1005132312'
      }
    }
    """

    Then a text message delivery receipt should exist with outgoing_text_message_id: the outgoing text message, status: "DELIVRD"

  Scenario: A text message delivery receipt is received for a non existing outgoing text message
    When a text message delivery receipt is received with:
    """
    {
      'text_message_delivery_receipt' => {
        'msgid'=>'6942744494999745',
        'dlrstatus'=>'DELIVRD',
        'dlr_err'=>'000',
        'donedate'=>'1005132312'
      }
    }
    """

    Then a text message delivery receipt should not exist

  Scenario: A duplicate text message delivery receipt is received
    Given a sent outgoing text_message exists with gateway_message_id: "SMSGlobalMsgID:6942744494999745"
    And a text message delivery receipt exists with outgoing_text_message: the outgoing text message
    And the text message delivery receipt has the following params:
    """
    {
      'msgid'=>'6942744494999745',
      'dlrstatus'=>'DELIVRD',
      'dlr_err'=>'000',
      'donedate'=>'1005132312'
    }
    """

    When a duplicate text message delivery receipt is received with:
    """
    {
      'text_message_delivery_receipt'=> {
        'msgid'=>'6942744494999745',
        'dlrstatus'=>'DELIVRD',
        'dlr_err'=>'000',
        'donedate'=>'1005132312'
      }
    }
    """

    Then 1 text message delivery receipts should exist

