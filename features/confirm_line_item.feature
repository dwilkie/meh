Feature: Confirm line item
  In order to notify my seller that I have received a line item and that I have confirmed the quantity and the item
  As a supplier
  I want to be able to confirm a line item by sending in a text message

  Background:
    Given a supplier exists with name: "Nok"
    And a verified mobile number: "Nok's number" exists with number: "66354668874", user: the supplier
    And a seller exists with name: "Mara"
    And a verified mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", verification_code: "hy456n", supplier: the supplier, seller: the seller
    And a line item exists for the product with quantity: 3
    And the seller order paypal ipn has the following params:
    """
    {
      'address_name' => 'Ho Chi Minh',
      'address_street' => '4 Chau Minh Lane',
      'address_city' => 'Hanoi',
      'address_state' => 'Hanoi Province',
      'address_country' => 'Viet Nam',
      'address_zip' => '52321'
    }
    """

  Scenario Outline: Successfully confirm a line item
    When I text "<message_text>" from "66354668874"

    Then the line item should be confirmed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be
    """
    Nok, pls ship order #1 to:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    then reply with: "co"
    """
    And the outgoing text message should be queued_for_sending
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has confirmed order #1
    """
    And the outgoing text message should be queued_for_sending
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                      |
    | line_item confirm 154674 3 hy456n |
    | item confirm 154674 3 hy456n      |
    | li confirm 154674 3 hy456n        |
    | i confirm 154674 3 hy456n         |
    | line_item c 154674 3 hy456n       |
    | item c 3 hy456n                   |
    | li c 3 hy456n                     |
    | i c 3 hy456n                      |
    | confirm line_item 3 hy456n        |
    | confirm item 3 hy456n             |
    | confirm li 3 hy456n               |
    | confirm i 3 hy456n                |
    | c line_item 3 hy456n              |
    | c item 3 hy456n                   |
    | c li 3 hy456n                     |
    | c i 3 hy456n                      |
    | cline_item 3 hy456n               |
    | citem 3 hy456n                    |
    | cli 3 hy456n                      |
    | ci 3 hy456n                       |
    | line_item 3 hy456n                |
    | item 3 hy456n                     |
    | li a 3 hy456n                     |
    | i 3 hy456n                        |

  Scenario Outline: Try to confirm a line item implicitly with multiple unconfirmed line items
    Then a line item: "first item" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product

    When I text "<message_text>" from "66354668874"

    Then the line item: "first item" should not be confirmed
    And the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "be specific about the line item number" in "en" (English) where supplier_name: "Nok", human_action: "confirm", topic: "<topic>", action: <action>, params: <params>
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text | topic | action | params      |
    | cli          | li    | " c"   | ""          |
    | ci           | i     | " c"   | ""          |
    | li           | li    | ""     | ""          |
    | i            | i     | ""     | ""          |
    | item         | item  | ""     | ""          |
    | c i          | i     | " c"   | ""          |
    | i c          | i     | " c"   | ""          |
    | ci 3 hy456n  | i     | " c"   | " 3 hy456n" |
    | i 3 hy456n   | i     | ""     | " 3 hy456n" |

  Scenario: Try to confirm a line item as the seller
    When I text "ci" from "66354668789"

    Then the line item should not be confirmed

    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be a translation of "you have no unconfirmed line items" in "en" (English) where supplier_name: "Mara"
    And the seller should be that outgoing text message's payer

  Scenario: Try to confirm a line item as a seller when the seller is also the supplier for this product
    Given a product exists with verification_code: "hy456m", supplier: the seller, seller: the seller
    And a line item exists for the product with quantity: 3
    And no outgoing text messages exist with mobile_number_id: mobile_number: "Mara's number"

    When I text "ci" from "66354668789"

    Then the line item should not be confirmed
    And 0 outgoing_text_messages should exist with mobile_number_id: mobile_number: "Mara's number"

  Scenario Outline: Successfully confirm a line item even when giving the wrong item number
    When I text "<message_text>" from "66354668874"

    Then the line item should be confirmed

  Examples:
    | message_text       |
    | ci 9999 3 hy456n   |
    | cli 9999 3 hy456n  |
    | li 4355 3 hy456n   |

  Scenario Outline: Try to confirm a line item giving the wrong quantity
    When I text "<message_text>" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text            | value  |
    | ci 1 1 hy456n           | 1      |
    | i 2 hy456n              | 2      |
    | li 4 hy456n             | 4      |
    | item maggot hy456n      | maggot |
    | cli 1 maggot hy456n     | maggot |

  Scenario Outline: Try to confirm a line item omitting the quantity
    When I text "<message_text>" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "line item quantity must be confirmed" in "en" (English)
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text   |
    | ci             |
    | i              |
    | li             |
    | ci 1           |
    | i 1            |
    | li 1           |

  Scenario Outline: Try to confirm an line item giving the wrong product verification code
    When I text "<message_text>" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text         | value  |
    | li 154674 3 hy456    | hy456  |
    | cli 3 hy456m         | hy456m |
    | i 3 hy456p           | hy456p |
    | item 3 HY456Q        | HY456Q |

  Scenario Outline: confirm a line item giving the correct product verification code but the incorrect case
    When I text "<message_text>" from "66354668874"

    Then the line item should be confirmed

  Examples:
    | message_text   |
    | li 1 3 hy456N  |
    | cli 3 hY456n   |
    | item 3 HY456N  |

  Scenario: Try to explicity confirm a line item which I already confirmed
    Given the line item was already confirmed

    When I text "li 1 3 hy456n" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you have no unconfirmed line items" in "en" (English) where supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

  Scenario: Try to implicitly confirm a line item which I already completed
    Given the line item was already confirmed

    When I text "li 3 hy456n" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you have no unconfirmed line items" in "en" (English) where supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

