Feature: Send text message
  In order to make money
  I want to be able to communicate with users over sms and charge for the service

  Background:
    Given a user exists
    And a mobile number exists with user: the user
    And no jobs exist

  Scenario Outline: The payer has enough message credits
    Given the user has <credits> message credits
    And the sms gateway is up
    And there are enough credits available in the sms gateway

    When an outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be marked as queued_for_sending
    And the user's message_credits should be "<credits_left>"
    And the most recent job in the queue should be to send the text message
    And the job's priority should be "1"

    When the worker works off the job

    Then the job should be deleted from the queue
    And the outgoing text message should be marked as sent

    Examples:
      | credits | num_chars | credits_left |
      | 1       | 0         | 0            |
      | 1       | 159       | 0            |
      | 1       | 160       | 0            |
      | 2       | 161       | 0            |
      | 2       | 306       | 0            |
      | 3       | 307       | 0            |
      | 3       | 459       | 0            |
      | 4       | 460       | 0            |
      | 10      | 1530      | 0            |
      | 999     | 0         | 998          |

  Scenario Outline: The payer does not have enough message credits
    Given the user's name is <user_name_chars> characters long
    And the user has <credits> message credits
    And the sms gateway is up
    And there are enough credits available in the sms gateway

    When an outgoing text message: "order message" <num_chars> characters long is created with mobile_number: the mobile number

    Then the most recent outgoing text message: "not enough credits" destined for the mobile number should include "you don't have enough credits"
    And that outgoing text message should be marked as queued_for_sending
    And the most recent job in the queue should be to send the text message
    And the job's priority should be "1"
    And the 2nd most recent outgoing text message destined for the mobile number should be the outgoing text message: "order message"
    But that outgoing text message should not be marked as queued_for_sending
    And the 2nd most recent job in the queue should not be to send the text message

    When the worker works off the job

    Then the job should be deleted from the queue
    And the outgoing text message: "not enough credits" should be marked as sent
    And the user's message_credits should be "<credits_left>"

    But the outgoing text message: "order message" should not be marked as sent

    Examples:
      | credits | num_chars | credits_left | user_name_chars |
      | 0       | 0         | -1           | 4               |
      | 0       | 159       | -2           | 146             |
      | 0       | 160       | -1           | 4               |
      | 1       | 161       | -1           | 146             |
      | 1       | 306       |  0           | 4               |
      | 2       | 307       |  0           | 146             |
      | 2       | 459       |  1           | 4               |
      | 3       | 460       |  1           | 146             |
      | 9       | 1530      |  8           | 4               |

  Scenario: The user has a negative number of credits
    Given the user has -1 message credits

    When an outgoing text message is created with mobile_number: the mobile number

    Then the most recent outgoing text message destined for the mobile number should be the outgoing text message
    But the outgoing text message should not be marked as queued_for_sending
    And the most recent job in the queue should not be to send the text message
    And the outgoing text message should not be marked as sent
    And the user's message_credits should be "-1"

  Scenario: The SMS Gateway is up but there are not enough credits available in the SMS Gateway
    Given the user has 1 message credit
    And an outgoing text message exists with mobile_number: the mobile number

    Then the outgoing text message should be marked as queued_for_sending
    And the most recent job in the queue should be to send the text message

    Given the sms gateway is up
    But there are not enough credits available in the sms gateway

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the outgoing text message should not be marked as sent
    And the outgoing text message should be marked as last_failed_to_send

  Scenario: The SMS Gateway is down
    Given the user has 1 message credit
    And an outgoing text message exists with mobile_number: the mobile number

    Then the outgoing text message should be marked as queued_for_sending
    And the most recent job in the queue should be to send the text message

    Given the sms gateway is down

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the outgoing text message should not be marked as sent
    And the outgoing text message should be marked as last_failed_to_send

  Scenario Outline: The SMS Gateway permanently fails to send the message
    Given the user has 10 message credits

    When an outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be marked as queued_for_sending
    And the user's message_credits should be "<credits_left>"
    And the most recent job in the queue should be to send the text message

    Given the sms gateway is down

    When the worker permanently fails to work off the job

    Then the outgoing text message should not be marked as sent
    And the outgoing text message should be marked as permanently_failed_to_send
    And the user's message_credits should be "10"

    Examples:
      | num_chars | credits_left |
      | 0                    | 9                    |
      | 159                  | 9                    |
      | 160                  | 9                    |
      | 161                  | 8                    |
      | 306                  | 8                    |
      | 307                  | 7                    |
      | 459                  | 7                    |
      | 460                  | 6                    |
      | 1530                 | 0                    |

