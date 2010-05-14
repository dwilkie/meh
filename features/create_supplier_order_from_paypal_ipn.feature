Feature: Create a supplier order when item is payed for via paypal
  In order to keep track of my orders
  As a supplier
  I want a new supplier order to be created when a customer successfully purchases an item that I am supplying on paypal

  Scenario: Customer successfully purchases an item using paypal
    Given a supplier exists
    And a product exists with supplier: the supplier
    
    When a customer successfully purchases the product through paypal
    
    Then an order should exist with supplier_id: the supplier
    And the order should be unconfirmed
    And the order should be amongst the supplier's supplier_orders
