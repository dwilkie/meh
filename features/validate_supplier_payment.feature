Feature: Validate Supplier Payment
  In order to prevent incorrect payments from being created
  As a seller
  I want to make sure that I or the system can't create invalid payments

  Background:
    Given a seller exists
    And a supplier exists
    And a mobile_number exists with phoneable: the seller
    And there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier

  Scenario: Do not create a payment when the product has no supplier price
    Given a product exists with supplier: the supplier, seller: the seller, cents: 0
    And a supplier_order exists with id: 154671, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

    When the supplier accepts the supplier_order

    Then a payment should not exist
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "invalid payment" in "en" (English) where
