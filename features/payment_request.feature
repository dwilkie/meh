Feature: Payment Request
  In order to transfer money to my suppliers
  As a seller
  I want be able to make payment requests to my external payment application

  Background:
    Given a seller exists
    And a supplier exists
    And a product exists with seller: the seller, supplier: the supplier, cents: "50000", currency: "THB"
    And a seller_order exists with seller: the seller
    And a supplier_order exists with supplier: the supplier, product: the product, quantity: "1"
    And a payment exists with cents: "50000", currency: "THB", supplier_order: the supplier_order, seller: the seller, supplier: the supplier

  Scenario: A payment request is created for my payment
     When a payment_request is created with id: 234564, application_uri: "http://example.com", payment: the payment
     Then a job should exist to notify my payment application

  Scenario: The worker processes its job
    Given the worker is about to process its job and send the payment request to "http://example.com"
    When the worker completes its job
    Then the payment request should have been sent

