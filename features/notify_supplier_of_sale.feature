Feature: Notify the supplier by text message when an item is payed for via paypal
  In order to ship my product and get paid from my seller
  As a supplier
  I want to be informed when a buyer has paid for a product that I should deliver

  Scenario: Buyer purchases a single item
    Given a seller exists with email: "seller@gmail.com"
    And a supplier exists with email: "supplier@gmail.com"

    And a product exists with seller: the seller, supplier: the supplier, external_id: "12345"
    
    When a buyer successfully purchases 1 product from the seller through paypal with external_id: "12345"
    
    Then a paypal_ipn should exist with payment_status: "Completed"
    And an order: "customer order" should exist with status: "unconfirmed"

    And the paypal_ipn should be the order: "customer order" paypal_ipn
    And the order: "customer order" should be amongst the seller customer_orders

    And an order: "supplier order" should exist with status: "unconfirmed"
    And the order: "supplier order" should be amongst the supplier supplier_orders
    
    And a line_item should exist with order: order "supplier_order", product: the product, quantity: 1

    And I should receive a text message which is a translation of "order received" in "en" (English)
    
    And the seller should have 1 order
    And the supplier should have 1 order
