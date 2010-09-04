Feature: Accept supplier order
  In order to notify my seller that I have received a supplier order (product order) and that I have confirmed the quantity and the item
  As a supplier
  I want to be able to accept a supplier order by sending in a text message

  Background:
    Given a mobile number: "Nok's number" exists with number: "66354668874"
    And a supplier exists with name: "Nok", mobile_number: mobile_number: "Nok's number"
    And a mobile number: "Mara's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", mobile_number: mobile_number: "Mara's number"
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", verification_code: "hy456n", supplier: the supplier, seller: the seller
    And a supplier order exists for product: the product with quantity: 3
    And the paypal ipn has the following params: "{'address_name' => 'Ho Chi Minh', 'address_street' => '4 Chau Minh Lane', 'address_city' => 'Hanoi', 'address_state' => 'Hanoi Province', 'address_country' => 'Viet Nam', 'address_zip' => '52321'}"

  Scenario Outline: Successfully accept an order
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be accepted
    And the 2nd most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "accepted", supplier_order_number: "1"
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be
    """
    Hi Nok, please send the product order: #1, to the following address:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    then reply with: "po complete 1"
    """
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has ACCEPTED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #1
    """

  Examples:
    | message_text                          |
    | supplier_order accept 154674 3 hy456n |
    | product_order accept 154674 3 hy456n  |
    | supplier_order a 154674 3 hy456n      |
    | product_order a 154674 3 hy456n       |
    | accept_supplier_order 154674 3 hy456n |
    | accept_product_order 154674 3 hy456n  |
    | po accept 154674 3 hy456n             |
    | po a 154674 3 hy456n                  |
    | apo 154674 3 hy456n                   |
    | supplier_order accept 3 hy456n        |
    | product_order accept 3 hy456n         |
    | supplier_order a 3 hy456n             |
    | product_order a 3 hy456n              |
    | accept_supplier_order 3 hy456n        |
    | accept_product_order 3 hy456n         |
    | po accept 3 hy456n                    |
    | po a 3 hy456n                         |
    | apo 3 hy456n                          |

  Scenario Outline: Try to accept an order implicitly with multiple unconfirmed supplier orders
    Then a supplier order: "first order" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a supplier order exists for product: the product

    When I text "<message_text>" from "66354668874"

    Then the supplier order: "first order" should not be accepted
    And the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "be specific about the supplier order number" in "en" (English) where supplier_name: "Nok", human_action: "accept", topic: "<topic>", action: "<action>"

  Examples:
    | message_text                   | topic          | action |
    | supplier_order accept 3 hy456n | supplier_order | accept |
    | product_order accept 3 hy456n  | product_order  | accept |
    | supplier_order a 3 hy456n      | supplier_order | a      |
    | product_order a 3 hy456n       | product_order  | a      |
    | accept_supplier_order 3 hy456n | supplier_order | accept |
    | accept_product_order 3 hy456n  | product_order  | accept |
    | po accept 3 hy456n             | po             | accept |
    | po a 3 hy456n                  | po             | a      |
    | apo 3 hy456n                   | po             | a      |

  Scenario Outline: Try to accept an order as the seller
    When I text "<message_text>" from "66354668789"

    Then the supplier order should not be accepted

    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Mara", status: "unconfirmed"

  Examples:
    | message_text                   |
    | po accept 3 hy456n             |
    | po a 2 hy456n                  |
    | apo 3 hy456x                   |

  Scenario Outline: Try to accept an order as a seller when the seller is also the supplier for the product

    Given a product exists with verification_code: "hy456m", supplier: the seller, seller: the seller
    And a supplier order exists for product: the product with quantity: 3
    And no outgoing text messages exist with mobile_number_id: mobile_number: "Mara's number"

    When I text "<message_text>" from "66354668789"

    Then the supplier_order should not be accepted
    And 0 outgoing_text_messages should exist with mobile_number_id: mobile_number: "Mara's number"

  Examples:
    | message_text            |
    | po accept 2 3 hy456m    |
    | po a 2 3 hy456m         |
    | apo 2 3 hy456x          |

  Scenario Outline: Successfully accept an order even when giving the wrong order number
    When I text "<message_text>" from "66354668874"

    Then the supplier order should be accepted

  Examples:
    | message_text                   |
    | po accept 9999 3 hy456n        |
    | po a 9999 3 hy456n             |
    | apo 4355 3 hy456n              |

  Scenario Outline: Try to accept an order forgetting to supply an action
    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "what would you like to do with the supplier order?" in "en" (English) where topic: "<message_text>"

  Examples:
    | message_text                   |
    | product_order                  |
    | po                             |

  Scenario Outline: Try to accept an order supplying an invalid action
    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should be a translation of "invalid action given for the supplier order" in "en" (English) where topic: "<topic>", action: "<action>"

  Examples:
    | message_text                    | topic         | action |
    | product_order z                 | product_order | z      |
    | po 4                            | po            | 4      |

  Scenario Outline: Try to accept an order giving the wrong quantity
    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "<response>" in "en" (English) <where>

  Examples:
    | message_text            |  response    | where             |
    | apo 1 2 hy456n          | is incorrect | where value: "2"  |
    | apo 2 hy456n            | is incorrect | where value: "2"  |
    | ProductOrder a 2 hy456n | is incorrect | where value: "2"  |

  Scenario Outline: Try to accept an order omitting the quantity
    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "<response>" in "en" (English)

  Examples:
    | message_text   |  response                   |
    | apo 1          | order quantity is blank     |
    | apo            | order quantity is blank     |
    | ProductOrder a | order quantity is blank     |


  Scenario Outline: Try to accept an order giving the wrong product verification code
    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should include a translation of "<response>" in "en" (English) <where>

  Examples:
    | message_text            | response     | where                 |
    | apo 154674 3 hy456      | is incorrect | where value: "hy456"  |
    | apo 3 hy456m            | is incorrect | where value: "hy456m" |
    | ProductOrder a 3 hy456p | is incorrect | where value: "hy456p" |

  Scenario Outline: Accept an order giving the correct product verification code but the incorrect case
    When I text "<message_text>" from "66354668874"

    Then the supplier order should be accepted

  Examples:
    | message_text            |
    | apo 1 3 hy456N          |
    | apo 3 hY456n            |
    | ProductOrder a 3 HY456N |

 Scenario: Try to explicity accept an order which was already completed
    Given the supplier order was already completed

    When I text "apo 1 3 hy456n" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "supplier order was already processed" in "en" (English) where status: "completed", supplier_name: "Nok"

 Scenario: Try to implicitly accept an order which was already completed
    Given the supplier order was already completed

    When I text "apo 3 hy456n" from "66354668874"

    Then the supplier order should not be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Nok", status: "unconfirmed"

 Scenario: Try to explicitly accept an order which was already accepted
    Given the supplier order was already accepted

    When I text "apo 1 3 hy456n" from "66354668874"

    Then the supplier order should be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "supplier order was already processed" in "en" (English) where status: "accepted", supplier_name: "Nok"

 Scenario: Try to implicitly accept an order which was already accepted
    Given the supplier order was already accepted

    When I text "apo 3 hy456n" from "66354668874"

    Then the supplier order should be accepted
    And the most recent outgoing text message destined for the mobile number: "Nok's number" should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Nok", status: "unconfirmed"

