Feature: Verify Paypal Ipn
  In order to verify that a Paypal IPN intended for me actually originated from Paypal and was not spoofed
  As a seller
  I want to post back all fields to paypal for verification

  Background:
    When a paypal ipn is created
    Then the most recent job in the queue should be to verify the paypal ipn

  Scenario: Paypal sent an IPN with a payment status of completed
    Given paypal sent the IPN

    When the worker works off the job

    Then the paypal ipn should be verified
    And the paypal ipn should not be fraudulent
    And the last request should contain the paypal ipn params

  Scenario: Paypal did not send the IPN
    Given paypal did not send the IPN

    When the worker works off the job

    Then the paypal ipn should not be verified
    And the paypal ipn should be fraudulent
    And the last request should contain the paypal ipn params

