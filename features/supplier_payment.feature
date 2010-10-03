Feature: Supplier Payment
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with name: "Dave", email: "dave@example.com"
    And a mobile_number: "Dave's number" exists with user: the seller, number: "662233445353"
    And a supplier exists with name: "Fon"
    And a mobile_number: "Fon's number" exists with user: the supplier, number: "665323568467"
    And a product exists with seller: the seller, supplier: the supplier, number: "120848121933", name: "A Rubber Dingy"
    And a supplier order exists for the product with quantity: 1
    When a supplier payment is created with cents: "50000", currency: "THB", supplier_order: the supplier order, seller: the seller, supplier: the supplier
    Then the most recent job in the queue should be to send the supplier payment

  Scenario: The seller has sufficient funds to pay the supplier
    Given the seller has sufficient funds to pay the supplier

    When the worker works off the job

    Then the job should be deleted from the queue
    And the supplier payment should have a successful_payment

  Scenario Outline: The seller does not have sufficient funds to pay the supplier
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified
    And the seller does not have sufficient funds to pay the supplier

    When the worker works off the job

    Then the job should be deleted from the queue
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "paypal account: dave@example.com does not have sufficient funds in THB"
    And the seller should be that outgoing text message's payer

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: The seller has not permitted supplier payments
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified
    And the seller has not permitted supplier payments

    When the worker works off the job

    Then the job should be deleted from the queue
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "payment was unauthorized. We don't yet have your permission to make payments on your behalf"
   And the seller should be that outgoing text message's payer

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario: Paypal returns an unkown error
    Given the mobile number: "Dave's number" was already verified
    And paypal will not accept the payment request

    When the worker works off the job

    Then the job should be deleted from the queue
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include "paypal account returned the following unexpected error: "
    And the seller should be that outgoing text message's payer

