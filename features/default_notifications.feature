Feature: Default Notifications
  In order to make it easier to get started
  As a seller
  I want to have default notifications set up for me after I register and be able to reset my notifications at any time

  Scenario: New seller is created
    When a seller is created

    #Then the seller should have 5 notifications

    And a notification should exist with seller_id: the seller, event: "customer_order_created", for: "seller", purpose: "to inform me about the customer order details", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "a customer completed payment for..."

    And a notification should exist with seller_id: the seller, event: "product_order_created", for: "seller", purpose: "to inform me which supplier a product order was sent to", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "product order was sent to..." in "en" (English)

    And a notification should exist with seller_id: the seller, event: "product_order_created", for: "seller", purpose: "to inform me which supplier a product order was sent to", enabled: true, should_send: false, supplier_id: the seller

    And a notification should exist with seller_id: the seller, event: "product_order_created", for: "supplier", purpose: "to inform the supplier about the product order details", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "you have a new product order from... for the following item..." in "en" (English)

    And a notification should exist with seller_id: the seller, event: "product_order_created", for: "supplier", purpose: "to inform the supplier about the product order details", enabled: true, should_send: true, supplier_id: the seller
    And the notification should have a message which is a translation of: "your customer bought the following item..." in "en" (English)

    And a notification should exist with seller_id: the seller, event: "product_order_accepted", for: "seller", purpose: "to inform me when a supplier accepts a product order", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "your supplier processed their product order..." in "en" (English) where processed: "ACCEPTED"

    And a notification should exist with seller_id: the seller, supplier_id: the seller, event: "product_order_accepted", for: "seller", purpose: "to inform me when a supplier accepts a product order", enabled: true, should_send: false

    And a notification should exist with seller_id: the seller, event: "product_order_accepted", for: "supplier", purpose: "to inform the supplier that they successfully accepted their product order", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "you successfully processed the product order..." in "en" (English) where processed: "accepted"

    And a notification should exist with seller_id: the seller, event: "product_order_accepted", for: "supplier", purpose: "to inform the supplier of the shipping instructions", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "send the product to..." in "en" (English)

    And a notification should exist with seller_id: the seller, event: "product_order_accepted", for: "supplier", purpose: "to inform the supplier of the shipping instructions", enabled: true, should_send: false, supplier_id: the seller

    And a notification should exist with seller_id: the seller, event: "product_order_rejected", for: "seller", purpose: "to inform me when a supplier rejects a product order", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "your supplier processed their product order..." in "en" (English) where processed: "REJECTED"

    And a notification should exist with seller_id: the seller, supplier_id: the seller, event: "product_order_rejected", for: "seller", purpose: "to inform me when a supplier rejects a product order", enabled: true, should_send: false

    And a notification should exist with seller_id: the seller, event: "product_order_rejected", for: "supplier", purpose: "to inform the supplier that they successfully rejected their product order", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "you successfully processed the product order..." in "en" (English) where processed: "rejected"

    And a notification should exist with seller_id: the seller, event: "product_order_completed", for: "seller", purpose: "to inform me when a supplier completes a product order", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "your supplier processed their product order..." in "en" (English) where processed: "COMPLETED"

    And a notification should exist with seller_id: the seller, supplier_id: the seller, event: "product_order_completed", for: "seller", purpose: "to inform me when a supplier completes a product order", enabled: true, should_send: false

    And a notification should exist with seller_id: the seller, event: "product_order_completed", for: "supplier", purpose: "to inform the supplier that they successfully completed their product order", enabled: true, should_send: true
    And the notification should have a message which is a translation of: "you successfully processed the product order..." in "en" (English) where processed: "completed"

