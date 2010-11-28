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
      | order           |
      | o               |

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
      | order 1          |
      | o 1              |

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
      | order 1          |
      | o 1              |

  Scenario Outline: Try to complete an order implicitly whilst having multiple incomplete orders
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product with quantity: 1

    When I text "<message_text>" from "66354668874"

    Then the seller order should not be completed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should be a translation of "be specific about the order number" in "en" (English) where supplier_name: "Nok", topic: "<topic>", action: <action>, params: <params>
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text | topic | action | params     |
      | co           | o     | " c"   | ""         |
      | co RE23123   | o     | " c"   | " RE23123" |

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

  @current
  Scenario Outline: Try to complete an order with a tracking number that I already used before
    Given the line item was already confirmed
    And the supplier order was already completed
    And I update the supplier order with tracking_number: "re123456789th"
    And a seller exists
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

    Then the supplier order should not be completed
    And the supplier order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "the tracking number is missing or invalid" in "en" (English) where supplier_name: "Nok", errors: "Tracking number is invalid", topic: "<topic>", action: "<action>", supplier_order_number: "1"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                          | topic          | action   |
    | supplier_order complete rd123456789th | supplier_order | complete |
    | supplier_order complete rd123456789th  | supplier_order  | complete |
    | po complete rd123456789th             | po             | complete |
    | po c re12345678th                     | po             | c        |
    | cpo re123456789ti                     | po             | c        |
    | cpo 1 cn123456789th                   | po             | c        |

  Scenario Outline: Try and complete an order without providing a tracking number for my seller who requires that one is given
    Given a tracking number format exists with seller: the seller

    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be completed
    And the supplier order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "the tracking number is missing or invalid" in "en" (English) where supplier_name: "Nok", errors: "Tracking number is required", topic: "<topic>", action: "<action>", supplier_order_number: "1"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text            | topic          | action   |
    | supplier_order complete | supplier_order | complete |
    | supplier_order complete  | supplier_order  | complete |
    | po complete             | po             | complete |
    | po c                    | po             | c        |
    | cpo                     | po             | c        |
    | cpo 1                   | po             | c        |

  Scenario Outline: Generally my seller always requires a tracking number to be provided, but not for this product
    Given a tracking number format exists with seller: the seller
    And a tracking number format exists with seller: the seller, product: the product, required: false

    When I text "<message_text>" from "66354668874"

    Then the supplier order should be completed
    And the supplier order's tracking_number should be nil

  Examples:
    | message_text            |
    | supplier_order complete |
    | supplier_order complete  |
    | po complete             |
    | po c                    |
    | cpo                     |
    | cpo 1                   |

  Scenario Outline: Generally my seller always requires a tracking number to be provided, but not when I am the supplier
    Given a tracking number format exists with seller: the seller
    And a tracking number format exists with seller: the seller, supplier: the supplier, required: false

    When I text "<message_text>" from "66354668874"

    Then the supplier order should be completed
    And the supplier order's tracking_number should be nil

  Examples:
    | message_text            |
    | supplier_order complete |
    | supplier_order complete  |
    | po complete             |
    | po c                    |
    | cpo                     |
    | cpo 1                   |

  Scenario Outline: Try to complete an order as the seller
    When I text "<message_text>" from "66354668789"

    Then the supplier order should not be completed

    And the most recent outgoing text message destined for the mobile_number: "Mara's number" should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "complete", supplier_name: "Mara", status: "incomplete"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text |
    | po complete  |
    | po c         |
    | cpo          |

  Scenario Outline: Successfully complete an order which I have not yet accepted but I am also the seller of the product
    Given a product exists with supplier: the seller, seller: the seller
    And a supplier order exists for the product

    When I text "<message_text>" from "66354668789"

    Then the supplier order should be completed
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Mara", processed: "completed", supplier_order_number: "2"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text              |
    | supplier_order complete 2 |
    | supplier_order complete 2  |
    | po complete 2             |
    | po c 2                    |
    | cpo 2                     |

  Scenario Outline: Try to complete an order which I have not yet accepted
    Given the supplier order is not yet accepted

    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be completed

    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you must accept the supplier order first" in "en" (English) where supplier_name: "Nok", topic: "<topic>", supplier_order_number: "1", quantity: "3"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text              | topic          |
    | supplier_order complete   | supplier_order |
    | supplier_order complete 1  | supplier_order  |
    | po complete               | po             |
    | po c 1                    | po             |
    | cpo                       | po             |
    | cpo 1                     | po             |

 Scenario: Try to explicitly complete an order which I already completed
    Given the supplier order was already completed

    When I text "cpo 1" from "66354668874"

    Then the supplier order should be completed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "supplier order was already processed" in "en" (English) where status: "completed", supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

 Scenario: Try to implicitly complete an order which I already completed
    Given the supplier order was already completed

    When I text "cpo" from "66354668874"

    Then the supplier order should be completed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "complete", supplier_name: "Nok", status: "incomplete"
    And the seller should be that outgoing text message's payer

  Scenario Outline: Successfully complete an order even when giving the wrong order number
    Given the supplier order was already accepted

    When I text "<message_text>" from "66354668874"

    Then the supplier order should be completed

  Examples:
    | message_text                   |
    | po complete 9999               |
    | po c 9999                      |
    | cpo 4355                       |

