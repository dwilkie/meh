Feature: Order payment
  In order to pay my suppliers for processing my orders
  As a seller
  I want to be able to pay my supplier when they have processed an order

  Background:
    Given a seller exists
    And a supplier exists

  Scenario Outline: Create a payment when an order is processed
    Given an agreement exists with seller: the seller, supplier: the supplier, payment_for_supplier_order: "<processed>"
    And a product exists with supplier: the supplier, seller: the seller, cents: "230000", currency: "THB"
    And a supplier_order exists with id: 154671, supplier: the supplier, status: "<status>", quantity: "4", product: the product
    
    When the supplier <processes> the supplier_order
    
    Then a payment should exist with supplier_order_id: the supplier_order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier

    Examples:
      | status       | processes  | processed |
      | unconfirmed  | accepts    | accepted  |
      | accepted     | completes  | completed |
      
  Scenario: Do not create a payment when the product has no supplier price
    Given an agreement exists with seller: the seller, supplier: the supplier, payment_for_supplier_order: "accepted"

    And a product exists with supplier: the supplier, seller: the seller, cents: "0"
    And a supplier_order exists with id: 154671, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

    When the supplier accepts the supplier_order
    
    Then a payment should not exist

  Scenario Outline: Do not create a payment when the product has no supplier price
    Given an agreement exists with seller: the seller, supplier: the supplier, payment_for_supplier_order: "<processed>"

    And a product exists with supplier: the supplier, seller: the seller, cents: "0"
    And a supplier_order exists with id: 154671, supplier: the supplier, status: "<status>", quantity: "4", product: the product

    When the supplier <processes> the supplier_order
    
    Then a payment should not exist

    Examples:
      | status       | processes | processed |
      | unconfirmed  | accept    | accepted  |
      | accepted     | complete  | completed |
