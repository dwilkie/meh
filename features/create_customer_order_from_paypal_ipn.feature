Feature: Create a customer order when item is payed for via paypal
  In order to keep track of my orders
  As a seller
  I want a new customer order to be created when a customer successfully purchases an item of mine using paypal

  Scenario: Customer successfully purchases an item using paypal
    Given a seller exists
    And a product exists with seller: the seller
    
    When a customer successfully purchases the product through paypal
    
    Then a paypal_ipn should exist with payment_status: "Completed"
    And an order should exist with seller_id: the seller
    And the order should be unconfirmed
    And the paypal_ipn should be the order's paypal_ipn
    And the order should be amongst the seller's customer_orders
