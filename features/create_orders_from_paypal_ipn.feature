Feature: Create orders from a Paypal IPN
  In order to keep track of my orders
  As a seller or supplier
  I want to be notified when a product that I am selling or supplying is sold

  Background:
    Given a seller exists with name: "Mara", email: "mara@example.com"
    And a verified mobile number: "Mara's number" exists with user: the seller, number: "66354668789"
    And a supplier exists with name: "Dave"
    And a verified mobile number: "Dave's number" exists with number: "66123555331", user: the supplier
    And a partnership exists with seller: the seller, supplier: the supplier
    And a product: "Rubber Dingy" exists with seller: the seller, partnership: the partnership, number: "12345790063", name: "Model Ship - The Rubber Dingy"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'mc_gross' => '75.00',
      'mc_currency' => 'USD',
      'item_number' => '12345790063',
      'item_name' => 'Model Ship - The Rubber Dingy',
      'quantity' => '1',
      'receiver_email' => 'mara@example.com',
      'address_name' => 'Ho Chi Minh',
      'address_street' => '4 Chau Minh Lane',
      'address_city' => 'Hanoi',
      'address_state' => 'Hanoi Province',
      'address_country' => 'Viet Nam',
      'address_zip' => '52321'
    }
    """

  Scenario: The payment status is completed
    When the seller order paypal ipn is verified

    Then a seller order should exist

  Scenario: The payment status is not completed
    Given the seller order paypal ipn has the following params:
    """
    { 'payment_status' => 'Pending' }
    """

    When the seller order paypal ipn is verified

    Then a seller order should not exist

  Scenario Outline: A Paypal IPN for a single unknown item is received
    Given no products exist
    And the mobile number: "Mara's number" <is_not_yet_or_was_already> verified

    When the seller order paypal ipn is verified

    Then a seller order should exist
    And the seller order should be unconfirmed
    And the seller order should be incomplete
    And the seller order should be the seller order paypal ipn's seller_order
    And the seller should be the seller order paypal ipn's seller
    And the seller order should be amongst the seller's seller_orders

    And a supplier order should exist
    And the supplier order should be unconfirmed
    And the supplier order should be incomplete
    And the supplier order should be amongst the seller order's supplier_orders
    And the supplier order should be amongst the seller's supplier_orders

    And a product should exist with number: "12345790063", name: "Model Ship - The Rubber Dingy", price: "75.00"
    And the product should be amongst the seller's selling_products

    And a line item should exist
    And the line item should be unconfirmed
    And the line item should be amongst the seller order's line_items
    And the line item's seller_order_index should be "1"
    And the line item should be amongst the supplier order's line_items
    And the line item's supplier_order_index should be "1"
    And the line item should be amongst the product's line_items

    And the 3rd most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, u just sold 1 item(s) totalling 75.00 USD (order ref: #1). Order details will follow shortly
    """
    And the outgoing text message should <be_or_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    And the 2nd most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Mara, pls ship order #1 to:
    Ho Chi Minh
    4 Chau Minh Lane
    Hanoi
    Hanoi Province
    Viet Nam 52321
    then reply with: "co"
    """
    And the outgoing text message should <be_or_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1, 1/1:
    1 x 12345790063, "Model Ship - The Rubber Dingy", 75.00 USD
    Pls ship to customer
    """
    And the outgoing text message should <be_or_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    Examples:
      | is_not_yet_or_was_already | be_or_not_be |
      | is not yet                | not be       |
      | was already               | be           |

  Scenario Outline: A Paypal IPN for a single known item with a supplier is received
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified

    When the seller order paypal ipn is verified

    Then a supplier order should exist
    And the supplier order should be amongst the supplier's supplier_orders

    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1, 1/1:
    1 x 12345790063, "Model Ship - The Rubber Dingy", 75.00 USD
    Delegated to Dave (+66123555331)
    """
    And the outgoing text message should be queued_for_sending
    And the seller should be that outgoing text message's payer

    And the 2nd most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, u have a new order (ref: #1) from Mara (+66354668789) for 1 item(s). Order details will follow shortly
    """
    And the seller should be that outgoing text message's payer
    And the outgoing text message should <be_or_not_be> queued_for_sending

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Order #1, item #1, 1/1:
    1 x 12345790063, "Model Ship - The Rubber Dingy"
    Confirm by replying with: "ci <qty>"
    """
    And the seller should be that outgoing text message's payer
    And the outgoing text message should <be_or_not_be> queued_for_sending

    Examples:
      | is_not_yet_or_was_already | be_or_not_be |
      | is not yet                | not be       |
      | was already               | be           |

  Scenario: The seller has registered the product name but the product number is different
    Given the seller order paypal ipn has the following params:
    """
    { 'item_number' => '12345790062' }
    """

    When the seller order paypal ipn is verified

    Then the product's number should be "12345790062"
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should include "12345790062"

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include "12345790062"

  Scenario: The seller has registered the product number but the product name is different
    Given the seller order paypal ipn has the following params:
    """
    { 'item_name' => 'Model Ship - The Rubber Ducky' }
    """

    When the seller order paypal ipn is verified

    Then the product's name should be "Model Ship - The Rubber Ducky"

    And the most recent outgoing text message destined for mobile_number: "Mara's number" should include "Model Ship - The Rubber Ducky"

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include "Model Ship - The Rubber Ducky"

  Scenario: The seller has registered the product number with a different product name and has also registered the product name with a different product number
    Given another product: "Titanic" exists with seller: the seller, partnership: the partnership, number: "12345790062", name: "Model Ship - The Titanic"
    And the seller order paypal ipn has the following params:
    """
    {
      'item_number' => '12345790063',
      'item_name' => 'Model Ship - The Titanic'
    }
    """
    When the seller order paypal ipn is verified

    Then 1 products should exist
    And the product: "Rubber Dingy"'s number should be "12345790063"
    And the product: "Rubber Dingy"'s name should be "Model Ship - The Titanic"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should include "12345790063"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should include "Model Ship - The Titanic"
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include "12345790063"
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should include "Model Ship - The Titanic"

  Scenario: A Paypal IPN for 3 known items and 2 unknown item is received
    Given another supplier: "Andy" exists with name: "Andy"
    And a partnership: "with Andy" exists with seller: the seller, supplier: supplier: "Andy"
    And a verified mobile number: "Andy's number" exists with number: "614121223322", user: supplier: "Andy"
    And another product exists with seller: the seller, partnership: partnership: "with Andy", number: "1902838475476", name: "Model Ship - The Titanic"
    And another product exists with seller: the seller, partnership: partnership: "with Andy", number: "1902838475479", name: "Model Ship - The Endevour"
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'receiver_email' => 'mara@example.com',
      'mc_gross' => '664.60',
      'mc_gross_1' => '150.00',
      'mc_gross_2' => '260.00',
      'mc_gross_3' => '39.75',
      'mc_gross_4' => '15.87',
      'mc_gross_5' => '198.98',
      'mc_currency' => 'USD',
      'item_name1' => 'Model Ship - The Rubber Dingy',
      'item_name2' => 'Model Ship - The Titanic',
      'item_name3' => 'A Red Dress',
      'item_name4' => 'A Blue Dress',
      'item_name5' => 'Endeveour Ship',
      'item_number1' => '12345790063',
      'item_number2' => '1902838475476',
      'item_number3' => '1902838475477',
      'item_number4' => '1902838475478',
      'item_number5' => '1902838475479',
      'quantity1' => '2',
      'quantity2' => '4',
      'quantity3' => '3',
      'quantity4' => '1',
      'quantity5' => '1',
      'num_cart_items' => '5'
    }
    """

    When the seller order paypal ipn is verified

    And 3 supplier orders should exist
    And 5 products should exist
    And 5 line items should exist
    And the 7th most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, u just sold 5 item(s) totalling 664.60 USD (order ref: #1). Order details will follow shortly
    """
    And the 6th most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1, 1/5:
    2 x 12345790063, "Model Ship - The Rubber Dingy", 150.00 USD
    Delegated to Dave (+66123555331)
    """
    And the 5th most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #2, 2/5:
    4 x 1902838475476, "Model Ship - The Titanic", 260.00 USD
    Delegated to Andy (+614121223322)
    """
    And the 4th most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #3, 5/5:
    1 x 1902838475479, "Endeveour Ship", 198.98 USD
    Delegated to Andy (+614121223322)
    """
    And the 3rd most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Mara, pls ship order #1 to:
    Ho Chi Minh
    4 Chau Minh Lane
    Hanoi
    Hanoi Province
    Viet Nam 52321
    then reply with: "co"
    """
    And the 2nd most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #4, 3/5:
    3 x 1902838475477, "A Red Dress", 39.75 USD
    Pls ship to customer
    """
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #5, 4/5:
    1 x 1902838475478, "A Blue Dress", 15.87 USD
    Pls ship to customer
    """

    And the 2nd most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, u have a new order (ref: #1) from Mara (+66354668789) for 1 item(s). Order details will follow shortly
    """
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Order #1, item #1, 1/1:
    2 x 12345790063, "Model Ship - The Rubber Dingy"
    Confirm by replying with: "ci <qty>"
    """

    And the 3rd most recent outgoing text message destined for the mobile number: "Andy's number" should be
    """
    Hi Andy, u have a new order (ref: #1) from Mara (+66354668789) for 2 item(s). Order details will follow shortly
    """
    And the 2nd most recent outgoing text message destined for the mobile number: "Andy's number" should be
    """
    Order #1, item #2, 1/2:
    4 x 1902838475476, "Model Ship - The Titanic"
    Confirm by replying with: "ci <qty>"
    """
    And the most recent outgoing text message destined for the mobile number: "Andy's number" should be
    """
    Order #1, item #3, 2/2:
    1 x 1902838475479, "Endeveour Ship"
    Confirm by replying with: "ci <qty>"
    """

