Feature: Paypal IPN Verification
  In order to verify that a Paypal IPN intended for me actually originated from Paypal and was not spoofed
  As a seller
  I want to post back all fields to paypal for verification

  Scenario: Paypal sent the IPN
    Given a seller exists with email: "some_seller@example.com"
    And a paypal_ipn exists with seller: the seller, transaction_id: "45D21472YD1820048"
    And paypal sent the IPN

    When the worker completes its job

    Then the paypal_ipn should be marked as verified
    And the paypal_ipn should not be fraudulent

