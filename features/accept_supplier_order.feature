Feature: Accept supplier order
  In order to notify my seller that I have received a supplier order (product order) and that I have confirmed the quantity and the item
  As a supplier
  I want to be able to accept a supplier order by sending in a text message

  Background:
    Given a mobile_number exists with number: "66354668874", password: "1234"
    And a seller exists
    And a supplier exists with name: "Nok", mobile_number: the mobile_number
    And a product exists with verification_code: "hy456n", supplier: the supplier, seller: the seller
    And a supplier_order: "first order" exists with id: 154674, product: the product, quantity: 3

  Scenario Outline: Accept an order explicitly by giving the supplier order number
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "accepted", supplier_order_number: 154674

  Examples:
    | message_text                               |
    | supplier_order accept 1234 154674 3 hy456n |
    | product_order accept 1234 154674 3 hy456n  |
    | supplier_order a 1234 154674 3 hy456n      |
    | product_order a 1234 154674 3 hy456n       |
    | accept_supplier_order 1234 154674 3 hy456n |
    | accept_product_order 1234 154674 3 hy456n  |
    | po accept 1234 154674 3 hy456n             |
    | po a 1234 154674 3 hy456n                  |
    | apo 1234 154674 3 hy456n                   |

  Scenario Outline: Accept an order implicitly by omitting the supplier order number
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "accepted", supplier_order_number: 154674

  Examples:
    | message_text                        |
    | supplier_order accept 1234 3 hy456n |
    | product_order accept 1234 3 hy456n  |
    | supplier_order a 1234 3 hy456n      |
    | product_order a 1234 3 hy456n       |
    | accept_supplier_order 1234 3 hy456n |
    | accept_product_order 1234 3 hy456n  |
    | po accept 1234 3 hy456n             |
    | po a 1234 3 hy456n                  |
    | apo 1234 3 hy456n                   |

  Scenario Outline: Try to accept an order implicitly by omitting the supplier order number with multiple unconfirmed supplier orders
    Given a supplier_order: "second order" exists with id: 154675, product_id: the product, quantity: 3

    When I text "<message_text>" from "66354668874"

    Then the supplier_order: "first order" should not be accepted
    And the supplier_order: "second order" should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "be specific about the supplier order number" in "en" (English) where supplier_name: "Nok", human_action: "accept", topic: "<topic>", action: "<action>"

  Examples:
    | message_text                        | topic          | action |
    | supplier_order accept 1234 3 hy456n | supplier_order | accept |
    | product_order accept 1234 3 hy456n  | product_order  | accept |
    | supplier_order a 1234 3 hy456n      | supplier_order | a      |
    | product_order a 1234 3 hy456n       | product_order  | a      |
    | accept_supplier_order 1234 3 hy456n | supplier_order | accept |
    | accept_product_order 1234 3 hy456n  | product_order  | accept |
    | po accept 1234 3 hy456n             | po             | accept |
    | po a 1234 3 hy456n                  | po             | a      |
    | apo 1234 3 hy456n                   | po             | a      |

  Scenario Outline: Try to accept an order suppling an incorrect a pin number
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "your pin number is incorrect" in "en" (English) where topic: "<topic>", action: "<action>"

  Examples:
    | message_text                    | topic         | action  |
    | po a 3 hy456n                   | po            | a       |
    | accept_product_order 3 hy456n   | product_order | accept  |
    | apo 3 hy456n                    | po            | a       |
    | apo                             | po            | a       |
    | apo 1235                        | po            | a       |

  Scenario Outline: Try to accept an order forgetting to supply an action
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "what would you like to do with the supplier order?" in "en" (English) where topic: "<message_text>"

  Examples:
    | message_text                   |
    | product_order                  |
    | po                             |

  Scenario Outline: Try to accept an order supplying an invalid action
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "invalid action given for the supplier order" in "en" (English) where topic: "<topic>", action: "<action>"

  Examples:
    | message_text                    | topic         | action |
    | product_order z                 | product_order | z      |
    | po 4                            | po            | 4      |

  Scenario Outline: Try to accept an order giving the wrong quantity
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "<response>" in "en" (English) <where>

  Examples:
    | message_text                 |  response    | where             |
    | apo 1234 154674 2 hy456n     | is incorrect | where value: "2"  |
    | apo 1234 2 hy456n            | is incorrect | where value: "2"  |
    | ProductOrder a 1234 2 hy456n | is incorrect | where value: "2"  |

  Scenario Outline: Try to accept an order omitting the quantity
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "<response>" in "en" (English)

  Examples:
    | message_text             |  response                   |
    | apo 1234 154674          | order quantity is blank     |
    | apo 1234                 | order quantity is blank     |
    | ProductOrder a 1234      | order quantity is blank     |


  Scenario Outline: Try to accept an order giving the wrong product verification code
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "<response>" in "en" (English) <where>

  Examples:
    | message_text                 | response     | where                 |
    | apo 1234 154674 3 hy456      | is incorrect | where value: "hy456"  |
    | apo 1234 3 hy456m            | is incorrect | where value: "hy456m" |
    | ProductOrder a 1234 3 hy456p | is incorrect | where value: "hy456p" |

  Scenario Outline: Accept an order giving the correct product verification code but the incorrect case
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be accepted

  Examples:
    | message_text                 |
    | apo 1234 154674 3 hy456N     |
    | apo 1234 3 hY456n            |
    | ProductOrder a 1234 3 HY456N |

 Scenario: Try to explicity accept an order which was already completed
    Given the supplier_order was already completed

    When I text "apo 1234 154674 3 hy456n" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "supplier order was already confirmed" in "en" (English) where status: "completed", supplier_name: "Nok"

 Scenario: Try to implicitly accept an order which was already completed
    Given the supplier_order was already completed

    When I text "apo 1234 3 hy456n" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Nok", status: "unconfirmed"

 Scenario: Try to explicitly accept an order which was already accepted
    Given the supplier_order was already accepted

    When I text "apo 1234 154674 3 hy456n" from "66354668874"

    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "supplier order was already confirmed" in "en" (English) where status: "accepted", supplier_name: "Nok"

 Scenario: Try to implicitly accept an order which was already accepted
    Given the supplier_order was already accepted

    When I text "apo 1234 3 hy456n" from "66354668874"

    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Nok", status: "unconfirmed"

