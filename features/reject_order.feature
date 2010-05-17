Feature: Reject an order
  In order Reject an order without using the Internet
  As a supplier
  I want to be able to reject an order by sending a text message

  Background:
    Given a supplier exists with name: "Fon"
    And a mobile_number exists with number: "66354668789", phoneable: the supplier

  Scenario: Reject an order for a sellers product
    Given a seller exists with name: "Dave"
    And a product exists with seller: the seller, supplier: the supplier
    And a supplier_order exists with id: 154674, supplier: the supplier, product: the product
    When I text "rejectorder 154674" from "66354668789"
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of "confirm reject order for sellers product" in "en" (English) where supplier: "Fon", seller: "Dave", order_number: "154674"

  Scenario: Reject an order for own product
    Given the supplier is also a seller
    And a product exists with seller: the supplier, supplier: the supplier
    And a supplier_order exists with id: 154674, supplier: the supplier, product: the product
    When I text "rejectorder 154674" from "66354668789"
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of "confirm reject order for own product" in "en" (English) where supplier: "Fon", order_number: "154674"
    
  Scenario Outline: Confirm rejecting an order
    Given a supplier_order exists with id: 654778, supplier: the supplier
    When I text <text_message> from "66354668789"
    Then the order should be rejected
    
      Examples:
      | text_message                  |
      | "rejectorder 654778 CONFIRM!" |
      | "rejectorder 654778 confirm!" |
