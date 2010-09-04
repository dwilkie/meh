Feature: Complete a supplier order
  In order to notify my seller that I have completed processing a supplier order (product order) and to submit the tracking number if applicable
  As a supplier
  I want to be able to complete a supplier order by sending in a text message

  Background:
    Given a mobile number: "Nok's number" exists with number: "66354668874"
    And a supplier exists with name: "Nok", mobile_number: mobile_number: "Nok's number"
    And a mobile number: "Mara's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", mobile_number: mobile_number: "Mara's number"
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", supplier: the supplier, seller: the seller
    And a supplier order exists for product: the product with quantity: 3
    And the supplier order was already accepted

  Scenario Outline: Successfully complete an order without providing a tracking number
    When I text "<message_text>" from "66354668874"

    Then the supplier order should be completed
    And the supplier order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "completed", supplier_order_number: "1"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has COMPLETED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #154673
    """

  Examples:
    | message_text              |
    | supplier_order complete 1 |
#    | product_order complete 1  |
#    | supplier_order c 1        |
#    | product_order c 1         |
#    | complete_supplier_order 1 |
#    | complete_product_order 1  |
#    | po complete 1             |
#    | po c 1                    |
#    | cpo 1                     |
#    | supplier_order complete   |
#    | product_order complete    |
#    | supplier_order c          |
#    | product_order c           |
#    | complete_supplier_order   |
#    | complete_product_order    |
#    | po complete               |
#    | po c                      |
#    | cpo                       |

  Scenario Outline: Successfully complete an order providing a tracking number
    Given a notification exists with event: "product_order_completed", for: "seller", purpose: "to inform me when a supplier completes a product order", seller: the seller, supplier: the supplier

    And the notification has the following message:
    """
    Hi <seller_name>, <supplier_name> (<supplier_mobile_number>) has COMPLETED their product order of <product_order_quantity> x <product_number> (<product_name>) which belongs to your customer order: #<customer_order_number>. The tracking number is: "<tracking_number>"
    """

    And a tracking_number_format exists with seller: the seller, format: "^(re|cp)\\d{9}th$"
    When I text "<message_text>" from "66354668874"

    Then the supplier_order's tracking_number should be "<tracking_number>"
    And the supplier_order should be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "completed", supplier_order_number: "1"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has COMPLETED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #154673. The tracking number is: "<tracking_number>"
    """

  Examples:
    | message_text                                      | tracking_number |
    | supplier_order complete 1 re123456789th | re123456789th   |
    | product_order complete 1 RE123456789TH  | RE123456789TH   |
    | supplier_order c 1 cp123456789th        | cp123456789th   |
    | product_order c 1 CP123456789TH         | CP123456789TH   |
    | complete_supplier_order 1 re221341212th | re221341212th   |
    | complete_product_order 1 re554621233th  | re554621233th   |
    | po complete 1 re000000000th             | re000000000th   |
    | po c 1 re999999999th                    | re999999999th   |
    | cpo 1 cp987654321th                     | cp987654321th   |
    | supplier_order complete CP987654321TH        | CP987654321TH   |
    | product_order complete Re123456789th         | Re123456789th   |
    | supplier_order c rE123456789th               | rE123456789th   |
    | product_order c re123456789Th                | re123456789Th   |
    | complete_supplier_order re123456789tH        | re123456789tH   |
    | complete_product_order RE123456789th         | RE123456789th   |
    | po complete Re123456789Th                    | Re123456789Th   |
    | po c Re123456789tH                           | Re123456789tH   |
    | cpo RE123456789Th                            | RE123456789Th   |

  Scenario Outline: Try to complete an order implicitly with multiple incomplete supplier orders
    Given a supplier_order: "second order" exists with product: the product

    When I text "<message_text>" from "66354668874"

    Then the supplier_order: "first order" should not be completed
    And the supplier_order: "second order" should not be completed
    And a new outgoing text message should be created destined for the mobile_number: "Nok's number"
    And the outgoing_text_message should be a translation of "be specific about the supplier order number" in "en" (English) where supplier_name: "Nok", human_action: "complete", topic: "<topic>", action: "<action>"

  Examples:
    | message_text                 | topic          | action   |
    | supplier_order complete | supplier_order | complete |
    | product_order complete  | product_order  | complete |
    | supplier_order c        | supplier_order | c        |
    | product_order c         | product_order  | c        |
    | complete_supplier_order | supplier_order | complete |
    | complete_product_order  | product_order  | complete |
    | po complete             | po             | complete |
    | po c                    | po             | c        |
    | cpo                     | po             | c        |

  Scenario Outline: Try to complete an order with a tracking number that I already used before
    Given a tracking_number_format exists with seller: the seller
    And a product exists with supplier: the supplier
    And a supplier_order exists with product: the product, tracking_number: "re123456789th"

    When I text "<message_text>" from "66354668874"

    Then the supplier_order: "first order" should not be completed
    And the supplier_order: "first order"s tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "this tracking number was already used by you" in "en" (English) where supplier_name: "Nok"

  Examples:
    | message_text                          |
    | po complete 1 re123456789th |
    | po c 1 Re123456789Th        |
    | cpo 1 RE123456789TH         |
    | cpo 1 rE123456789tH         |

  Scenario Outline: Try to complete an order with a tracking number that is invalid
    Given a tracking_number_format exists with seller: the seller, format: "^(re|cp)\\d{9}th$"

    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be completed
    And the supplier_order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "the tracking number is missing or invalid" in "en" (English) where supplier_name: "Nok", errors: "tracking number is invalid", topic: "<topic>", action: "<action>", supplier_order_number: "1"

  Examples:
    | message_text                               | topic          | action   |
    | supplier_order complete rd123456789th | supplier_order | complete |
    | product_order complete rd123456789th  | product_order  | complete |
    | po complete rd123456789th             | po             | complete |
    | po c re12345678th                     | po             | c        |
    | cpo re123456789ti                     | po             | c        |
    | cpo 1 cn123456789th              | po             | c        |

  Scenario Outline: Try and complete an order without providing a tracking number for my seller who requires that one is given
    Given a tracking_number_format exists with seller: the seller

    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be completed
    And the supplier_order's tracking_number should be nil
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "the tracking number is missing or invalid" in "en" (English) where supplier_name: "Nok", errors: "tracking number is required", topic: "<topic>", action: "<action>", supplier_order_number: "1"

  Examples:
    | message_text                 | topic          | action   |
    | supplier_order complete | supplier_order | complete |
    | product_order complete  | product_order  | complete |
    | po complete             | po             | complete |
    | po c                    | po             | c        |
    | cpo                     | po             | c        |
    | cpo 1              | po             | c        |

  Scenario Outline: Generally my seller always requires a tracking number to be provided, but not for this product
    Given a tracking_number_format exists with seller: the seller
    And a tracking_number_format exists with seller: the seller, product: the product, required: false

    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be completed
    And the supplier order's tracking_number should be nil

  Examples:
    | message_text                 |
    | supplier_order complete |
    | product_order complete  |
    | po complete             |
    | po c                    |
    | cpo                     |
    | cpo 1              |

  Scenario Outline: Generally my seller always requires a tracking number to be provided, but not when I am the supplier
    Given a tracking_number_format exists with seller: the seller
    And a tracking_number_format exists with seller: the seller, supplier: the supplier, required: false

    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be completed
    And the supplier order's tracking_number should be nil

  Examples:
    | message_text                 |
    | supplier_order complete |
    | product_order complete  |
    | po complete             |
    | po c                    |
    | cpo                     |
    | cpo 1              |

  Scenario Outline: Try and complete an order which I have not yet accepted
    Given a product exists with supplier: the supplier
    And a supplier_order exists with id: 12345, product: the product, quantity: 5

    When I text "<message_text>" from "66354668874"

    Then the supplier_order should not be completed

    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you must accept the supplier order first" in "en" (English) where supplier_name: "Nok", topic: "<topic>", supplier_order_number: "12345", quantity: "5"

  Examples:
    | message_text                       | topic          |
    | supplier_order complete 12345 | supplier_order |
    | product_order complete 12345  | product_order  |
    | po complete 12345             | po             |
    | po c 12345                    | po             |
    | cpo 12345                     | po             |

  Scenario Outline: Try to complete an order as the seller
    When I text "<message_text>" from "66354668789"

    Then the supplier_order should not be completed

    And a new outgoing text message should be created destined for the mobile_number: "Mara's number"
    And the outgoing_text_message should be a translation of "you do not have any supplier orders" in "en" (English) where human_action: "complete", supplier_name: "Mara", status: "incomplete"

  Examples:
    | message_text     |
    | po complete |
#    | po c        |
#    | cpo         |

  Scenario Outline: Successfully complete an order which I have not yet accepted but I am also the seller of the product
    Given a product exists with supplier: the seller, seller: the seller
    And a supplier_order exists with id: 12345, product: the product, seller_order: the seller_order

    When I text "<message_text>" from "66354668789"

    Then the supplier_order should be completed
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Mara", processed: "completed", supplier_order_number: "12345"

  Examples:
    | message_text                       |
    | supplier_order complete 12345 |
    | product_order complete 12345  |
    | po complete 12345             |
    | po c 12345                    |
    | cpo 12345                     |

  Scenario Outline: Try to complete an order forgetting the pin code or suppling an incorrect a pin code
    Given a supplier_order exists with id: 1, product_id: the product, status: "accepted"
    When I text <message_text> from "66354668789"

    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of <error_message> in "en" (English)

    Examples:
    | message_text                              | error_message                      |
    | "completeorder 1235 1 re246589912th" | "mobile pin number incorrect"      |
    | "completeorder x123 1 re246589912th" | "mobile pin number format invalid" |
    | "completeorder"                           | "mobile pin number blank"          |

  Scenario Outline: Try to complete an order with an invalid tracking number
    Given a supplier_order exists with id: 654789, product_id: the product, status: "accepted"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "invalid attribute" in "en" (English)

    Examples:
      | text_message                             |
      | completeorder 654789 rd246589912th  |
      | completeorder 654789 re2465899124th |
      | completeorder 654789 re246589912ti  |

  Scenario Outline: Try to complete an order which has not been accepted
    Given a supplier_order exists with id: 654789, product_id: the product, status: "<order_status>"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "<order_status>", supplier: "Nok"

    Examples:
      | text_message                            | order_status |
      | completeorder 654789 re246589912th | rejected     |
      | completeorder 654789 re246589912th | unconfirmed  |

  Scenario: Try to complete an order which was already completed
    Given a supplier_order exists with id: 654789, product_id: the product, status: "completed"

    When I text "completeorder 654789 re246589912th" from "66354668789"
    Then the supplier_order should be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "completed", supplier: "Nok"

