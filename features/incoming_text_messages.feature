Feature: Incoming Text Messages
  In order to be sure that an incoming text message came from SMSGlobal
  I want to check that the incoming text message is in reply to a message sent from this application

  Scenario: An incoming text message is received
    When an incoming text message is received

    Then the most recent job in the queue should be to create the incoming text message

    And the job's priority should be "2"

  Scenario: An incoming text message is received that is in reply to a text message sent by this application
    Given a mobile number exists with number: "66322345211"

    When a reply from "66322345211" is received

    Then an incoming text message should exist with mobile_number_id: the mobile number

  Scenario: An incoming text message is received that is not in reply to a text message sent by this application
    Given a mobile number exists with number: "66322345211"

    When an incoming text message from "66322345211" is received

    Then an incoming text message should not exist

  Scenario: An incoming text message is received for an unknown mobile number
    When a reply from "66123456789" is received

    Then an incoming text message should not exist

  Scenario: A duplicate incoming text message is received
    Given a mobile number exists with number: "66322345211"
    And an incoming text message exists with mobile_number: the mobile number

    And the incoming text message has the following params:
    """
    {
      'to'=>'61447100308',
      'message'=> 'Endiad ad y les',
      'date'=>'2010-05-13 23:59:58',
      'sms_gateway_field' => 'something'
    }
    """

    When a duplicate reply from "66322345211" is received with the following params:
    """
    {
      'to'=>'61447100308',
      'message'=> 'Endiad ad y les',
      'date'=>'2010-05-13 23:59:58',
      'sms_gateway_field' => 'something'
    }
    """

    Then 1 incoming text messages should exist

