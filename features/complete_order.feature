Feature: Complete an order
  In order to notify stakeholders that I have completed processing this order and
  send them any other relevant information
  As a supplier
  I want to be able to complete an order by sending in a text message

  Background:
    Given a mobile_number exists with number: "66354668789", password: "1234"
    And a supplier exists with name: "Nok", mobile_number: the mobile_number
    And a product exists with supplier_id: the supplier

  Scenario Outline: Complete an order
    Given a supplier_order exists with id: 154674, product_id: the product, status: "accepted"
    When I text "<text_message>" from "66354668789"

    Then the supplier_order should be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "successfully processed order" in "en" (English) where supplier: "Nok", order_number: "154674", processed: "completed"

    Examples:
      | text_message                             |
      | completeorder 1234 154674 cp246589912th  |
      | completeorder 1234 154674 re142325512th  |

  Scenario Outline: Try to complete an order forgetting the pin code or suppling an incorrect a pin code
    Given a supplier_order exists with id: 154674, product_id: the product, status: "accepted"
    When I text <message_text> from "66354668789"

    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of <error_message> in "en" (English)

    Examples:
    | message_text                              | error_message                      |
    | "completeorder 1235 154674 re246589912th" | "mobile pin number incorrect"      |
    | "completeorder x123 154674 re246589912th" | "mobile pin number format invalid" |
    | "completeorder"                           | "mobile pin number blank"          |

  Scenario Outline: Try to complete an order with an invalid tracking number
    Given a supplier_order exists with id: 654789, product_id: the product, status: "accepted"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "invalid attribute" in "en" (English)

    Examples:
      | text_message                             |
      | completeorder 1234 654789 rd246589912th  |
      | completeorder 1234 654789 re2465899124th |
      | completeorder 1234 654789 re246589912ti  |

  Scenario Outline: Try to complete an order which has not been accepted
    Given a supplier_order exists with id: 654789, product_id: the product, status: "<order_status>"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "<order_status>", supplier: "Nok"

    Examples:
      | text_message                            | order_status |
      | completeorder 1234 654789 re246589912th | rejected     |
      | completeorder 1234 654789 re246589912th | unconfirmed  |

  Scenario: Try to complete an order which was already completed
    Given a supplier_order exists with id: 654789, product_id: the product, status: "completed"

    When I text "completeorder 1234 654789 re246589912th" from "66354668789"
    Then the supplier_order should be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "completed", supplier: "Nok"

