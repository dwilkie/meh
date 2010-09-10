Feature: Pay a supplier for a supplier order
  In order to pay my suppliers for orders they have processed
  As a seller
  I want to be able to pay suppliers automatically after they accept or complete a supplier order

  Background:
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Fon"
    And a mobile number: "Dave's number" exists with user: the seller
    And a mobile number: "Fon's number" exists with user: the supplier
    And a product exists with supplier: the supplier, seller: the seller, cents: "230000", currency: "THB", number: "19022331123", name: "Model Ship - The Titanic"
    And a supplier order exists for product: the product with quantity: 4

  Scenario Outline: I have set up a payment agreement between me and my supplier and I have configured and verified my payment application
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "<event>"
    And a verified payment application exists with seller: the seller
    And the supplier order <is_not_yet_or_was_already> accepted

    When the supplier <processes> the supplier order

    Then a payment should exist with supplier_order_id: the supplier order, cents: "920000", currency: "THB", seller_id: the seller, supplier_id: the supplier
    And a payment request should exist with payment_id: the payment

    Examples:
     | event                   | is_not_yet_or_was_already | processes |
     | product_order_accepted  | is not yet                | accepts   |
     | product_order_completed | was already               | completes |

  Scenario Outline: I have set up a payment agreement between me and my supplier but the product's supplier price is zero
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And the mobile number "Dave's number" <is_not_yet_or_was_already> verified
    And a verified payment application exists with seller: the seller
    And a product exists with supplier: the supplier, seller: the seller, cents: "0", number: "120848121933", name: "A Rubber Dingy"
    And a supplier order exists for product: the product with quantity: 4
    And the supplier order is not yet accepted

    When the supplier accepts the supplier order

    Then a payment should not exist
    And a payment request should not exist
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "4", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "amount would have been 0"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: I have set up a payment agreement between me and my supplier but I am yet to configure my payment application
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And the mobile number "Dave's number" <is_not_yet_or_was_already> verified
    And the supplier order is not yet accepted

    When the supplier accepts the supplier order

    Then a payment should not exist
    And a payment request should not exist
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "4", product_number: "19022331123", product_name: "Model Ship - The Titanic", errors: "Payment application settings have not yet been configured"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: I have set up a payment agreement between me and my supplier but I my payment application is not yet verified
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And a payment application exists with seller: the seller
    And the mobile number "Dave's number" <is_not_yet_or_was_already> verified
    And the supplier order is not yet accepted

    When the supplier accepts the supplier order

    Then a payment should not exist
    And a payment request should not exist
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "4", product_number: "19022331123", product_name: "Model Ship - The Titanic", errors: "Payment application settings have not yet been verified"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: I have set up a payment agreement between me and my supplier and I also set up another payment agreement for this particular product
    Given a payment agreement exists with seller: the seller, supplier: the supplier, enabled: true, event: "product_order_accepted"
    And a verified payment application exists with seller: the seller
    And a product exists with supplier: the supplier, seller: the seller, cents: "1200", currency: "THB"
    And a supplier order exists for product: the product with quantity: 4
    And a payment agreement exists with product: the product, enabled: <enabled>, event: "product_order_completed"
    And the supplier order <is_not_yet_or_was_already> accepted

    When the supplier <processes> the supplier order

    Then a payment <should_should_not> exist
    And a payment request <should_should_not> exist

    Examples:
     | enabled | is_not_yet_or_was_already | processes | should_should_not |
     | false   | is not yet                | accepts   | should not        |
     | true    | was already               | completes | should            |
     | false   | was already               | completes | should not        |

