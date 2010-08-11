Feature: Unknown topic or blank incoming text messages
  In order to inform existing users that their text message was invalid or to welcome new users to the system
  I want to reply to all messages that are blank or have an unknown topic

  Scenario Outline: An incoming text message is received with invalid or blank text from an unknown mobile number

    When an incoming text message is received with: <incoming_text_message_params>

    Then a mobile_number should exist with number: "66322345211"
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "the welcome message" in "en" (English)

    Examples:
      | incoming_text_message_params                                               |
      | "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}" |
      | "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> '', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"                |

  Scenario Outline: An incoming text message is received with invalid or blank text from an existing mobile number not linked to a user
    Given a mobile_number exists with number: "66322345211"

    When an incoming text message is received with: <incoming_text_message_params>

    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "the welcome message" in "en" (English)

    Examples:
      | incoming_text_message_params                                               |
      | "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}" |
      | "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> '', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"                |

  Scenario Outline: An incoming text message is received with invalid or blank text from an existing mobile number linked to a user

    Given a mobile_number exists with number: "66322345211"
    And a user exists with name: "Mara", mobile_number: the mobile_number

    When an incoming text message is received with: <incoming_text_message_params>

    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "invalid command" in "en" (English) where <interpolations>

    Examples:
      | incoming_text_message_params | interpolations |
      | "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> 'Endiad ad y les', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"                         | user: "Mara", topic: "Endiad", message_text: "Endiad ad y les"                                     |
      | "{'incoming_text_message' => {'to'=>'61447100308', 'from'=> '66322345211', 'msg'=> '', 'userfield'=>'123456', 'date'=>'2010-05-13 23:59:58'}}"                | user: "Mara"                                        |

