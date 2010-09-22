Feature: Payment Agreement
  In order to pay my suppliers automatically for orders they receive or process
  As a seller
  I want to be able set up payment agreements to pay suppliers when a supplier order is created or after the supplier accepts or completes a supplier order

  Background:
    Given a seller exists with name: "Dave"
    And a supplier: "Fon" exists with name: "Fon"
    And a mobile number exists with user: the seller
    And a product exists with supplier: the supplier, seller: the seller, cents: "230000", currency: "THB", number: "19022331123", name: "Model Ship - The Titanic"
    And a supplier order exists for the product with quantity: 4

  Scenario Outline: I have set up a payment agreement with my supplier
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "<event>"
    And the supplier order <is_not_yet_or_was_already> accepted

    When the supplier <processes> the supplier order

    Then a supplier payment should exist with supplier_order_id: the supplier order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier
    And the most recent job in the queue should be to send the supplier payment

    Examples:
     | event                   | is_not_yet_or_was_already | processes |
     | product_order_accepted  | is not yet                | accepts   |
     | product_order_completed | was already               | completes |

  Scenario: I have set up a payment agreement for when a product order is created
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_created"
    And a product exists with supplier: the supplier, seller: the seller, cents: "1200", currency: "THB"

    When a supplier order is created for the product with quantity: 1

    Then a supplier payment should exist with supplier_order_id: the supplier order, cents: "1200", currency: "THB", seller_id: the seller, supplier_id: the supplier
    And the most recent job in the queue should be to send the supplier payment

  Scenario Outline: I have set up a payment agreement with my supplier but the product's supplier price is zero
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And the mobile number <is_not_yet_or_was_already> verified
    And a product exists with supplier: the supplier, seller: the seller, cents: "0", number: "120848121933", name: "A Rubber Dingy"
    And a supplier order exists for the product with quantity: 4
    And the supplier order is not yet accepted

    When the supplier accepts the supplier order

    Then a supplier payment should not exist
    And the most recent outgoing text message destined for the mobile number should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "4", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "amount would have been 0"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: I have set up a payment agreement with my supplier and I also set up another payment agreement for the product in this order
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And a product exists with supplier: the supplier, seller: the seller, cents: "1200", currency: "THB"
    And a supplier order exists for the product with quantity: 4
    And a payment agreement exists with product: the product, enabled: <enabled>, event: "product_order_completed"
    And the supplier order <is_not_yet_or_was_already> accepted

    When the supplier <processes> the supplier order

    Then a supplier payment <should_should_not> exist
    And the most recent job in the queue <should_should_not> be to send the supplier payment

    Examples:
     | enabled | is_not_yet_or_was_already | processes | should_should_not |
     | false   | is not yet                | accepts   | should not        |
     | true    | was already               | completes | should            |
     | false   | was already               | completes | should not        |

  Scenario: I have set up a payment agreement with my supplier and I also set up another payment agreement for a product which is not in this order
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And the mobile number was already verified
    And a product exists with supplier: the supplier, seller: the seller, cents: "1200", currency: "THB"
    And a payment agreement exists with product: the product, enabled: true, event: "product_order_completed"
    And the supplier order was already accepted

    When the supplier completes the supplier order

    Then 1 supplier payments should exist
    And the most recent outgoing text message destined for the mobile number should not include "we didn't pay"

  Scenario: I have set up a payment agreement with another supplier who is not the supplier for this order
    Given a supplier exists
    And a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And the supplier order is not yet accepted

    When the supplier: "Fon" accepts the supplier order

    Then a supplier payment should not exist
    And the most recent job in the queue should not be to send the supplier payment

  Scenario: I am also the supplier for this order
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And a product exists with supplier: the seller, seller: the seller, cents: "1200", currency: "THB"
    And a supplier order exists for the product with quantity: 4
    And the supplier order is not yet accepted

    When I accept the supplier order

    Then a supplier payment should not exist
    And the most recent job in the queue should not be to send the supplier payment

  Scenario: I have not yet set up any payment agreements
    Given the supplier order is not yet accepted

    When the supplier accepts the supplier order

    Then a supplier payment should not exist
    And the most recent job in the queue should not be to send the supplier payment

