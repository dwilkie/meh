@action_sms
Feature: Send outgoing text messages
  In order physcially send text mesages
  I want to communicate with an the SMS gateway

  Background:
    Given a user exists
    And a verified mobile number exists with user: the user
    And no jobs exist
    And an outgoing text message exists with mobile_number: the mobile number

    Then the outgoing text message should be queued_for_sending
    And the most recent job in the queue should be to send the text message

  Scenario: Send a text message
    Given the sms gateway is up
    And there are enough credits available in the sms gateway

    When the worker works off the job

    Then the job should be deleted from the queue
    And the outgoing text message should be marked as sent

  Scenario: The SMS Gateway is up but there are not enough credits available in the SMS Gateway
    Given the sms gateway is up
    But there are not enough credits available in the sms gateway

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the outgoing text message should not be marked as sent
    And the outgoing text message should be marked as last_failed_to_send

  Scenario: The SMS Gateway is down
    Given the sms gateway is down

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the outgoing text message should not be marked as sent
    And the outgoing text message should be marked as last_failed_to_send

  Scenario: The text message permanently fails to send
    Given the sms gateway is down

    When the worker permanently fails to work off the job

    Then the job should be deleted from the queue
    And the outgoing text message should not be marked as sent
    And the outgoing text message should be marked as permanently_failed_to_send

