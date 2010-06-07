Feature: Payment Request Verification
  In order to prevent unauthorized payment requests made to my external payment application from being executed
  As a seller
  I want to verify that the payment request was made by this application

  Background:
    Given a seller exists with email: "mara@gmail.com"
    And a supplier exists with email: "johnny@gmail.com"
    And the seller has an active payment application with uri: "http://example.com"
    And a product exists with seller: the seller, supplier: the supplier, cents: "50000", currency: "THB"
    And a seller_order exists with seller: the seller
    And a supplier_order exists with supplier: the supplier, product: the product, quantity: "1"
    And a payment exists with cents: "50000", currency: "THB", supplier_order: the supplier_order, seller: the seller, supplier: the supplier
    
  Scenario: Payment request verification is made with correct parameters
    Given a payment_request exists with id: 234564, application_uri: "http://example.com", payment: the payment, status: "requested"
    When a payment request verification is made for 234564 with amount: "500.00", currency: "THB", to: "johnny@gmail.com", sender: "mara@gmail.com"
    Then the response should be 200
    
  Scenario: Payment request verification is made with correct parameters but for a payment request which has already been completed
    Given a payment_request exists with id: 234564, application_uri: "http://example.com", payment: the payment, status: "completed"
    When a payment request verification is made for 234564 with amount: "500.00", currency: "THB", to: "johnny@gmail.com", sender: "mara@gmail.com"
    Then the response should be 404
      
  Scenario: Payment request verification is made for unknown resource
    Given a payment_request exists with id: 234564, application_uri: "http://example.com", payment: the payment, status: "requested"
    When a payment request verification is made for 234563
    Then the response should be 404

  Scenario Outline: Payment request verification is made for correct resource with incorrect parameters
    Given a payment_request exists with id: 234564, application_uri: "http://example.com", payment: the payment, status: "requested"
    When a payment request verification is made for 234564 with <parameters>
    Then the response should be 404
    
    Examples:
      | parameters                                                                          |
      | amount: "500.01", currency: "THB", to: "johnny@gmail.com", sender: "mara@gmail.com" |
      | amount: "500.00", currency: "USD", to: "johnny@gmail.com", sender: "mara@gmail.com" |
      | amount: "500.00", currency: "THB", to: "johnny2@gmail.com", sender: "mara@gmail.com" |
      | amount: "500.00", currency: "THB", to: "johnny@gmail.com", sender: "mar@gmail.com" |
