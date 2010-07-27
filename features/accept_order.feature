Feature: Accept an order
  In order to notify stakeholders that I wish to process this order
           and I have looked up which product belongs to the order
  As a supplier
  I want to be able to accept an order by sending in a text message

  Background:
    Given a mobile_number exists with number: "66354668789", password: "1234"
    And a supplier exists with name: "Nok", mobile_number: the mobile_number

    And a product exists with external_id: "12345", verification_code: "hy456n"
    And a supplier_order exists with id: 154674, supplier: the supplier, product_id: the product, quantity: 1

  Scenario Outline: Accept an order correctly
    When I text <message_text> from "66354668789"

    Then the supplier_order should be accepted

  Examples:
    | message_text                          |
    | "acceptorder 1234 154674 1 x hy456n"  |
    | "acceptorder 1234 154674 1 hy456n"    |
    | "acceptorder 1234 154674 1x hy456n"   |
    | "acceptorder 1234 #154674 1x hy456n"  |

  Scenario Outline: Try to accept an order forgetting the pin code or suppling an incorrect a pin code
    When I text <message_text> from "66354668789"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of <error_message> in "en" (English)

    Examples:
    | message_text                         | error_message                      |
    | "acceptorder 1235 154674 1 x hy456n" | "mobile pin number incorrect"      |
    | "acceptorder x123 154674 1 x hy456n" | "mobile pin number format invalid" |
    | "acceptorder"                        | "mobile pin number blank"          |

  Scenario Outline: Try to accept an order with the wrong quantity or pv code
    When I text <message_text> from "66354668789"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of <response> in "en" (English) <where>

  Examples:
    | message_text                          |  response                     | where             |
    | "acceptorder 1234 154674 2 x hy456n"  | "not matching order quantity" | where value: "2"  |
    | "acceptorder 1234 154674 1 x hy456m"  | "not matching pv code"    | where value: "hy456m" |

 Scenario Outline: Try to accept an order which has been rejected or completed
    Given a supplier_order exists with id: 154670, supplier: the supplier, product_id: the product, quantity: 2, status: "<order_status>"

    When I text "<text_message>" from "66354668789"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "<order_status>", supplier: "Nok"

    Examples:
      | text_message                       | order_status |
      | acceptorder 1234 154670 2 x hy456n | rejected     |
      | acceptorder 1234 154670 2 x hy456n | completed    |

 Scenario: Try to accept an order which is already accepted
    Given a supplier_order exists with id: 154670, supplier: the supplier, product_id: the product, quantity: 2, status: "accepted"

    When I text "acceptorder 1234 154670 2 x hy456n" from "66354668789"
    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "accepted", supplier: "Nok"

