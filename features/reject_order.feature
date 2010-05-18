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
    
    Then the supplier_order should not be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "confirm reject order for seller's product" in "en" (English) where supplier: "Fon", seller: "Dave", order_number: "154674"

  Scenario: Reject an order for own product
    Given the supplier is also a seller
    And a product exists with seller: the supplier, supplier: the supplier
    And a supplier_order exists with id: 154674, supplier: the supplier, product: the product
    When I text "rejectorder 154674" from "66354668789"
    
    Then the supplier_order should not be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "confirm reject order for own product" in "en" (English) where supplier: "Fon", order_number: "154674"
    
  Scenario Outline: Confirm rejecting an order
    Given a supplier_order exists with id: 654778, supplier: the supplier
    When I text <text_message> from "66354668789"
    Then the supplier_order should be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "successfully rejected order" in "en" (English) where supplier: "Fon", order_number: "654778"
    
      Examples:
      | text_message                  |
      | "rejectorder 654778 CONFIRM!" |
      | "rejectorder 654778 confirm!" |
  
  Scenario: Confirm rejecting an order for a sellers product
    Given a seller exists with name: "Dave"
    And a mobile_number: "seller's number" exists with phoneable: the seller
    And a product exists with seller: the seller, supplier: the supplier, external_id: "567864ab"
    And a supplier_order exists with id: 154674, supplier: the supplier, product: the product
    When I text "rejectorder 154674 confirm!" from "66354668789"
    Then a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be a translation of "supplier rejected sellers order" in "en" (English) where seller: "Dave", supplier: "Fon", supplier_contact_details: "+66354668789", order_number: "154674", product_code: "567864ab"
  
  Scenario Outline: Try to confirm rejecting an order incorrectly
    Given a supplier_order exists with id: 654778, supplier: the supplier
    When I text <text_message> from "66354668789"
    Then the supplier_order should not be rejected
    
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "confirmation invalid when rejecting an order" in "en" (English) 
    And the outgoing_text_message should include "Fon"

      Examples:
      | text_message                       |
      | "rejectorder 654778 CONFIRM"       |
      | "rejectorder 654778 anything else" |
