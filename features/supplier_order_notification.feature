Feature: Notify the supplier by text message when a supplier order is created
  In order to ship my product and get paid from my seller
  As a supplier
  I want to be notified when a supplier order is created belonging to me

  Scenario: Send me a supplier order notification
    Given a supplier exists with name: "Bob"
    And a mobile_number exists with phoneable: the supplier
    And a product exists with supplier: the supplier, external_id: "12345"

    When an order is created with supplier_id: the supplier, product_id: the product, quantity: 1

    Then the order should be unconfirmed
    And the order should be amongst the supplier's supplier_orders
    And a supplier_order_notification_conversation should exist with with: the supplier, topic: "supplier_order_notification"
    And the supplier_order_notification_conversation should be finished
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be amongst the mobile_number's outgoing_text_messages
    And the outgoing_text_message should be a translation of "supplier order notification" in "en" (English) where supplier: "Bob", product_code: "12345", quantity: "1", order_number: "1"
