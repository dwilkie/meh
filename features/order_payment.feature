Feature: Order payment
  In order to pay my suppliers processing my orders
  As a seller
  I want to be able to pay my supplier when they have processed an order

  Background:
  
  Scenario Outline: Pay the supplier when the order is processed
    Given a seller exists
    And a supplier exists
    And an agreement exists with seller: the seller, supplier: the supplier, payment_for_supplier_order: "<processed>"
    And a product exists with supplier: the supplier, seller: the seller, supplier_amount: "230000", currency: "THB"
    And a supplier_order exists with id: 154671, supplier: the supplier, status: "<status>"
    
    When the supplier <processes> the supplier_order
    
    Then a order payment should exist with supplier_order: the supplier_order, status: "new", currency: "THB", amount: "230000"

    Examples:
      | status       | processes | processed |
      | unconfirmed  | accept    | accepted  |
      | accepted     | complete  | completed |
