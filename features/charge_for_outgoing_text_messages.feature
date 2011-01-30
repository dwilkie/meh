Feature: Charge for outgoing text messages
  In order to make money
  I want to charge message credits for outgoing text messages

  Background:
    Given a user: "Dave" exists with name: "Dave"
    Then a mobile number: "Dave's number" should exist with user: user: "Dave"

  Scenario: The payer has enough message credits
    Given the user has 2 message credits

    When an outgoing text message 0 characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending

    And the user's message_credits should be "1"

  Scenario Outline: The payer has just enough message credits
    Given the user has <credits> message credits

    When an outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending
    But the most recent outgoing text message destined for the mobile number should be "No more messages can be sent because you've run out of credits. Pls top up"

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

  Scenario: The payer's mobile number is already verified and they have just enough credits
    Given the mobile number was already verified
    And the user has 1 message credit

    When an outgoing text message is created with mobile_number: the mobile number

    Then the most recent outgoing text message destined for the mobile number should be "Dave, No more messages can be sent because you've run out of credits. Pls top up"

  Scenario Outline: The payer does not have enough message credits
    Given the user has <credits> message credits

    When an outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should not be queued_for_sending
    And the most recent outgoing text message destined for the mobile number should be "No more messages can be sent because you've run out of credits. Pls top up"
    But that outgoing text message should be queued_for_sending
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

  Scenario: The payer has negative credits
    Given the user has -1 message credits

    When an outgoing text message 0 characters long is created with mobile_number: the mobile number

    Then the outgoing text message should not be queued_for_sending
    And the most recent outgoing text message destined for the mobile number should be "No more messages can be sent because you've run out of credits. Pls top up"
    But that outgoing text message should be queued_for_sending
    And the user's message_credits should be "-2"

  Scenario: The payer is out of credits but is not the same person as the receiver of the message
    Given the user has 0 message credits
    And another user exists
    Then another mobile number should exist

    When an outgoing text message is created with mobile_number: the mobile number, payer: user: "Dave"

    Then the outgoing text message should not be queued_for_sending
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be "No more messages can be sent because you've run out of credits. Pls top up"
    And the outgoing text message should be queued_for_sending
    And the user: "Dave"'s message_credits should be "-1"

  Scenario Outline: The SMS Gateway permanently fails to send the message
    Given the user has 10 message credits
    And an outgoing text message <num_chars> characters long is created with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending

    When the outgoing text message permanently fails to send

    Then the user's message_credits should be "10"

    Examples:
      | num_chars            |
      | 0                    |
      | 159                  |
      | 160                  |
      | 161                  |
      | 306                  |
      | 307                  |
      | 459                  |
      | 460                  |

