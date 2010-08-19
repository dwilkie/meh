Feature: Default Notifications
  In order to make it easier to get started
  As a seller
  I want to have default notifications set up for me after I register and be able to reset my notifications at any time

  Scenario: New seller is created
    When a new seller is created

    Then the seller should have 5 notifications
    And a notification should exist with seller: the seller, event: "supplier_order_accepted", for: "seller"
    And the notification should have the following message:
    """
    Hi <seller_name>, <supplier_name> (<supplier_mobile_number>) has accepted their order (<supplier_order_number>) of <supplier_order_quantity> x <product_code> (<product_name>) which belongs to your seller order (<seller_order_number>)
    """
    And a notification should exist with seller: the seller, event: "supplier_order_accepted", for: "supplier"
    And the notification should have the following message:
    """
    Hi <supplier_name>, you successfully accepted the order <supplier_order_number>
    """
    And a notification should exist with seller: the seller, supplier: the seller, event: "supplier_order_accepted", for: "supplier"
    And the notification should have the following message:
    """
    Hi <supplier_name>, you successfully accepted the order <supplier_order_number>
    """

