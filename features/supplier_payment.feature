Feature: Supplier Payment
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with name: "Dave"
    And a mobile_number: "Dave's number" exists with user: the seller, number: "662233445353"
    And a supplier exists with name: "Fon", email: "fon@example.com"
    And a mobile_number: "Fon's number" exists with user: the supplier, number: "665323568467"
    And a product exists with seller: the seller, supplier: the supplier, number: "120848121933", name: "A Rubber Dingy"
    And a supplier order exists for the product with quantity: 1
    When a supplier payment is created with cents: "50000", currency: "THB", supplier_order: the supplier order, seller: the seller, supplier: the supplier
    Then the most recent job in the queue should be to send the supplier payment

  @current
  Scenario Outline: The seller does not have sufficient funds to pay the supplier
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified
    And seller does not have sufficient funds to pay the supplier

    When the worker works off the job

    Then the job should be deleted from the queue
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "email address dave@example.com is invalid. It may not be registered in PayPals system yet"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: The seller has sufficient funds to pay the supplier
    Given the mobile number: "Dave's number" <seller_number_verified> verified
    And the mobile number: "Fon's number" <supplier_number_verified> verified
    And the seller has sufficient funds to pay the supplier

    When the worker works off the job

    Then the job should be deleted from the queue
    And the supplier payment should be successful
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <send_seller_message>
    """
    Hi Dave, a payment of 500.00 THB was made to Fon (<supplier_number>) for 1 x 120848121933 (A Rubber Dingy) which belongs to your customer order: #1
    """

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should <send_supplier_message>
    """
    Hi Fon, you have received a payment of 500.00 THB from Dave (<seller_number>) for your product order: #1
    """

    Examples:
     | seller_number_verified | seller_number | supplier_number_verified |supplier_number | send_seller_message | send_supplier_message |
     | was already | +662233445353 | was already | +665323568467 | be | be |
     | was already | +662233445353 | is not yet  | No verified number! | be | not be |
     | is not yet  | No verified number! | was already | +665323568467 | not be | be |
     | is not yet  | No verified number! | is not yet  | No verified number! | not be | not be |

