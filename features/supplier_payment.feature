Feature: Supplier Payment
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with name: "Dave", email: "dave@example.com"
    And a verified mobile_number: "Dave's number" exists with user: the seller, number: "66823344533"
    And a supplier exists with name: "Fon"
    And a verified mobile_number: "Fon's number" exists with user: the supplier, number: "66823568467"
    And a confirmed partnership exists with seller: the seller, supplier: the supplier
    And a product exists with seller: the seller, partnership: the partnership
    And a line item exists for that product
    Then a supplier order should exist

    Given a payment agreement exists with seller: the seller, supplier: the supplier, fixed_amount: "500"
    And the line item was already confirmed
    Then a supplier payment should exist
    And a job should exist to send the supplier payment

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
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include a translation of "insufficient funds for supplier payment" in "en" (English) where seller_email: "dave@example.com", currency: "USD"
    And the outgoing text message should <be_or_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario: The seller has not permitted supplier payments
    Given the seller has not permitted supplier payments

    When the worker works off the job

    Then the job should be deleted from the queue
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include a translation of "unauthorized supplier payment" in "en" (English)
   And the seller should be that outgoing text message's payer

  Scenario: Paypal returns an unkown error
    Given paypal will not accept the payment request

    When the worker works off the job

    Then the job should be deleted from the queue
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include a translation of "unknown error for supplier payment" in "en" (English) where error: "Currency is not supported"
    And the seller should be that outgoing text message's payer

