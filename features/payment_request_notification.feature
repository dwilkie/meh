Feature: Payment Request Notification
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with email: "mara@gmail.com"
    And a supplier exists with email: "johnny@gmail.com"
    And a product exists with seller: the seller, supplier: the supplier, cents: "50000", currency: "THB"
    And a seller_order exists with seller: the seller
    And a supplier_order exists with supplier: the supplier, product: the product, quantity: "1"
    And a payment exists with cents: "50000", currency: "THB", supplier_order: the supplier_order, seller: the seller, supplier: the supplier
    And a payment_request exists with id: 234564, application_uri: "http://example.com", payment: the payment

  @current
  Scenario: A payment request notification is received
    When a payment request notification is received for 234564
    Then a job should exist to verify it came from my payment application

  Scenario: My payment application made the request
    Given the worker is about to process its job and verify the notification came from "http://example.com" regarding the payment request: "" and assuming my application made the request

    When the worker completes its job
    Then the payment request notification verification should have been sent
    And the payment_request should be verified

  Scenario: My payment application did not make the request
    Given the worker is about to process its job and verify the notification came from "http://example.com" regarding the payment request: "" and assuming my application did not make the request

    When the worker completes its job
    Then the payment request notification verification should have been sent
    But the payment_request should not be verified

