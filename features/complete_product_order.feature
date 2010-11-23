Feature: Complete a supplier order
  In order to notify my seller that I have completed processing a supplier order (product order) and to submit the tracking number if applicable
  As a supplier
  I want to be able to complete a supplier order by sending in a text message

  Background:
    Given a supplier exists with name: "Nok"
    And a verified mobile number: "Nok's number" exists with number: "66354668874", user: the supplier
    And a seller exists with name: "Mara"
    And a verified mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", supplier: the supplier, seller: the seller
    And a supplier order exists for the product with quantity: 3
    And the supplier order was already accepted

  Scenario Outline: Successfully complete an order without providing a tracking number
    Given the mobile number: "Mara's number" <is_not_yet_already> verified
    When I text "<message_text>" from "66354668874"

    Then the supplier order should be completed
    And the supplier order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "completed", product_order_number: "1"
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for mobile_number: "Mara's number" <should_be>
    """
    Hi Mara, Nok (+66354668874) has COMPLETED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #1
    """
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text              | is_not_yet_already | should_be     |
    | product_order complete 1 | was already        | should be     |
    | product_order complete 1  | is not yet         | should not be |
    | product_order c 1        | was already        | should be     |
    | product_order c 1         | is not yet         | should not be |
    | complete_product_order 1 | was already        | should be     |
    | complete_product_order 1  | is not yet         | should not be |
    | po complete 1             | was already        | should be     |
    | po c 1                    | is not yet         | should not be |
    | cpo 1                     | was already        | should be     |
    | product_order complete   | is not yet         | should not be |
    | product_order complete    | was already        | should be     |
    | product_order c          | is not yet         | should not be |
    | product_order c           | was already        | should be     |
    | complete_product_order   | is not yet         | should not be |
    | complete_product_order    | was already        | should be     |
    | po complete               | is not yet         | should not be |
    | po c                      | was already        | should be     |
    | cpo                       | is not yet         | should not be |

  Scenario Outline: Successfully complete an order providing a tracking number
    Given a notification exists with event: "product_order_completed", for: "seller", purpose: "to inform me when a supplier completes a product order", seller: the seller, supplier: the supplier

    And the notification has the following message:
    """
    Hi <seller_name>, <supplier_name> (<supplier_mobile_number>) has COMPLETED their product order of <product_order_quantity> x <product_number> (<product_name>) which belongs to your customer order: #<customer_order_number>. The tracking number is: "<tracking_number>"
    """

    And a tracking number format exists with seller: the seller, format: "^(re|cp)\\d{9}th$"
    When I text "<message_text>" from "66354668874"

    Then the supplier order's tracking_number should be "<tracking_number>"
    And the supplier order should be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "completed", product_order_number: "1"
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has COMPLETED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #1. The tracking number is: "<tracking_number>"
    """
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                            | tracking_number |
    | product_order complete 1 re123456789th | re123456789th   |
    | product_order complete 1 RE123456789TH  | RE123456789TH   |
    | product_order c 1 cp123456789th        | cp123456789th   |
    | product_order c 1 CP123456789TH         | CP123456789TH   |
    | complete_product_order 1 re221341212th | re221341212th   |
    | complete_product_order 1 re554621233th  | re554621233th   |
    | po complete 1 re000000000th             | re000000000th   |
    | po c 1 re999999999th                    | re999999999th   |
    | cpo 1 cp987654321th                     | cp987654321th   |
    | product_order complete CP987654321TH   | CP987654321TH   |
    | product_order complete Re123456789th    | Re123456789th   |
    | product_order c rE123456789th          | rE123456789th   |
    | product_order c re123456789Th           | re123456789Th   |
    | complete_product_order re123456789tH   | re123456789tH   |
    | complete_product_order RE123456789th    | RE123456789th   |
    | po complete Re123456789Th               | Re123456789Th   |
    | po c Re123456789tH                      | Re123456789tH   |
    | cpo RE123456789Th                       | RE123456789Th   |

  Scenario Outline: Try to complete an order implicitly with multiple incomplete supplier orders
    Then a supplier order: "first order" should exist with product_id: the product
    Given a product exists with supplier: the supplier, seller: the seller
    And a supplier order exists for the product

    When I text "<message_text>" from "66354668874"

    Then the supplier order: "first order" should not be completed
    And the supplier order should not be completed
    And the most recent outgoing text message destined for the mobile_number: "Nok's number" should be a translation of "be specific about the supplier order number" in "en" (English) where supplier_name: "Nok", human_action: "complete", topic: "<topic>", action: "<action>"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text            | topic          | action   |
    | product_order complete | product_order | complete |
    | product_order complete  | product_order  | complete |
    | product_order c        | product_order | c        |
    | product_order c         | product_order  | c        |
    | complete_product_order | product_order | complete |
    | complete_product_order  | product_order  | complete |
    | po complete             | po             | complete |
    | po c                    | po             | c        |
    | cpo                     | po             | c        |

  Scenario Outline: Try to complete an order with a tracking number that I already used before
    Then a supplier order: "first order" should exist with product_id: the product
    Given a tracking number format exists with seller: the seller
    Given a product exists with supplier: the supplier, seller: the seller
    And a supplier order exists for the product with tracking_number: "re123456789th"

    When I text "<message_text>" from "66354668874"

    Then the supplier order: "first order" should not be completed
    And the product_order: "first order"s tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "this tracking number was already used by you" in "en" (English) where supplier_name: "Nok"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                |
    | po complete 1 re123456789th |
    | po c 1 Re123456789Th        |
    | cpo 1 RE123456789TH         |
    | cpo 1 rE123456789tH         |

  Scenario Outline: Try to complete an order with a tracking number that is invalid
    Given a tracking number format exists with seller: the seller, format: "^(re|cp)\\d{9}th$"

    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be completed
    And the supplier order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "the tracking number is missing or invalid" in "en" (English) where supplier_name: "Nok", errors: "Tracking number is invalid", topic: "<topic>", action: "<action>", product_order_number: "1"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text                          | topic          | action   |
    | product_order complete rd123456789th | product_order | complete |
    | product_order complete rd123456789th  | product_order  | complete |
    | po complete rd123456789th             | po             | complete |
    | po c re12345678th                     | po             | c        |
    | cpo re123456789ti                     | po             | c        |
    | cpo 1 cn123456789th                   | po             | c        |

  Scenario Outline: Try and complete an order without providing a tracking number for my seller who requires that one is given
    Given a tracking number format exists with seller: the seller

    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be completed
    And the supplier order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "the tracking number is missing or invalid" in "en" (English) where supplier_name: "Nok", errors: "Tracking number is required", topic: "<topic>", action: "<action>", product_order_number: "1"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text            | topic          | action   |
    | product_order complete | product_order | complete |
    | product_order complete  | product_order  | complete |
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
    | product_order complete |
    | product_order complete  |
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
    | product_order complete |
    | product_order complete  |
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
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Mara", processed: "completed", product_order_number: "2"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text              |
    | product_order complete 2 |
    | product_order complete 2  |
    | po complete 2             |
    | po c 2                    |
    | cpo 2                     |

  Scenario Outline: Try to complete an order which I have not yet accepted
    Given the supplier order is not yet accepted

    When I text "<message_text>" from "66354668874"

    Then the supplier order should not be completed

    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you must accept the supplier order first" in "en" (English) where supplier_name: "Nok", topic: "<topic>", product_order_number: "1", quantity: "3"
    And the seller should be that outgoing text message's payer

  Examples:
    | message_text              | topic          |
    | product_order complete   | product_order |
    | product_order complete 1  | product_order  |
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

