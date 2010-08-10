Feature: Create a seller order
  In order to keep track of my orders
  As a seller
  I want a new seller order to be created when a paypal ipn is verified and the payment status is: 'Completed'

  Background:
    Given a seller exists with email: "some_seller@example.com"
    And a product exists with seller: the seller

  Scenario: The payment status is 'Completed'
    Given a paypal_ipn exists with payment_status: "Completed"
    And the paypal_ipn has the following params: "{'receiver_email'=>'some_seller@example.com'}"

    When the paypal_ipn is verified

    Then a seller_order should exist
    And the seller_order should be the paypal_ipn seller_order
    And the seller should be the paypal_ipn seller
    And the seller_order should be amongst the seller's seller_orders

  Scenario: The payment status is not 'Completed'
    Given a paypal_ipn exists
    And the paypal_ipn has the following params: "{'receiver_email'=>'some_seller@example.com'}"

    When the paypal_ipn is verified

    Then a seller_order should not exist

