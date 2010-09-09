Feature: Pay Supplier for Product Order
  In order to pay my suppliers for orders they have processed
  As a seller
  I want to be able to pay suppliers automatically after they accept or complete a supplier order

  Background:
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Fon"
    And a mobile number: "Dave's number" exists with user: the seller
    And a mobile number: "Fon's number" exists with user: the supplier, number: "66789098763"
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

  Scenario: Automatic payment when the seller also has an active payment application
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And a payment_application exists with seller: the seller, status: "active"

    When the supplier accepts the supplier_order

    Then a payment should exist
    And a payment_request should exist

  Scenario Outline: Automatic payment when seller also has payment application but it is not active
    Given there is a payment agreement set to automatic and to trigger when an order is accepted with seller: the seller, supplier: the supplier
    And a payment_application exists with seller: the seller, status: "<status>"

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
    And a payment exists with cents: 200000, currency: "KHR", supplier_order: the supplier_order, seller: the seller, supplier: the supplier

    When the supplier accepts the supplier_order

    Then 1 payments should exist with cents: 200000, currency: "KHR", supplier_order_id: the supplier_order, seller_id: the seller, supplier_id: the supplier
    And a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "payment already exists for this order" in "en" (English) where value: "154674"

