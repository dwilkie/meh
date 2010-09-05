Feature: Create a seller order from an order notification
  In order to keep track of my orders
  As a seller
  I want a new seller order to be created when a order notification is verified and the payment is completed

  Background:
    Given a seller exists with name: "Mara", email: "mara@example.com"

  Scenario Outline: The payment status is completed and the seller has a verified and active mobile number
    Given a verified active mobile number exists with user: the seller
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller order should exist
    And the seller order should be the <order_notification> seller_order
    And the seller should be the <order_notification> seller
    And the seller order should be amongst the seller's seller_orders
    And the 2nd most recent outgoing text message destined for the mobile number should be
    """
    Hi Mara, a customer just completed payment for 1 of your products. The customer's shipping address is:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    We'll send you more details about the items in this order shortly. Your customer order number is: #1
    """

    Examples:
      | order_notification | payment_status | params                             |
      | paypal_ipn         | Completed      | {'receiver_email' => 'mara@example.com', 'address_name' => 'Ho Chi Minh', 'address_street' => '4 Chau Minh Lane', 'address_city' => 'Hanoi', 'address_state' => 'Hanoi Province', 'address_country' => 'Viet Nam', 'address_zip' => '52321'}                                                                         |

  Scenario Outline: The payment status is not completed
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller order should not exist

    Examples:
      | order_notification | payment_status | params   |
      | paypal_ipn         | Pending        | {'receiver_email' => 'mara@example.com'}                                    |

  Scenario Outline: The payment status is completed but the does not have any mobile numbers
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller order should exist
    But an outgoing text message should not exist

    Examples:
      | order_notification | payment_status | params |
      | paypal_ipn         | Completed      | {'receiver_email' => 'mara@example.com'}                                 |


  Scenario Outline: The payment status is completed but the seller does not have an active or verified mobile number
    Given a mobile number exists with user: the seller
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller order should exist
    But an outgoing text message should not exist with mobile_number_id: the mobile number

    Examples:
      | order_notification | payment_status | params |
      | paypal_ipn         | Completed      | {'receiver_email' => 'mara@example.com'}                                 |

  Scenario Outline: The payment status is completed and the seller has an active mobile number but it is not verified
    Given an active mobile number exists with user: the seller
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller order should exist
    But an outgoing text message should not exist with mobile_number_id: the mobile number

    Examples:
      | order_notification | payment_status | params |
      | paypal_ipn         | Completed      | {'receiver_email' => 'mara@example.com'}                                  |

