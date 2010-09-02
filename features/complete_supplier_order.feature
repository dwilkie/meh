Feature: Complete a supplier order
  In order to notify my seller that I have completed processing a supplier order (product order) and to submit the tracking number if applicable
  As a supplier
  I want to be able to complete a supplier order by sending in a text message

  Background:
    Given a mobile_number: "Nok's number" exists with number: "66354668874", password: "1234"
    And a supplier exists with name: "Nok", mobile_number: mobile_number: "Nok's number"
    And a mobile_number: "Mara's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", mobile_number: mobile_number: "Mara's number"
    And a product exists with number: "190287626891", name: "Vietnamese Chicken", supplier: the supplier, seller: the seller
    And a seller_order exists with id: 154673, seller: the seller
    And a supplier_order: "first order" exists with id: 154674, product: the product, quantity: 3, seller_order: the seller_order
    And the supplier_order was already accepted

  Scenario Outline: Successfully complete an order without a tracking number
    When I text "<message_text>" from "66354668874"

    Then the supplier_order should be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "completed", supplier_order_number: "154674"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has COMPLETED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #154673
    """

  Examples:
    | message_text                        |
    | supplier_order complete 1234 154674 |
    | product_order complete 1234 154674  |
    | supplier_order c 1234 154674        |
    | product_order c 1234 154674         |
    | complete_supplier_order 1234 154674 |
    | complete_product_order 1234 154674  |
    | po complete 1234 154674             |
    | po c 1234 154674                    |
    | cpo 1234 154674                     |
    | supplier_order complete 1234        |
    | product_order complete 1234         |
    | supplier_order c 1234               |
    | product_order c 1234                |
    | complete_supplier_order 1234        |
    | complete_product_order 1234         |
    | po complete 1234                    |
    | po c 1234                           |
    | cpo 1234                            |

  Scenario Outline: Successfully complete an order with a tracking number
    Given a notification exists with event: "product_order_completed", for: "seller", purpose: "to inform me when a supplier completes a product order", seller: the seller, supplier: the supplier

    And the notification has the following message:
    """
    Hi <seller_name>, <supplier_name> (<supplier_mobile_number>) has COMPLETED their product order of <product_order_quantity> x <product_number> (<product_name>) which belongs to your customer order: #<customer_order_number>. The tracking number is: "<tracking_number>"
    """

    And a tracking_number_format exists with seller: the seller
    When I text "<message_text>" from "66354668874"

    Then the supplier_order's tracking_number should be "re123456789th"
    And the supplier_order should be completed
    And the most recent outgoing text message destined for mobile_number: "Nok's number" should be a translation of "you successfully processed the supplier order" in "en" (English) where supplier_name: "Nok", processed: "completed", supplier_order_number: "154674"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, Nok (+66354668874) has COMPLETED their product order of 3 x 190287626891 (Vietnamese Chicken) which belongs to your customer order: #154673. The tracking number is: "re123456789th"
    """

  Examples:
    | message_text                                      |
    | supplier_order complete 1234 154674 re123456789th |
#    | product_order complete 1234 154674 re123456789th  |
#    | supplier_order c 1234 154674 re123456789th        |
#    | product_order c 1234 154674 re123456789th         |
#    | complete_supplier_order 1234 154674 re123456789th |
#    | complete_product_order 1234 154674 re123456789th  |
#    | po complete 1234 154674 re123456789th             |
#    | po c 1234 154674 re123456789th                    |
#    | cpo 1234 154674 re123456789th                     |
#    | supplier_order complete 1234 re123456789th        |
#    | product_order complete 1234 re123456789th         |
#    | supplier_order c 1234 re123456789th               |
#    | product_order c 1234 re123456789th                |
#    | complete_supplier_order 1234 re123456789th        |
#    | complete_product_order 1234 re123456789th         |
#    | po complete 1234 re123456789th                    |
#    | po c 1234 re123456789th                           |
#    | cpo 1234 re123456789th                            |

  Scenario Outline: Try to complete an order forgetting the pin code or suppling an incorrect a pin code
    Given a supplier_order exists with id: 154674, product_id: the product, status: "accepted"
    When I text <message_text> from "66354668789"

    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of <error_message> in "en" (English)

    Examples:
    | message_text                              | error_message                      |
    | "completeorder 1235 154674 re246589912th" | "mobile pin number incorrect"      |
    | "completeorder x123 154674 re246589912th" | "mobile pin number format invalid" |
    | "completeorder"                           | "mobile pin number blank"          |

  Scenario Outline: Try to complete an order with an invalid tracking number
    Given a supplier_order exists with id: 654789, product_id: the product, status: "accepted"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "invalid attribute" in "en" (English)

    Examples:
      | text_message                             |
      | completeorder 1234 654789 rd246589912th  |
      | completeorder 1234 654789 re2465899124th |
      | completeorder 1234 654789 re246589912ti  |

  Scenario Outline: Try to complete an order which has not been accepted
    Given a supplier_order exists with id: 654789, product_id: the product, status: "<order_status>"

    When I text "<text_message>" from "66354668789"
    Then the supplier_order should not be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "<order_status>", supplier: "Nok"

    Examples:
      | text_message                            | order_status |
      | completeorder 1234 654789 re246589912th | rejected     |
      | completeorder 1234 654789 re246589912th | unconfirmed  |

  Scenario: Try to complete an order which was already completed
    Given a supplier_order exists with id: 654789, product_id: the product, status: "completed"

    When I text "completeorder 1234 654789 re246589912th" from "66354668789"
    Then the supplier_order should be completed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "cannot process order" in "en" (English) where status: "completed", supplier: "Nok"

