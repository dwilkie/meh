Feature: Charge for outgoing text messages
  In order to make money
  I want to charge message credits for outgoing text messages

  Background:
    Given a user: "Dave" exists with name: "Dave"
    And a verified mobile number: "Dave's number" exists with user: the user

  Scenario: The payer has enough message credits
    Given the user has 2 message credits

    When an outgoing text message 0 characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending

    And the user's message_credits should be "1"

  Scenario Outline: The payer just has enough message credits
    Given the user has <credits> message credits

    When an outgoing text message: "original message" <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending
    But the most recent outgoing text message destined for the mobile number should be a translation of "no credits remaining" in "en" (English) where payer_name: "Dave, "
    And the 2nd most recent outgoing text message destined for the mobile number should be the outgoing text message: "original message"

    And the user's message_credits should be "<credits_left>"

    Examples:
      | credits | num_chars | credits_left |
      | 1       | 0         | -1           |
      | 1       | 159       | -1           |
      | 1       | 160       | -1           |
      | 2       | 161       | -1           |
      | 2       | 306       | -1           |
      | 3       | 307       | -1           |
      | 3       | 459       | -1           |
      | 4       | 460       | -1           |
      | 10      | 1530      | -1           |

  Scenario Outline: The payer does not have enough message credits
    Given the user has <credits> message credits

    When an outgoing text message: "original message" <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should not be queued_for_sending

    And the most recent outgoing text message destined for the mobile number should be a translation of "no credits remaining" in "en" (English) where payer_name: "Dave, "
    And that outgoing text message should be marked as queued_for_sending

    And the 2nd most recent outgoing text message destined for the mobile number should be the outgoing text message: "original message"
    But that outgoing text message should not be queued_for_sending

    And the user's message_credits should be "<credits_left>"

    Examples:
      | credits | num_chars | credits_left |
      | 0       | 0         | -1           |
      | 0       | 159       | -1           |
      | 0       | 160       | -1           |
      | 1       | 161       |  0           |
      | 1       | 306       |  0           |
      | 2       | 307       |  1           |
      | 2       | 459       |  1           |
      | 3       | 460       |  2           |
      | 9       | 1530      |  8           |

  Scenario: The payer does not have enough message credits and does not have a verified mobile number
    Given the mobile number is not yet verified
    And the user has 0 message credits

    When an outgoing text message is created with mobile_number: the mobile number

    Then the most recent outgoing text message destined for the mobile number should be a translation of "no credits remaining" in "en" (English) where payer_name: ""

  Scenario: The payer is not the same person as the receiver of the message
    Given the user has 0 message credits
    And another user exists
    And another mobile number exists with user: the user

    When an outgoing text message is created with mobile_number: the mobile number, payer: user: "Dave"

    Then the outgoing text message should not be queued_for_sending
    But the most recent outgoing text message destined for the mobile number: "Dave's number" should be a translation of "no credits remaining" in "en" (English) where payer_name: "Dave, "
    And the outgoing text message should be queued_for_sending
    And the user: "Dave"s message_credits should be "-1"

  Scenario Outline: The SMS Gateway permanently fails to send the message
    Given the user has 10 message credits
    And an outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending
    And the user's message_credits should be "<credits_left>"

    When the outgoing text message permanently fails to send

    Then the user's message_credits should be "10"

    Examples:
      | num_chars            | credits_left         |
      | 0                    | 9                    |
      | 159                  | 9                    |
      | 160                  | 9                    |
      | 161                  | 8                    |
      | 306                  | 8                    |
      | 307                  | 7                    |
      | 459                  | 7                    |
      | 460                  | 6                    |
      | 1530                 | 0                    |

