Feature: Create supplier orders from an order notification
  In order to keep track of my orders
  As a supplier
  I want a new supplier order to be created when an order notification containing a product that I am supplying is verified and the payment status is completed

  Background:
    Given a mobile_number: "seller's number" exists with number: "66354668789"
    And a seller exists with email: "some_seller@example.com", mobile_number: the mobile_number, name: "Dave"
    And a supplier exists
    And a product exists with seller: the seller, supplier: the supplier, number: "12345790063", name: "Model Ship - The Rubber Dingy"

  Scenario Outline: The payment status is completed
    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a seller_order should exist
    And a supplier_order should exist with supplier_id: the supplier, product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be amongst the supplier's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | "Completed"    | "{'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}"                                                                      |

  Scenario Outline: The payment status is not completed
    Given an <order_notification> exists
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a supplier_order should not exist

    Examples:
      | order_notification | params                                           |
      | paypal_ipn         | "{'item_number1'=>'12345790063', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}"                                                       |

  Scenario Outline: The seller has not registered this product
    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a supplier_order should not exist
    But a seller_order should exist
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be
    """
    Hi Dave, the customer order: 1, contains the following item which is not registered with us: 12345790062 (Model Ship - The Rubber Ducky). Reply with "rp 12345790062 1" to register the new product. For other options log in to your account
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | "Completed"    | "{'item_number1'=>'12345790062', 'item_name1' => 'Model Ship - The Rubber Ducky', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}"                                                    |

  Scenario Outline: The seller has registered this product name but the product number is different
    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a supplier_order should not exist
    But a seller_order should exist
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be
    """
    Hi Dave, you have the following product: 12345790063 (Model Ship - The Rubber Dingy) registered with us, but the customer order: 1, contains the following item instead: 12345790062 (Model Ship - The Rubber Dingy). Reply with: "up 12345790063 1" to update your existing product details with the details from this order. For other options log in to your account
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | "Completed"    | "{'item_number1'=>'12345790062', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}"                                                    |

  Scenario Outline: The seller has registered this product number but the product name is different
    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a supplier_order should not exist
    But a seller_order should exist
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be
    """
    Hi Dave, you have the following product: 12345790063 (Model Ship - The Rubber Dingy) registered with us, but the customer order: 1, contains the following item instead: 12345790063 (Model Ship - The Rubber Ducky). Reply with: "up 12345790063 1" to update your existing product details with the details from this order. For other options log in to your account
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | "Completed"    | "{'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Ducky', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}"                                                    |

