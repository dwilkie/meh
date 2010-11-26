Feature: Confirm line item
  In order to verify that I have received a line item and that I have confirmed the quantity and know the item
  As a supplier
  I want to be able to confirm a line item by sending in a text message

  Background:
    Given a supplier exists with name: "Nok"
    And a verified mobile number: "Nok's number" exists with number: "66354668874", user: the supplier
    And a seller exists with name: "Mara"
    And a verified mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", supplier: the supplier, seller: the seller
    And a line item exists for the product with quantity: 1
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

  Scenario Outline: Confirm a line item implicitly
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
      | message_text        |
      | line_item confirm 1 |
      | item confirm 1      |
      | li confirm 1        |
      | i confirm 1         |
      | line_item c 1       |
      | item c 1            |
      | li c 1              |
      | i c 1               |
      | confirm line_item 1 |
      | confirm item 1      |
      | confirm li 1        |
      | confirm i 1         |
      | c line_item 1       |
      | c item 1            |
      | c li 1              |
      | c i 1               |
      | cline_item 1        |
      | citem 1             |
      | cli 1               |
      | ci 1                |
      | line_item 1         |
      | item 1              |
      | li 1                |
      | i 1                 |

  Scenario Outline: Confirm an order explicitly
    When I text "<message_text>" from "66354668874"

    Then the line item should be confirmed

    Examples:
      | message_text |
      | cli 1 1      |
      | ci 1 1       |
      | li 1 1       |
      | i 1 1        |
      | item 1 1     |
      | c i 1 1      |
      | i c 1 1      |
      | ci 1 1       |
      | li 1 1       |

  Scenario Outline: Confirm a line item explicity whilst having multiple unconfirmed line items
    Then a line item: "first item" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product

    When I text "<message_text>" from "66354668874"

    Then the line item: "first item" should be confirmed
    But the line item should not be confirmed

    Examples:
      | message_text |
      | cli 1 1      |
      | ci 1 1       |
      | li 1 1       |
      | i 1 1        |
      | item 1 1     |
      | c i 1 1      |
      | i c 1 1      |
      | ci 1 1       |
      | li 1 1       |

  Scenario Outline: Try to confirm a line item implicitly whilst having multiple unconfirmed line items
    Then a line item: "first item" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product

    When I text "<message_text>" from "66354668874"

    Then the line item: "first item" should not be confirmed
    And the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "be specific about the line item number" in "en" (English) where supplier_name: "Nok", topic: "<topic>", action: <action>, params: <params>
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

  Scenario: Try to confirm a line item explicitly giving the wrong item number
    When I text "li 234 1" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should include a translation of "line item # does not exist" in "en" (English) where value: "234"
    And the seller should be that outgoing text message's payer

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

  Scenario Outline: Try to confirm a line item giving the wrong quantity
    When I text "<message_text>" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text  | value  |
      | ci 1 2        | 2      |
      | i 2           | 2      |
      | li 4          | 4      |
      | item maggot   | maggot |
      | cli 1 maggot  | maggot |

  Scenario: Try to implicitly confirm a line item omitting the quantity
    When I text "li" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "line item quantity must be confirmed" in "en" (English)
    And the seller should be that outgoing text message's payer

  Scenario: Try to explicitly confirm a line item omitting the quantity with multiple unconfirmed line items
    Then a line item: "first item" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a line item exists for the product

    When I text "li 1" from "66354668874"

    Then the line item: "first item" should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "line item quantity must be confirmed" in "en" (English)
    And the seller should be that outgoing text message's payer

  Scenario Outline: Confirm an line item with a product verification code
    Given I update the product with verification_code: "abc123"

    When I text "<message_text>" from "66354668874"

    Then the line item should be confirmed

    Examples:
      | message_text         |
      | li 1 abc123          |
      | cli 1 abC123         |
      | i 1 1 ABC123         |
      | item 1 1 aBc123      |

  Scenario: Confirm a line item with a product verification code giving the incorrect case
    Given I update the product with verification_code: "abc123"

    When I text "li 1 ABC123" from "66354668874"

    Then the line item should be confirmed

  Scenario Outline: Try to confirm an line item with a product verification code giving the wrong code
    Given I update the product with verification_code: "abc123"

    When I text "<message_text>" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text         | value  |
      | li 1 1 abc12         | abc12  |
      | cli 1 ab123          | ab123  |
      | i 1 cba123           | cba123 |
      | item 1 1 1           | 1      |

  Scenario: Try to confirm a line item with a product verification code omitting the code
    Given I update the product with verification_code: "1"

    When I text "li 1" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is required" in "en" (English) where value: "<value>"
    And the seller should be that outgoing text message's payer

  Scenario: Try to implicitly confirm a line item without a product verification code giving a code
    When I text "li 1 xyz123" from "66354668874"

    Then the line item should not be confirmed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "is incorrect" in "en" (English) where value: "xyz123"
    And the seller should be that outgoing text message's payer

  Scenario: Try to explicitly confirm a line item without a product verification code giving a code
    When I text "li 1 1 xyz123" from "66354668874"

    Then the line item should be confirmed

  Scenario: Try to explicity confirm a line item which I already confirmed
    Given the line item was already confirmed

    When I text "li 1 1" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you have no unconfirmed line items" in "en" (English) where supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

  Scenario: Try to implicitly confirm a line item which I already completed
    Given the line item was already confirmed

    When I text "li 1" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you have no unconfirmed line items" in "en" (English) where supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

