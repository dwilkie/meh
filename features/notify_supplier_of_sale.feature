Feature: Notify the supplier by text message when an item is payed for via paypal
  In order to ship my product and get paid from my seller
  As a supplier
  I want to be informed when a buyer has paid for a product that I should deliver

  Scenario: Buyer purchases a single item
    Given a seller exists with email: "seller@gmail.com"
    And a supplier exists with email: "bob@gmail.com", name: "Bob"
    And a mobile_number exists with phoneable: the supplier
    And a product exists with seller: the seller, supplier: the supplier, external_id: "12345"
    
    When a buyer successfully purchases 1 product from the seller through paypal with external_id: "12345"

    Then a paypal_ipn should exist with payment_status: "Completed"
    And an order: "customer order" should exist with seller_id: the seller, status: "unconfirmed"
    And the paypal_ipn should be the order: "customer order" paypal_ipn
    And the order: "customer order" should be amongst the seller's customer_orders
    And an order: "supplier order" should exist with supplier_id: the supplier, status: "unconfirmed"
    And the order: "supplier order" should be amongst the supplier's supplier_orders
    And a supplier_order_notification_conversation should exist with with: the mobile_number, topic: "supplier_order_notification"
    And the supplier_order_notification_conversation should be finished
    And an outgoing_text_message should exist with smsable_id: the mobile_number, conversation_id: the supplier_order_notification_conversation
    And the outgoing_text_message should be amongst the mobile_number's outgoing_text_messages
    And the outgoing_text_message should be amongst the supplier_order_notification_conversation's outgoing_text_messages
    And the outgoing_text_message should be a translation of "supplier order notification" in "en" (English) where supplier: "Bob", product_code: "12345", quantity: "1", order_number: "2"
