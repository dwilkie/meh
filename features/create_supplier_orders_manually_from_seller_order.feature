Feature: Create supplier orders manually from a seller order
  In order to recover from a situation where products don't exist before an order notification is received
  As a seller
  I want to be able to manually create supplier orders for newly added products that belong to an existing seller order

  Background:
    Given a seller exists with email: "some_seller@example.com"
    And a supplier exists

  Scenario Outline: The seller did not add products for the item numbers contained in the order notification before it was received. After the order notification was received the seller went ahead and added a product with one of the item numbers contained in the order notification. The seller then manually requested supplier orders to be created for the seller order.

    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a seller_order should exist
    But 0 supplier_orders should exist

    Given a product exists with seller: the seller, supplier: the supplier, number: "12345790063"

    When a manual creation of supplier orders is triggered for the seller_order

    Then 1 supplier_orders should exist
    And a supplier_order should exist with product_id: the product, supplier_id: the supplier, quantity: "1", seller_order_id: the seller_order

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | "Completed"    | "{'item_number1'=>'12345790063', 'item_number2'=>'12345790064', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'quantity2'=>'2', 'num_cart_items'=>'2'}"                |

  Scenario Outline: The seller added a product for one item number contained in the order notification before it was received but did not add a one for the other item number. After the order notification was received the seller went ahead and added a product for the other item number contained in the order notification. The seller then manually requested supplier orders to be created for the seller order.

    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>
    And a product exists with seller: the seller, supplier: the supplier, item_number: "12345790063"

    When the <order_notification> is verified

    Then a seller_order should exist
    And 1 supplier_orders should exist
    And a supplier_order should exist with product_id: the product, supplier_id: the supplier, quantity: "1", seller_order_id: the seller_order

    Given a product exists with seller: the seller, supplier: the supplier, item_number: "12345790064"

    When a manual creation of supplier orders is triggered for the seller_order

    Then 2 supplier_orders should exist
    And a supplier_order should exist with product_id: the product, supplier_id: the supplier, quantity: "2", seller_order_id: the seller_order

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | "Completed"    | "{'item_number1'=>'12345790063', 'item_number2'=>'12345790064', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'quantity2'=>'2', 'num_cart_items'=>'2'}"                |

