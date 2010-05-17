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
