Feature: Accept supplier order
  In order to notify my seller that I have received a supplier order (product order) and that I have confirmed the quantity and the item
  As a supplier
  I want to be able to accept a supplier order by sending in a text message

  Background:
    Given a mobile_number: "Nok's number" exists with number: "66354668874", password: "1234"
    And a supplier exists with name: "Nok", mobile_number: mobile_number: "Nok's number"
    And a mobile_number: "Mara's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", mobile_number: mobile_number: "Mara's number"
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", verification_code: "hy456n", supplier: the supplier, seller: the seller
    And a paypal_ipn exists with seller: the seller
    And the paypal_ipn has the following params: "{'address_name' => 'Ho Chi Minh', 'address_street' => '4 Chau Minh Lane', 'address_city' => 'Hanoi', 'address_state' => 'Hanoi Province', 'address_country' => 'Viet Nam', 'address_zip' => '52321'}"
    And a seller_order exists with id: 154673, seller: the seller, order_notification: the paypal_ipn
    And a supplier_order: "first order" exists with id: 154674, product: the product, quantity: 3, seller_order: the seller_order

  Scenario Outline: Successfully accept an order
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be accepted
    And the 2nd most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "accepted", supplier_order_number: "154674"
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be
    """
    Hi Nok, please send the product order: #154674, to the following address:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    then reply with: "po complete 154674"
    """
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has ACCEPTED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #154673
    """

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
    | supplier_order accept 1234 3 hy456n        |
    | product_order accept 1234 3 hy456n         |
    | supplier_order a 1234 3 hy456n             |
    | product_order a 1234 3 hy456n              |
    | accept_supplier_order 1234 3 hy456n        |
    | accept_product_order 1234 3 hy456n         |
    | po accept 1234 3 hy456n                    |
    | po a 1234 3 hy456n                         |
    | apo 1234 3 hy456n                          |

  Scenario Outline: Try to accept an order implicitly with multiple unconfirmed supplier orders
    Given a supplier_order: "second order" exists with id: 154675, product: the product, quantity: 3

    When I text "<message_text>" from "66354668874"

    Then the supplier_order: "first order" should not be accepted
    And the supplier_order: "second order" should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
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

  Scenario Outline: Try to accept an order as the seller
    When I text "<message_text>" from "66354668789"

    Then the supplier_order should not be accepted

    And a new outgoing text message should be created destined for the mobile_number: "Mara's number"
    And the outgoing_text_message should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Mara", status: "unconfirmed"

  Examples:
    | message_text                        |
    | po accept 1234 3 hy456n             |
    | po a 1234 2 hy456n                  |
    | apo 1234 3 hy456x                   |

  Scenario Outline: Try to accept an order as a seller when the seller is also the supplier for the product

    Given a product exists with number: "190287626892", name: "Vietnamese Pig", verification_code: "hy456m", supplier: the seller, seller: the seller
    And a supplier_order: "second order" exists with id: 154675, product: the product, quantity: 3, seller_order: the seller_order

    When I text "<message_text>" from "66354668789"

    Then the supplier_order: "second order" should not be accepted
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should not be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Mara", processed: "accepted", supplier_order_number: 154675

  Examples:
    | message_text                        |
    | po accept 1234 3 hy456m             |
    | po a 1234 2 hy456m                  |
    | apo 1234 3 hy456x                   |

  Scenario Outline: Try to accept an order giving the wrong order number
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be accepted

  Examples:
    | message_text                        |
    | po accept 1234 9999 3 hy456n        |
    | po a 1234 9999 3 hy456n             |
    | apo 1234 4355 3 hy456n              |

  Scenario Outline: Try to accept an order suppling an incorrect a pin number
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
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
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "what would you like to do with the supplier order?" in "en" (English) where topic: "<message_text>"

  Examples:
    | message_text                   |
    | product_order                  |
    | po                             |

  Scenario Outline: Try to accept an order supplying an invalid action
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "invalid action given for the supplier order" in "en" (English) where topic: "<topic>", action: "<action>"

  Examples:
    | message_text                    | topic         | action |
    | product_order z                 | product_order | z      |
    | po 4                            | po            | 4      |

  Scenario Outline: Try to accept an order giving the wrong quantity
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should include a translation of "<response>" in "en" (English) <where>

  Examples:
    | message_text                 |  response    | where             |
    | apo 1234 154674 2 hy456n     | is incorrect | where value: "2"  |
    | apo 1234 2 hy456n            | is incorrect | where value: "2"  |
    | ProductOrder a 1234 2 hy456n | is incorrect | where value: "2"  |

  Scenario Outline: Try to accept an order omitting the quantity
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should include a translation of "<response>" in "en" (English)

  Examples:
    | message_text             |  response                   |
    | apo 1234 154674          | order quantity is blank     |
    | apo 1234                 | order quantity is blank     |
    | ProductOrder a 1234      | order quantity is blank     |


  Scenario Outline: Try to accept an order giving the wrong product verification code
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
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
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "supplier order was already confirmed" in "en" (English) where status: "completed", supplier_name: "Nok"

 Scenario: Try to implicitly accept an order which was already completed
    Given the supplier_order was already completed

    When I text "apo 1234 3 hy456n" from "66354668874"

    Then the supplier_order should not be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Nok", status: "unconfirmed"

 Scenario: Try to explicitly accept an order which was already accepted
    Given the supplier_order was already accepted

    When I text "apo 1234 154674 3 hy456n" from "66354668874"

    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "supplier order was already confirmed" in "en" (English) where status: "accepted", supplier_name: "Nok"

 Scenario: Try to implicitly accept an order which was already accepted
    Given the supplier_order was already accepted

    When I text "apo 1234 3 hy456n" from "66354668874"

    Then the supplier_order should be accepted
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "accept", supplier_name: "Nok", status: "unconfirmed"

