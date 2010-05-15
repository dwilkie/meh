Feature: Allow the supplier to respond by text message to an order notification
  In order to confirm or reject an order without using the Internet
  As a supplier
  I want to be able to confirm or reject an order by sending a text message
  
  Background:
    Given a supplier exists
    And a mobile_number exists with number: "66354668789", phoneable: the supplier
    And a product exists with external_id: "12345", verification_code: "hy456n"
    And an order exists with supplier_id: the supplier, product_id: the product, quantity: 1
    # We should implement validation on the order that ensures that the supplier
    # is the same as the product supplier...this will then brake which is ok...

  Scenario: Confirm an order correctly
    When I text "acceptorder 1 1 hy456n" from "66354668789"
    Then the order should be confirmed
   
  Scenario Outline: Confirm an order incorrectly
    When I text <message_text> from "66354668789"
    Then the order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of <response> in "en" (English) <where>

  Examples:
    | message_text              | response                      | where            |
    | "acceptorder 2 1 hyn456n" | "incorrect order number"      |                  |
    | "acceptorder 1 2 hyn456n" | "non matching order quantity" | value: "2"       |
    | "acceptorder 1 1 hyn456a" | "non matching pv code"        | value: "hyn456a" |
    
  # See if you can turn the background off for these scenaros
  Scenario: Try to accept or reject an order as a non supplier
    Given a seller exists
    And a mobile_number exists with phoneable: the seller, number: "66354668790"
    
    When I text "acceptorder 1 1 hy456n" from "66354668790"
    Then the order should not be confirmed
    
  Scenario: Try to accept or reject an order not belonging to me
    Given a supplier exists
    And a mobile_number exists with phoneable: the supplier, number: "66354668790"

    When I text "acceptorder 1 1 hy456n" from "66354668790"
    Then the order should not be confirmed

  Scenario: Try to accept an order which belongs to me as a seller but not as a supplier

  # Try to accept a confirmed order
  
