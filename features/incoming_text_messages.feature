Feature: Incoming Text Messages
  In order to be sure that an incoming text message came from SMSGlobal
  I want to check that the incoming text message is in reply to a message sent from this application

  Scenario Outline: An incoming text message is received that is in reply to a text message sent by this application

    When an authentic incoming text message is received with:
    """
    { 'incoming_text_message' => <params> }
    """

    Then a mobile number should exist with number: "66322345211"
    And an incoming text message should exist with mobile_number_id: the mobile number
    And the incoming text message should have the following params:
    """
    <params>
    """

    Examples:
      | params                                  |
      | {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'date'=>'2010-05-13 23:59:58'}                  |

  Scenario: An incoming text message is received that is not in reply to a text message sent by this application

  When an incoming text message is received with:
  """
  {
    'incoming_text_message' => {
      'to'=>'61447100308',
      'from'=> '66322345211',
      'msg'=> 'Endiad ad y les',
      'date'=>'2010-05-13 23:59:58'
    }
  }
  """

  Then a mobile number should not exist
  And an incoming text message should not exist

  Scenario Outline: A duplicate incoming text message is received
    Given an incoming text message exists

    And the incoming text message has the following params:
    """
    <params>
    """

    When an authentic incoming text message is received with:
    """
    { 'incoming_text_message' => <params> }
    """

    Then 1 incoming text messages should exist

    Examples:
      | params                                  |
      | {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'date'=>'2010-05-13 23:59:58'}                  |

