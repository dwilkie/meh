Feature: Incoming text messages
  In order to execute business logic based on the content of incoming text messages
  I want to be save all valid incoming text messages

  Scenario: An incoming text message is received from an existing mobile number
    Given a mobile_number exists with number: "66322345211"

    When an incoming text message is received with: "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"

    Then an incoming_text_message should exist with mobile_number_id: the mobile_number

  Scenario: An incoming text message is received for a non existing mobile number
    When an incoming text message is received with: "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"

    Then a mobile_number should exist with number: "66322345211"
    And an incoming_text_message should exist with mobile_number_id: the mobile_number

  Scenario: A duplicate incoming text message is received
    Given an incoming_text_message exists
    And the incoming_text_message has the following params: "{'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}"

    When an incoming text message is received with: "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"

    Then 1 incoming_text_messages should exist

  Scenario: An incoming text message is received with no from field
    When an incoming text message is received with: "{'incoming_text_message' => {'to'=>'61447100308', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"

    Then an incoming_text_message should not exist

