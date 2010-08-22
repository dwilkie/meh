Feature: Create a seller order from an order notification
  In order to keep track of my orders
  As a seller
  I want a new seller order to be created when a order notification is verified and the payment is completed

  Background:
    Given a mobile_number exists
    And a seller exists with name: "Mara", email: "mara@example.com", mobile_number: the mobile_number

  Scenario Outline: The payment status is completed
    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a seller_order should exist
    And the seller_order should be the <order_notification> seller_order
    And the seller should be the <order_notification> seller
    And the seller_order should be amongst the seller's seller_orders
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be
    """
    Hi Mara, a customer just completed payment for 0 of your products. The customer's shipping address is:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    We'll send you more details about the items in this order shortly. Your customer order number is: 1
       """

    Examples:
      | order_notification | payment_status | params                             |
      | paypal_ipn         | "Completed" | "{'receiver_email'=>'mara@example.com', 'address_name' => 'Ho Chi Minh', 'address_street' => '4 Chau Minh Lane', 'address_city' => 'Hanoi', 'address_state' => 'Hanoi Province', 'address_country' => 'Viet Nam', 'address_zip' => '52321', 'num_cart_items' => '0'}"                              |

  Scenario Outline: The payment status is not completed
    Given an <order_notification> exists
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a seller_order should not exist

    Examples:
      | order_notification | params                                          |
      | paypal_ipn         | "{'receiver_email'=>'mara@example.com'}" |

