Feature: Payment Request
  In order to transfer money to my suppliers
  As a seller
  I want be able to make payment requests to my external payment application

  Background: A payment is created
    When a payment is created
    Then a payment request should exist with payment_id: the payment
    And the most recent job in the queue should be to create a remote payment request

  Scenario: The remote payment application is up
    Given the remote payment application is up
    When the worker works off the job
    Then the job should be deleted from the queue
    And the time when the first attempt to contact the remote payment application occurred should be recorded

  Scenario: The remote payment application is down
    Given the remote payment application is down
    When the worker works off the job
    Then the job should not be deleted from the queue
    And the job's attempts should be "1"
    And the time when the first attempt to contact the remote payment application occurred should be recorded

  Scenario: The worker tries 9 times to contact the remote payment application
    Given the remote payment application is down
    When the worker tries 9 times to work off the job
    Then the job should be deleted from the queue

#    And the most recent outgoing text message destined for the mobile number

