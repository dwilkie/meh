Feature: Payment Agreement
  In order to pay my suppliers for orders they have processed
  As a seller
  I want to be able to set up payment agreements to pay suppliers automatically
         with or without confirmation when they process an order
  
  Background:
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Fon"
    And a mobile_number: "Dave's number" exists with phoneable: the seller
    And a mobile_number: "Fon's number" exists with phoneable: the supplier, number: "66789098763"
    And a product exists with supplier: the supplier, seller: the seller, cents: "230000", currency: "THB", external_id: 244654
    And a seller_order exists with id: 154673
    And a supplier_order exists with id: 154674, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product, seller_order: the seller_order

  Scenario Outline: Payment agreement between the seller and supplier is set to automatic
    Given there is a payment agreement set to automatic and to trigger when an order is <processed> with seller: the seller, supplier: the supplier
    And a supplier_order exists with supplier: the supplier, status: "<status>", quantity: "4", product: the product

    When the supplier <processes> the supplier_order

    Then a payment should exist with supplier_order_id: the supplier_order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier

    Examples:
      | status       | processes  | processed |
      | unconfirmed  | accepts    | accepted  |
      | accepted     | completes  | completed |

  Scenario: Automatic payment when the seller also has an active payment application
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And the seller has an active payment application

    When the supplier accepts the supplier_order
    
    Then a payment should exist
    And a payment_request should exist

  Scenario Outline: Automatic payment when seller also has payment application but it is not active
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And the seller has an <status> payment application
    
    When the supplier accepts the supplier_order
    
    Then a payment should exist
    But a payment_request should not exist
    And a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should be a translation of "invalid payment application" in "en" (English) where seller: "Dave", supplier_order_number: "154674", supplier_contact_details: "+66789098763", amount: "9,200.00 THB", supplier: "Fon", status: "<status>"

    Examples:
      | status      |
      | unconfirmed |
      | inactive    |
      
  Scenario: Automatic payment when the seller does not have a payment application
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    
    When the supplier accepts the supplier_order
    
    Then a payment should exist
    But a payment_request should not exist
    And a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should be a translation of "invalid payment application" in "en" (English) where seller: "Dave", supplier_order_number: "154674", supplier_contact_details: "+66789098763", amount: "9,200.00 THB", supplier: "Fon"

  Scenario: Payment agreement between seller and supplier is set to automatic with confirmation
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier, confirm: true

    When the supplier accepts the supplier_order
    
    Then a payment should not exist
    And a new outgoing text message should be created destined for mobile_number: "Dave's number"
    And the outgoing_text_message should be a translation of "confirm payment" in "en" (English) where seller: "Dave", supplier_order_number: "154674", processed: "accepted", supplier_contact_details: "+66789098763", amount: "9,200.00 THB", quantity: "4", product_code: "244654", customer_order_number: "154673", supplier: "Fon"

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

  Scenario: Do not create a payment when the product has no supplier price
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And a product exists with supplier: the supplier, seller: the seller, cents: 0
    And a supplier_order exists with supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

    When the supplier accepts the supplier_order

    Then a payment should not exist
    And a new outgoing text message should be created destined for mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "payment not greater than" in "en" (English) where count: 0

  Scenario: Do not create a payment if there is already a payment for this order
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And a payment exists with cents: 920000, currency: "THB", supplier_order: the supplier_order, seller: the seller, supplier: the supplier

    When the supplier accepts the supplier_order

    Then a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "payment already exists for this order" in "en" (English) where value: "154674"
