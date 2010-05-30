Feature: Pay
  In order to actually transfer funds
  I want to communicate with the sellers payment application and update the payment object accordingly
  
  Background:
    Given a seller exists
    And a supplier exists
    And a product exists with cents: 50000, currency: "THB", seller: the seller, supplier: the supplier
    And a supplier_order exists with supplier: the supplier

  Scenario: Pay
    Given a payment_application exists with seller: the seller
    When a payment is created with seller: the seller, supplier: the supplier, supplier_order: the supplier_order

