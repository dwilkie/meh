Feature: Payment Request
  In order to transfer money to my suppliers
  As a seller
  I want be able to make payment requests to my external payment application

  Background: A payment is created
    When a payment is created

    Then a payment request should exist with payment_id: the payment
    And the most recent job in the queue should be to create a remote payment request

  Scenario: The remote payment application is up
    Given the remote payment application is up

    When the worker works off the job

    Then the job should be deleted from the queue
    And the time when the first attempt to contact the remote payment application occurred should be recorded

  Scenario: The remote payment application is down
    Given the remote payment application is down

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the job's attempts should be "1"
    And the time when the first attempt to contact the remote payment application occurred should be recorded

  Scenario Outline: The worker gives up trying to contact the remote payment application
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Fon"
    And a mobile number exists with user: the seller
    And the mobile number <is_not_yet_or_was_already> verified
    And a verified payment application exists with seller: the seller, uri: "http://dave-payment-app-example.com"
    And a product exists with number: "120848121933", name: "A Rubber Dingy", seller: the seller, supplier: the supplier, cents: "200"
    And a supplier order exists for the product with quantity: 1

    When a payment is created with supplier_order: the supplier order, seller: the seller, supplier: the supplier

    Then a payment request should exist with payment_id: the payment
    And the most recent job in the queue should be to create a remote payment request

    Given the remote payment application <is_status>

    When the worker <works_off> the job

    Then the job should be deleted from the queue
    And the payment request should have given_up
    And the most recent outgoing text message destined for the mobile number should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "url (http://dave-payment-app-example.com/payment_requests) can't be found"

    Examples:
     | is_status | works_off | is_not_yet_or_was_already   | be_or_not_be |
     | is down   | tries 9 times to work off | is not yet  | not be       |
     | is down   | tries 9 times to work off | was already | be           |
     | does not respond to the create remote payments url with status code 200 | works off | is not yet       | not be |
     | does not respond to the create remote payments url with status code 200 | works off | was already      | be     |

