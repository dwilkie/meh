Feature: Paypal IPN Verification
  In order to verify that a Paypal IPN intended for me actually originated from Paypal and was not spoofed
  As a seller
  I want to post back all fields to paypal for verification

  Scenario: A Paypal IPN is created
    When a paypal_ipn is created
    Then a job should exist to verify the ipn came from paypal

  Scenario: Paypal sent the IPN
    Given a paypal_ipn exists
    And paypal sent the IPN

    When the worker completes its job

    Then the paypal_ipn should be marked as verified
    And the paypal_ipn should not be fraudulent

  Scenario: Paypal did not send the IPN
    Given a paypal_ipn exists
    And paypal did not send the IPN

    When the worker completes its job

    Then the paypal_ipn should not be marked as verified
    And the paypal_ipn should be fraudulent

