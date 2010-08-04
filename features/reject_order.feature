Feature: Reject an order
  In order to notify stakeholders that I do not wish to process this order
           and i'm completely sure about my decision
  As a supplier
  I want to be able to reject an order by sending in a text message

  Background:
    Given a mobile_number exists with number: "66354668789", password: "1234"
    And a supplier exists with name: "Fon", mobile_number: the mobile_number
    And a supplier_order exists with id: 154674, supplier: the supplier

  Scenario: Reject an order
    When I text "rejectorder 1234 154674" from "66354668789"
    Then the supplier_order should not be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "confirm reject order" in "en" (English) where supplier: "Fon", order_number: "154674"

  Scenario Outline: Confirm rejecting an order
    When I text <text_message> from "66354668789"

    Then the supplier_order should be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "successfully processed order" in "en" (English) where supplier: "Fon", order_number: "154674", processed: "rejected"

      Examples:
      | text_message                       |
      | "rejectorder 1234 154674 CONFIRM!" |
      | "rejectorder 1234 154674 confirm!" |

  Scenario Outline: Try to reject an order forgetting the pin code or suppling an incorrect a pin code
    When I text <message_text> from "66354668789"

    Then the supplier_order should not be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of <error_message> in "en" (English)

    Examples:
    | message_text                         | error_message                      |
    | "rejectorder 1235 154674 1 x hy456n" | "mobile pin number incorrect"      |
    | "rejectorder x123 154674 1 x hy456n" | "mobile pin number format invalid" |
    | "rejectorder"                        | "mobile pin number blank"          |

  Scenario Outline: Try to confirm rejecting an order incorrectly
    When I text <text_message> from "66354668789"

    Then the supplier_order should not be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "confirmation invalid when rejecting an order" in "en" (English)

      Examples:
      | text_message                            |
      | "rejectorder 1234 154674 CONFIRM"       |
      | "rejectorder 1234 154674 anything else" |

  Scenario Outline: Try to reject an order which has been accepted or completed
    Given a supplier_order exists with id: 654789, supplier: the supplier, status: "<order_status>"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "<order_status>", supplier: "Fon"

    Examples:
      | text_message            | order_status  |
      | rejectorder 1234 654789 | accepted      |
      | rejectorder 1234 654789 | completed     |

  Scenario: Try to reject an order is already rejected
    Given a supplier_order exists with id: 654789, supplier: the supplier, status: "rejected"

    When I text "rejectorder 1234 654789" from "66354668789"
    Then the supplier_order should be rejected
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "rejected", supplier: "Fon"

