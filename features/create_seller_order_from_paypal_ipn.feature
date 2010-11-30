Feature: Create a seller order from an order notification
  In order to keep track of my orders
  As a seller
  I want a new seller order (customer order) to be created when a order notification is verified and the payment is completed

  Background:
    Given a seller exists with name: "Mara", email: "mara@example.com"
    And a verified mobile number exists with user: the seller

  Scenario: The payment status is completed
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'receiver_email' => 'mara@example.com'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should exist

  Scenario: The payment status is not completed
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Pending',
      'receiver_email' => 'mara@example.com'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should not exist

  Scenario Outline: A Paypal IPN for a single item is received
    Given the mobile number <is_not_yet_or_was_already> verified
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'receiver_email' => 'mara@example.com',
      'mc_gross' => '75.00',
      'mc_currency' => 'USD'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should exist
    And the seller order should be the seller order paypal ipn's seller_order
    And the seller should be the seller order paypal ipn's seller
    And the seller order should be amongst the seller's seller_orders
    And a line item should exist
    And the line item should be amongst the seller order's line_items
    And the line item's seller_order_index should be "1"
    And the 3rd most recent outgoing text message destined for the mobile number should be
    """
    Hi Mara, u just sold 1 item(s) totalling 75.00 USD (order ref: #1). Order details will follow shortly
    """
    And the outgoing text message <should_be_or_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    Examples:
      | is_not_yet_or_was_already | should_be_or_not_be |
      | is not yet                | should not be       |
      | was already               | should be           |

  Scenario: A Paypal IPN for multiple items is received
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'receiver_email' => 'mara@example.com',
      'mc_gross' => '140.00',
      'mc_gross_1' => '75.00',
      'mc_gross_2' => '65.00',
      'mc_currency' => 'USD',
      'item_name1' => 'Some Manky Product',
      'item_name2' => 'Another Manky Product',
      'item_number1' => '1902838475475',
      'item_number2' => '1902838475476',
      'quantity1' => '2',
      'quantity2' => '4',
      'num_cart_items' => '2'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should exist
    And the seller order should be the seller order paypal ipn's seller_order
    And the seller should be the seller order paypal ipn's seller
    And the seller order should be amongst the seller's seller_orders
    And 2 line items should exist
    And the 4th most recent outgoing text message destined for the mobile number should be
    """
    Hi Mara, u just sold 2 item(s) totalling 140.00 USD (order ref: #1). Order details will follow shortly
    """
    And the outgoing text message should be queued for sending
    And the seller should be that outgoing text message's payer

