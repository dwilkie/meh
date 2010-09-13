Feature: Invalid or blank incoming text messages
  In order to be informed that my text message was invalid
  As an existing user
  I want to receive brief help containing examples of valid messages

  Background:
    Given a user exists with name: "Dave"
    And a mobile number exists with user: the user, number: "66322345211"

  Scenario Outline: An incoming text message is received with invalid or blank text
    Given the mobile number <is_not_yet_or_was_already> verified
    When I text "<text_message>" from "66322345211"

    Then the most recent outgoing text message destined for the mobile number should be a translation of "valid message commands are" in "en" (English) where user_name: <user_name>

    Examples:
      | is_not_yet_or_was_already | message_text | user_name |
      | is not yet                | blah         |  ""       |
      | was already               | help         | " Dave"   |
      | is not yet                |              |   ""      |
      | was already               |              | " Dave"   |

