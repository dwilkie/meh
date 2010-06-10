Feature: Payment Request Notification
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with email: "mara@gmail.com"
    And a supplier exists with email: "johnny@gmail.com"
    And the seller has an active payment application with uri: "http://example.com"
    And a product exists with seller: the seller, supplier: the supplier, cents: "50000", currency: "THB"
    And a seller_order exists with seller: the seller
    And a supplier_order exists with supplier: the supplier, product: the product, quantity: "1"
    And a payment exists with cents: "50000", currency: "THB", supplier_order: the supplier_order, seller: the seller, supplier: the supplier
    And a payment_request exists with id: 234564, application_uri: "http://example.com", payment: the payment, status: "requested"

  @current
  Scenario: A payment request notification is received
    When a payment request notification is received for 234564

    Then the payment request should be answered
    But the payment request response should not be verified

