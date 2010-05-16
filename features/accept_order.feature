Feature: Accept an order
  In order Accept an order without using the Internet
  As a supplier
  I want to be able to accept an order by sending a text message
  
  Background:
    Given a supplier exists
    And a mobile_number exists with number: "66354668789", phoneable: the supplier
    And a product exists with external_id: "12345", verification_code: "hy456n"
    And a supplier_order exists with id: 154674, supplier: the supplier, product_id: the product, quantity: 1

  Scenario Outline: Accept an order correctly
    When I text <message_text> from "66354668789"
    Then the supplier_order should be confirmed

  Examples:
    | message_text                    |
    | "acceptorder 154674 1 x hy456n" |
    | "acceptorder 154674 1 hy456n"   |
    | "acceptorder 154674 1x hy456n"  |

  Scenario Outline: Try to accept an order with the wrong quantity or pv code
    When I text <message_text> from "66354668789"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should include a translation of <response> in "en" (English) <where>

  Examples:
    | message_text                     |  response                     | where             |
    | "acceptorder 154674 2 x hyn456n" | "not matching order quantity" | where value: "2"  |
    | "acceptorder 154674 1 x hyn456a" | "not matching pv code"   | where value: "hyn456a" |
    
  Scenario: Try to accept an order with an incorrect order number
    When I text "acceptorder 154673 1 x hyn456n" from "66354668789"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should include a translation of "order not found when accepting order" in "en" (English)

  Scenario: Try to accept an order as a seller
    Given a seller exists
    And a mobile_number exists with phoneable: the seller, number: "66354668790"
    
    When I text "acceptorder 154674 1 x hy456n" from "66354668790"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of "unauthorized message action" in "en" (English) where action: "accept orders"
    
  Scenario: Try to accept an order not belonging to me
    Given a supplier exists
    And a mobile_number exists with phoneable: the supplier, number: "66354668790"

    When I text "acceptorder 154674 x hy456n" from "66354668790"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should include a translation of "order not found when accepting order" in "en" (English)

  Scenario: Try to accept an order which belongs to me as a seller but not as a supplier
    Given a seller exists
    And the seller is also a supplier
    And a supplier exists
    And a seller_order exists with seller_id: the seller
    And a supplier_order exists with id: 654789, supplier_id: the supplier, product_id: the product, seller_order_id: the seller_order
    And a mobile_number exists with phoneable: the seller, number: "66354668790"

    When I text "acceptorder 654789 1 x hy456n" from "66354668790"
    Then the supplier_order should not be confirmed
    And the seller_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should include a translation of "order not found when accepting order" in "en" (English)

  Scenario: Try to accept an already confirmed order
    Given a supplier exists
    And a mobile_number exists with phoneable: the supplier, number: "66354668790"
    And a product exists with supplier: the supplier, verification_code: "xcvbyu"
    And a supplier_order exists with id: 654789, quantity: 5, product: that product, supplier: the supplier, status: "accepted"
    
    When I text "acceptorder 654789 5 x xcvbyu" from "66354668790"
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of "order already confirmed" in "en" (English) where confirmation: "accepted"
