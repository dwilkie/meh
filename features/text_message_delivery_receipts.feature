Feature: Text message delivery receipts
  In order to keep track of the status of outgoing text messages
  I want to be notified with delivery receipts when outgoing text messages are delivered or fail to be delivered

  Scenario: A text message delivery receipt is received
    When a text message delivery receipt is received
    Then the most recent job in the queue should be to create the text message delivery receipt

  Scenario: A text message delivery receipt is received for an existing outgoing text message
    Given a sent outgoing text message exists with gateway_message_id: "12345"

    When a text message delivery receipt is received for message id: "12345"

    Then a text message delivery receipt should exist with outgoing_text_message_id: the outgoing text message

  Scenario: A text message delivery receipt is received for a non existing outgoing text message
    When a text message delivery receipt is received for message id: "12345"

    Then a text message delivery receipt should not exist

  Scenario: A duplicate text message delivery receipt is received
    Given a sent outgoing text message exists with gateway_message_id: "12345"
    And a text message delivery receipt exists with outgoing_text_message: the sent outgoing text message
    And the text message delivery receipt also has the following params:
    """
    {
      'date'=>'1005132312',
      'sms_gateway_field' => 'something'
    }
    """

    When a duplicate text message delivery receipt is received for message id: "12345" with the following params:
    """
    {
      'date'=>'1005132312',
      'sms_gateway_field' => 'something'
    }
    """

    Then 1 text message delivery receipts should exist

  Scenario: The create resource url is hit with no payload
    When a text message delivery receipt is received

    Then a text message delivery receipt should not exist

