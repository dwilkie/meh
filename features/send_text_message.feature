Feature: Send text message
  In order to communicate with users over sms
  I want to be able to send text messages

  Scenario: Send a text message
    Given an outgoing text message exists

    Then the most recent job in the queue should be to send the text message
    And the job's priority should be "1"

  Scenario: The SMS Gateway is up and there are enough credits available in the SMS Gateway
    Given an outgoing text message exists

    Then the most recent job in the queue should be to send the text message

    Given the SMS Gateway is up
    And there are enough credits available in the SMS Gateway

    When the worker works off the job

    Then the job should be deleted from the queue
    And the outgoing text message should be sent

  Scenario: The SMS Gateway is up but there are not enough credits available in the SMS Gateway
    Given an outgoing text message exists

    Then the most recent job in the queue should be to send the text message

    Given the SMS Gateway is up
    But there are not enough credits available in the SMS Gateway

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the outgoing text message should not be sent

  Scenario: The SMS Gateway is down
    Given an outgoing text message exists

    Then the most recent job in the queue should be to send the text message

    Given the SMS Gateway is down

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the outgoing text message should not be sent

  @current
  Scenario Outline: The user does not have enough credits left
    Given a user exists
    And the user's name is <user_name_chars> characters long
    And a mobile_number exists with user: the user
    And the user has <credits> message credits
    And the sms gateway is up
    And there are enough credits available in the sms gateway

    When an outgoing text message: "order message" <num_chars> characters long is created with mobile_number: the mobile number

    Then the most recent outgoing text message destined for the mobile number should be a translation of "you do not have enough credits left" in "en" (English)
    And the most recent job in the queue should be to send the text message
    And the 2nd most recent outgoing text message destined for the mobile number should be the outgoing text message: "order message"
    But the 2nd most recent job in the queue should not be to send the text message

    When the worker works off the job

    Then the outgoing text message should be sent
    And the user's message credits should be "<credits_left>"

    But the outgoing text message: "order message" should not be sent

    When another outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the most recent outgoing text message destined for the mobile_number should be the outgoing text message
    But the most recent job in the queue should not be to send the text message
    And the outgoing text message should not be sent
    And user's message credits should be "<credits_left>"

    Examples:
      | credits | num_chars | credits_left | user_name_chars |
      | 0       | 0         | -1           | 4               |
#      | 0       | 159       | -2          | 147             |
#      | 0       | 160       | -1          | 4               |
#      | 1       | 161       | -1          | 147             |
#      | 1       | 306       |  0          | 4               |
#      | 2       | 307       |  0          | 147             |
#      | 2       | 459       |  1          | 4               |
#      | 3       | 460       |  1          | 147             |
#      | 9       | 1530      |  8          | 4               |

  Scenario Outline: The SMS Gateway permanently fails to send the message
    Given a user exists
    And a mobile_number exist with user: the user
    And the user has 10 message credits

    When an outgoing text message <number_of_characters> characters long is created with mobile_number: the mobile number

    And the most recent job in the queue should be to send the text message
    And the user's message_credits should be "<message_credits_left>"

    Given the SMS Gateway is down

    When the worker permanently fails to work off the job

    Then the outgoing text message should not be sent
    And the user's message_credits should be "10"

    Examples:
      | number_of_characters | message_credits_left |
      | 0                    | 9                    |
#      | 159                  | 9                    |
#      | 160                  | 9                    |
#      | 161                  | 8                    |
#      | 306                  | 8                    |
#      | 307                  | 7                    |
#      | 459                  | 7                    |
#      | 460                  | 6                    |
#      | 1530                 | 0                    |

