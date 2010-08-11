Feature: Create a seller order from an order notification
  In order to keep track of my orders
  As a seller
  I want a new seller order to be created when a order notification is verified and the payment is completed

  Background:
    Given a seller exists with email: "some_seller@example.com"

  Scenario Outline: The payment status is completed
    Given an <order_notification> exists with payment_status: <payment_status>
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a seller_order should exist
    And the seller_order should be the <order_notification> seller_order
    And the seller should be the <order_notification> seller
    And the seller_order should be amongst the seller's seller_orders

    Examples:
      | order_notification | payment_status | params                                       |
      | paypal_ipn         | "Completed" | "{'receiver_email'=>'some_seller@example.com'}" |

  Scenario Outline: The payment status is not completed
    Given an <order_notification> exists
    And the <order_notification> has the following params: <params>

    When the <order_notification> is verified

    Then a seller_order should not exist

    Examples:
      | order_notification | params                                          |
      | paypal_ipn         | "{'receiver_email'=>'some_seller@example.com'}" |

