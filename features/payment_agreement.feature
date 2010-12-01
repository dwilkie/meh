Feature: Payment Agreement
  In order to pay my suppliers automatically for orders they receive or process
  As a seller
  I want to be able set up payment agreements to pay suppliers when they confirm or complete an order

  Background:
    Given a seller exists with name: "Dave"
    And a verified mobile number: "Dave's number" exists with user: the seller, number: "66876423223"
    And a supplier: "Fon" exists with name: "Fon"
    And a verified mobile number: "Fon's number" exists with user: the supplier, number: "66813456743"
    And a payment agreement exists with seller: the seller, supplier: the supplier, currency: "THB"
    And a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product with quantity: 4
    Then a supplier order should exist

  Scenario: I have a payment agreement with my supplier to pay them a fixed amount when they confirm an order
    Given I update the payment agreement with fixed_amount: "500"

    When the supplier confirms the line item

    Then a supplier payment should exist with supplier_order_id: the supplier order, seller_id: the seller, supplier_id: the supplier
    And the supplier payment's amount should be "500.00"
    And the supplier payment's currency should be "THB"

  Scenario: I have a payment agreement with my supplier to pay them a fixed amount when they complete an order
    Given I update the payment agreement with event: "supplier_order_completed", fixed_amount: "500"
    And the line item was already confirmed
    Then a supplier payment should not exist

    When the supplier completes the supplier order

    Then a supplier payment should exist with supplier_order_id: the supplier order, seller_id: the seller, supplier_id: the supplier
    And the supplier payment's amount should be "500.00"
    And the supplier payment's currency should be "THB"

  Scenario: I have a payment agreement with my supplier for no fixed amount indicating that the amount depends on the products in the order
    Given I update the product with supplier_payment_amount: "750"

    When the supplier confirms the line item

    Then a supplier payment should exist with supplier_order_id: the supplier order, seller_id: the seller, supplier_id: the supplier
    And the supplier payment's amount should be "3000.00"
    And the supplier payment's currency should be "THB"

  Scenario Outline: I have a payment agreement with my supplier for no fixed amount and the product in the order does not have a supplier payment amount
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified

    When the supplier confirms the line item

    Then a supplier payment should not exist
    And the 2nd most recent outgoing text message destined for the mobile number: "Dave's number" should include a translation of "supplier payment amount invalid" in "en" (English) where count: "0"
    And the seller should be that outgoing text message's payer
    And the outgoing text message should <be_or_not_be> queued_for_sending

    Examples:
      | is_not_yet_or_was_already | be_or_not_be |
      | is not yet                | not be       |
      | was already               | be           |

  Scenario: I have a payment agreement with my supplier for no fixed amount and 2 line items for products with supplier payment amounts exist in the order
    Then a line item: "first item" should exist
    Given I update the product with supplier_payment_amount: "539.24"
    And another product exists with seller: the seller, supplier: the supplier, supplier_payment_amount: "1000"
    And a line item exists for that product and the supplier order with quantity: 3

    When the supplier confirms the line item
    And the supplier confirms line item: "first item"

    Then a supplier payment should exist with supplier_order_id: the supplier order, seller_id: the seller, supplier_id: the supplier
    And the supplier payment's amount should be "5156.96"
    And the supplier payment's currency should be "THB"

  Scenario: I have a payment agreement with another supplier who is not the supplier of this order
    Given no payment agreements exist
    And another supplier exists
    And a payment agreement exists with seller: the seller, supplier: the supplier, fixed_amount: "500"

    When the supplier: "Fon" confirms the line item
    And the supplier: "Fon" completes the supplier order

    Then a supplier payment should not exist

  Scenario: I disable my payment agreement
    Given I update the payment agreement with enabled: false, fixed_amount: "500"

    When the supplier confirms the line item
    And the supplier completes the supplier order

    Then a supplier payment should not exist

  Scenario: I don't have any payment agreements
    Given no payment agreements exist

    When the supplier confirms the line item
    And the supplier completes the supplier order

    Then a supplier payment should not exist

