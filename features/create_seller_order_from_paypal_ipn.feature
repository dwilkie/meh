Feature: Create a seller order
  In order to keep track of my orders
  As a seller
  I want a new seller order to be created when a paypal ipn is received and verified and the payment status is: 'Completed'

  Scenario: Paypal ipn is verified and a the payment status is completed
    Given a seller exists
    And a product exists with seller: the seller
    And a paypal_ipn exists
    And the paypal_ipn has the following params: "'payment_status'=>'Completed', 'txn_id'=>'45D21472YD1820048', 'receiver_email'=>'some_seller@example.com'"

    When the paypal_ipn is verified

    Then a seller_order should exist
    And the seller_order should be the paypal_ipn seller_order
    And the seller should be the paypal_ipn seller
    And the seller_order should be amongst the seller's seller_orders

