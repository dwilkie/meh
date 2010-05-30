Feature: Payment Agreement
  In order to pay my suppliers for orders they have processed
  As a seller
  I want to be able to set up payment agreements to pay suppliers automatically
         with or without confirmation when they process an order
  
  Background:
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Fon"
    And a product exists with supplier: the supplier, seller: the seller, cents: "230000", currency: "THB"
    And a supplier_order exists with supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

  Scenario Outline: Payment agreement between the seller and supplier is set to automatic
    Given there is a payment agreement set to automatic and to trigger when an order is <processed> with seller: the seller, supplier: the supplier
    And a supplier_order exists with supplier: the supplier, status: "<status>", quantity: "4", product: the product

    When the supplier <processes> the supplier_order

    Then a payment should exist with supplier_order_id: the supplier_order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier

    Examples:
      | status       | processes  | processed |
      | unconfirmed  | accepts    | accepted  |
      | accepted     | completes  | completed |
      
  Scenario: Payment agreement between seller and supplier is set to automatic with confirmation
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier, confirm: true
    And a mobile_number: "seller's number" exists with phoneable: the seller
    And a mobile_number: "supplier's number" exists with phoneable: the supplier, number: "66789098763"
    And a product exists with supplier: the supplier, seller: the seller, cents: "230000", currency: "THB", external_id: 244654
    And a seller_order exists with id: 123553
    And a supplier_order exists with supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product, id: 154674, seller_order: the seller_order

    When the supplier accepts the supplier_order
    
    Then a payment should not exist
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be a translation of "confirm payment" in "en" (English) where seller: "Dave", supplier_order_number: "154674", processed: "accepted", supplier_contact_details: "+66789098763", amount: "9,200.00 THB", quantity: "4", product_code: "244654", customer_order_number: "123553", supplier: "Fon"

  Scenario: Payment agreement between the seller and supplier is set to manual
    Given there is a payment agreement set to manual with seller: the seller, supplier: the supplier

    When the supplier accepts the supplier_order
    
    Then a payment should not exist

  Scenario: Payment agreement between the seller and supplier is set to automatic but the payment agreement for this particular product is set to manual
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And there is a payment agreement set to manual with product: the product

    When the supplier accepts the supplier_order
    
    Then a payment should not exist

  Scenario: Payment agreement with between the seller and supplier is set to manual but the payment agreement for this particular product is set to automatic
    Given there is a payment agreement set to manual with seller: the seller, supplier: the supplier
    And there is a payment agreement set to automatic and to trigger when an order is accepted with product: the product

    When the supplier accepts the supplier_order
    
    Then a payment should exist with supplier_order_id: the supplier_order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier

  Scenario: Payment agreement between the seller and supplier is set to automatic with confirmation but the payment agreement for this particular product is set to automatic without confirmation
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier, confirm: true
    And there is a payment agreement set to automatic and to trigger when an order is accepted with product: the product
    
    When the supplier accepts the supplier_order
    
    Then a payment should exist with supplier_order_id: the supplier_order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier

  Scenario: There are no payment agreements between the seller and the supplier or for this product
    When the supplier accepts the supplier_order
    
    Then a payment should not exist
