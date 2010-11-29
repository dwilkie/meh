Feature: Complete a supplier order
  In order to notify my seller that I have completed processing a supplier and to submit the tracking number if applicable
  As a supplier
  I want to be able to complete a supplier order by sending in a text message

  Background:
    Given a supplier exists with name: "Nok"
    And a verified mobile number: "Nok's number" exists with number: "66354668874", user: the supplier
    And a seller exists with name: "Mara"
    And a verified mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", supplier: the supplier, seller: the seller
    And a line item exists for the product with quantity: 1
    Then a supplier order should exist
    And a seller order should exist
    Given the supplier order was already confirmed

  Scenario Outline: Complete an order implicitly
    When I text "<message_text>" from "66354668874"

    Then the seller order should be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be
    """
    Thanks Nok, Order #1 has been marked as shipped
    """
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Order #1 has been shipped by Nok (+66354668874).
    """
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text    |
      | order complete  |
      | o complete      |
      | order c         |
      | o c             |
      | complete order  |
      | complete o      |
      | c order         |
      | c o             |
      | corder          |
      | co              |

  Scenario Outline: Complete an order explicitly
    When I text "<message_text>" from "66354668874"

    Then the seller order should be completed

    Examples:
      | message_text     |
      | order complete 1 |
      | o complete 1     |
      | order c 1        |
      | o c 1            |
      | complete order 1 |
      | complete o 1     |
      | c order 1        |
      | c o 1            |
      | corder 1         |
      | co 1             |

  Scenario Outline: Complete an order explicity whilst having multiple incomplete orders
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product

    When I text "<message_text>" from "66354668874"

    Then the seller order should be completed

    Examples:
      | message_text     |
      | order complete 1 |
      | o complete 1     |
      | order c 1        |
      | o c 1            |
      | complete order 1 |
      | complete o 1     |
      | c order 1        |
      | c o 1            |
      | corder 1         |
      | co 1             |

  @current
  Scenario Outline: Try to complete an order implicitly whilst having multiple incomplete orders
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product with quantity: 1

    When I text "<message_text>" from "66354668874"

    Then the seller order should not be completed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should be a translation of "be specific about the order number" in "en" (English) where supplier_name: "Nok", topic: "<topic>", action: <action>, params: <params>
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text   | topic | action | params     |
      | co             | o     | "c"    | ""         |
      | corder RE23123 | order | "c"    | " RE23123" |

  Scenario: Be the last to complete an order belonging to multiple suppliers
    Given a supplier exists with name: "Andy"
    And a verified mobile number: "Andy's number" exists with number: "61444431123", user: the supplier
    And a supplier order exists with seller_order: the seller order, supplier: the supplier
    And a product exists with seller: the seller, supplier: the supplier
    And the supplier order was already confirmed

    When I text "co" from "61444431123"

    Then the seller order should not be completed

    When I text "co" from "66354668874"

    Then the seller order should be completed
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Order #1 has been shipped by Nok (+66354668874) and Andy (+61444431123).
    """
    And the seller should be that outgoing text message's payer

  Scenario Outline: Complete an order providing a tracking number
    Given a tracking number format exists with seller: the seller, format: "^(re|cp)\\d{9}th$"
    When I text "<message_text>" from "66354668874"

    Then the supplier order's tracking_number should be "<tracking_number>"
    And the seller order should be completed
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Order #1 has been shipped by Nok (+66354668874). Tracking # <tracking_number>
    """
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text          | tracking_number |
      | co 1 re123456789th    | re123456789th   |
      | c order RE123456789TH | RE123456789TH   |

  Scenario: Be the last to complete an order with a tracking number belonging to multiple suppliers
    Given a tracking number format exists with seller: the seller, supplier: the supplier, format: "^(re|cp)\\d{9}th$"
    And a supplier exists with name: "Andy"
    And a verified mobile number: "Andy's number" exists with number: "61444431123", user: the supplier
    And a supplier order exists with seller_order: the seller order, supplier: the supplier
    And a product exists with seller: the seller, supplier: the supplier
    And the supplier order was already confirmed

    When I text "co" from "61444431123"

    Then the seller order should not be completed

    When I text "co re123456789th" from "66354668874"

    Then the seller order should be completed
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Order #1 has been shipped by Nok (+66354668874) and Andy (+61444431123). Tracking # re123456789th and N/A
    """
    And the seller should be that outgoing text message's payer

  Scenario Outline: Try to complete an order with a tracking number that I already used before
    Given the line item was already confirmed
    And the supplier order was already completed
    And I update the supplier order with tracking_number: "re123456789th"
    And another seller exists
    And a product exists with seller: the seller, supplier: the supplier
    And a line item exists for that product
    And that line item was already confirmed
    And a tracking number format exists with seller: the seller
    Then a seller order should exist with seller: the seller

    When I text "<message_text>" from "66354668874"

    Then the seller order should not be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should include a translation of "tracking number already used by you" in "en" (English) where value: "<tracking_number>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text       | tracking_number |
      | co re123456789th   | re123456789th   |
      | co 2 RE123456789TH | RE123456789TH   |

  Scenario Outline: Try to complete an order with a tracking number that is invalid
    Given a tracking number format exists with seller: the seller, format: "^(re|cp)\\d{9}th$"

    When I text "<message_text>" from "66354668874"

    Then the seller order should not be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should include a translation of "tracking number is invalid" in "en" (English) where value: "<tracking_number>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text              | tracking_number  |
      | o complete rd123456789th  | rd123456789th    |
      | complete o 1 re12345678th | re12345678th     |
      | co re123456789ti          | re123456789ti    |
      | co x-1234 4232 1123       | x-1234 4232 1123 |
      | co 1234                   | 1234             |

  Scenario Outline: Try and complete an order without providing a tracking number for my seller who requires that one is given
    Given a tracking number format exists with seller: the seller

    When I text "<message_text>" from "66354668874"

    Then the seller order should not be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should include a translation of "is required" in "en" (English)
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text   |
      | complete order |
      | co             |
      | co 1           |

  Scenario: Generally my seller always requires a tracking number to be provided, but not for me
    Given a tracking number format exists with seller: the seller
    And a tracking number format exists with seller: the seller, supplier: the supplier, required: false

    When I text "co" from "66354668874"

    Then the seller order should be completed

  Scenario: Try to complete an order as the seller
    When I text "co" from "66354668789"

    Then the supplier order should not be completed

    And the most recent outgoing text message destined for the mobile_number: "Mara's number" should be a translation of "you have no orders to complete" in "en" (English) where supplier_name: "Mara"
    And the seller should be that outgoing text message's payer

  Scenario: Complete an order as the seller/supplier
    Given another seller exists with name: "Andy"
    And another verified mobile number: "Andy's number" exists with number: "61444144443", user: the seller
    And another product exists with supplier: the seller, seller: the seller
    And a line item exists for that product
    Then another seller order should exist with seller: the seller

    When I text "co" from "61444144443"

    Then the seller order should be completed
    And the most recent outgoing text message destined for mobile_number: "Andy's number" should be
    """
    Thanks Andy, Order #2 has been marked as shipped
    """
    And the seller should be that outgoing text message's payer

  Scenario: Try to complete an order which I have not yet confirmed
    Given the supplier order is not yet confirmed

    When I text "co" from "66354668874"

    Then the seller order should not be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you must confirm the line items first" in "en" (English) where supplier_name: "Nok", line_item_numbers: "#1"
    And the seller should be that outgoing text message's payer

  Scenario Outline: Try to complete an order which I already completed
    Given the supplier order was already completed

    When I text "co 1" from "66354668874"

    Then the supplier order should be completed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you have no orders to complete" in "en" (English) where supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text |
      | co           |
      | co 1         |

  Scenario Outline: Try to complete an order giving the wrong order number
    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should include a translation of "# does not exist" in "en" (English) where value: "<order_id>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text | order_id |
      | co 2123443   | 2123443  |
      | co 2 1231    | 2        |

