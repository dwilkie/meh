Feature: Create a seller order from an order notification
  In order to keep track of my orders
  As a seller
  I want a new seller order to be created when a order notification is verified and the payment is completed

  Background:
    Given a seller exists with name: "Mara", email: "mara@example.com"
    And a mobile number exists with user: the seller

  Scenario Outline: The payment status is completed
    Given the mobile number <is_not_yet_or_was_already> verified
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'receiver_email' => 'mara@example.com',
      'address_name' => 'Ho Chi Minh',
      'address_street' => '4 Chau Minh Lane',
      'address_city' => 'Hanoi',
      'address_state' => 'Hanoi Province',
      'address_country' => 'Viet Nam',
      'address_zip' => '52321'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should exist
    And the seller order should be the seller order paypal ipn's seller_order
    And the seller should be the seller order paypal ipn's seller
    And the seller order should be amongst the seller's seller_orders
    And the 2nd most recent outgoing text message destined for the mobile number <should_or_should_not_be>
    """
    Hi Mara, a customer just completed payment for 1 of your products. The customer's shipping address is:
    Ho Chi Minh,
    4 Chau Minh Lane,
    Hanoi,
    Hanoi Province,
    Viet Nam 52321
    We'll send you more details about the items in this order shortly. Your customer order number is: #1
    """
    And the seller should be that outgoing text message's payer

    Examples:
      | is_not_yet_or_was_already | should_or_should_not_be |
      | was already               | should be               |
      | is not yet                | should not be           |

  Scenario: The payment status is not completed
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'receiver_email' => 'mara@example.com'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should not exist

