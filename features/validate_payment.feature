Feature: Validate Payment
  In order to prevent incorrect payments from being created for supplier orders
  As a seller
  I want to make sure that I or the system can't create invalid payments

  Background:
    Given a seller exists
    And a supplier exists
    And a mobile_number exists with phoneable: the seller
    And there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier

  Scenario: Do not create a payment when the product has no supplier price
    Given a product exists with supplier: the supplier, seller: the seller, cents: 0
    And a supplier_order exists with supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

    When the supplier accepts the supplier_order

    Then a payment should not exist
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "payment not greater than" in "en" (English) where count: 0
    
  Scenario: Do not create a payment if there is already a payment for this order
    Given a product exists with supplier: the supplier, seller: the seller, cents: 500000, currency: "KHR"
    And a supplier_order exists with supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product, id: 234564
    And a payment exists with cents: 2000000, currency: "KHR", supplier_order: the supplier_order, seller: the seller, supplier: the supplier

    When the supplier accepts the supplier_order

    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "payment already exists for this order" in "en" (English) where value: "234564"
