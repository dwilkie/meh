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

  @current
  Scenario Outline: Successfully confirm a line item
    When I text "<message_text>" from "66354668874"

    Then the line item should be confirmed
    And the 2nd most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you successfully processed the line item" in "en" (English) where supplier_name: "Nok", processed: "confirmed", line_item_number: "1"
    And the outgoing text message should be queued_for_sending
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be
    """
    Hi Nok, pls send the line item: #1, to this address:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    then reply with: "cpo"
    """
    And the outgoing text message should be queued_for_sending
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has confirmed their line item of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #1
    """
    And the outgoing text message should be queued_for_sending
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                      |
    | line_item confirm 154674 3 hy456n |
#    | item confirm 154674 3 hy456n      |
#    | li confirm 154674 3 hy456n        |
#    | i confirm 154674 3 hy456n         |
#    | line_item c 154674 3 hy456n       |
#    | item c 154674 3 hy456n            |
#    | li c 154674 3 hy456n              |
#    | i c 154674 3 hy456n               |
#    | confirm line_item 154674 3 hy456n |
#    | confirm item 154674 3 hy456n      |
#    | confirm li 154674 3 hy456n        |
#    | confirm i 154674 3 hy456n         |
#    | c line_item 154674 3 hy456n       |
#    | c item 154674 3 hy456n            |
#    | c li 154674 3 hy456n              |
#    | c i 3 hy456n                      |
#    | cline_item 3 hy456n               |
#    | citem 3 hy456n                    |
#    | cli 3 hy456n                      |
#    | ci 3 hy456n                       |
#    | line_item 3 hy456n                |
#    | item 3 hy456n                     |
#    | li a 3 hy456n                     |
#    | i 3 hy456n                        |

  Scenario Outline: Try to confirm an order implicitly with multiple unconfirmed line items
    Then a line item: "first order" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product

    When I text "<message_text>" from "66354668874"

    Then the line item: "first order" should not be accepted
    And the line item should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "be specific about the line item number" in "en" (English) where supplier_name: "Nok", human_action: "confirm", topic: "<topic>", action: "<action>"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                   | topic          | action |
    | line_item confirm 3 hy456n | line_item | confirm |
    | line_item confirm 3 hy456n  | line_item  | confirm |
    | line_item a 3 hy456n      | line_item | a      |
    | line_item a 3 hy456n       | line_item  | a      |
    | confirm_line_item 3 hy456n | line_item | confirm |
    | confirm_line_item 3 hy456n  | line_item  | confirm |
    | po confirm 3 hy456n             | po             | confirm |
    | po a 3 hy456n                  | po             | a      |
    | apo 3 hy456n                   | po             | a      |

  Scenario Outline: Try to confirm an order as the seller
    When I text "<message_text>" from "66354668789"

    Then the line item should not be accepted

    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be a translation of "you do not have any line items" in "en" (English) where human_action: "confirm", supplier_name: "Mara", status: "unconfirmed"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                   |
    | po confirm 3 hy456n             |
    | po a 2 hy456n                  |
    | apo 3 hy456x                   |

  Scenario Outline: Try to confirm an order as a seller when the seller is also the supplier for the product
    Given a product exists with verification_code: "hy456m", supplier: the seller, seller: the seller
    And a line item exists for the product with quantity: 3
    And no outgoing text messages exist with mobile_number_id: mobile_number: "Mara's number"

    When I text "<message_text>" from "66354668789"

    Then the line_item should not be accepted
    And 0 outgoing_text_messages should exist with mobile_number_id: mobile_number: "Mara's number"

  Examples:
    | message_text            |
    | po confirm 2 3 hy456m    |
    | po a 2 3 hy456m         |
    | apo 2 3 hy456x          |

  Scenario Outline: Successfully confirm an order even when giving the wrong order number
    When I text "<message_text>" from "66354668874"

    Then the line item should be accepted

  Examples:
    | message_text                   |
    | po confirm 9999 3 hy456n        |
    | po a 9999 3 hy456n             |
    | apo 4355 3 hy456n              |

  Scenario Outline: Try to confirm an order giving the wrong quantity
    When I text "<message_text>" from "66354668874"

    Then the line item should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text            | value  |
    | apo 1 1 hy456n          | 1      |
    | apo 2 hy456n            | 2      |
    | ProductOrder a 4 hy456n | 4      |
    | apo maggot hy456n       | maggot |
    | apo 1 maggot hy456n     | maggot |

  Scenario Outline: Try to confirm an order omitting the quantity
    When I text "<message_text>" from "66354668874"

    Then the line item should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "order quantity must be confirmed" in "en" (English)
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text   |
    | apo 1          |
    | apo            |
    | ProductOrder a |

  Scenario Outline: Try to confirm an order giving the wrong product verification code
    When I text "<message_text>" from "66354668874"

    Then the line item should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text            | value  |
    | apo 154674 3 hy456      | hy456  |
    | apo 3 hy456m            | hy456m |
    | ProductOrder a 3 hy456p | hy456p |
    | apo 3 HY456Q            | HY456Q |

  Scenario Outline: confirm an order giving the correct product verification code but the incorrect case
    When I text "<message_text>" from "66354668874"

    Then the line item should be accepted

  Examples:
    | message_text            |
    | apo 1 3 hy456N          |
    | apo 3 hY456n            |
    | ProductOrder a 3 HY456N |

  Scenario: Try to explicity confirm an order which I already completed
    Given the line item was already completed

    When I text "apo 1 3 hy456n" from "66354668874"

    Then the line item should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "line item was already processed" in "en" (English) where status: "completed", supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

  Scenario: Try to implicitly confirm an order which I already completed
    Given the line item was already completed

    When I text "apo 3 hy456n" from "66354668874"

    Then the line item should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you do not have any line items" in "en" (English) where human_action: "confirm", supplier_name: "Nok", status: "unconfirmed"
    And the seller should be that outgoing text message's payer

  Scenario: Try to explicitly confirm an order which I already accepted
    Given the line item was already accepted

    When I text "apo 1 3 hy456n" from "66354668874"

    Then the line item should be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "line item was already processed" in "en" (English) where status: "accepted", supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

  Scenario: Try to implicitly confirm an order which I already accepted
    Given the line item was already accepted

    When I text "apo 3 hy456n" from "66354668874"

    Then the line item should be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you do not have any line items" in "en" (English) where human_action: "confirm", supplier_name: "Nok", status: "unconfirmed"
    And the seller should be that outgoing text message's payer

