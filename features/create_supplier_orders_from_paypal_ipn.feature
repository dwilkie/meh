Feature: Create line items from an order notification
  In order to keep track of my orders
  As a supplier
  I want a new line item to be created when a paypal ipn containing a product that I am supplying is verified and the payment status is completed

  Background:
    Given a seller exists with name: "Mara", email: "mara@example.com"
    And a verified mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a supplier exists with name: "Dave"
    And a product: "Rubber Dingy" exists with seller: the seller, supplier: the supplier, number: "12345790063", name: "Model Ship - The Rubber Dingy"
    And a verified mobile number: "Dave's number" exists with number: "66123555331", user: the supplier

  Scenario: The payment status is not completed
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'item_number' => '12345790063',
      'item_name' => 'Model Ship - The Rubber Dingy',
      'receiver_email'=>'mara@example.com',
      'quantity' => '1'
    }
    """

    When the seller order paypal ipn is verified
    Then a supplier order should not exist
    And a line item should not exist

  @current
  Scenario: The payment status is completed
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number' => '12345790063',
      'item_name' => 'Model Ship - The Rubber Dingy',
      'receiver_email'=>'mara@example.com',
      'quantity' => '1',
      'mc_currency' => 'AUD',
      'mc_gross' => '100.00'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller order should exist
    And a supplier order should exist with seller_order_id: the seller order
    And a line item should exist with product_id: the product, quantity: 1, supplier_order_id: the supplier order
    And the supplier order should be unconfirmed
    And the supplier order should be amongst the seller_order's supplier_orders
    And the supplier order should be amongst the supplier's supplier_orders
    And the line item should be unconfirmed
    And the line item should be amongst the supplier_order's line_items
    And the line item should be amongst the supplier's line_items
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1, 1/1:
    1 x 12345790063, "Model Ship - The Rubber Dingy", 100.00 AUD
    Status: Sent to Dave (+66123555331)
    """
    And the seller should be that outgoing text message's payer
    And the 2nd most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, u have a new order (ref: #1) from Mara (+66354668789) for 1 item(s). Order details will follow shortly
    """
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Order #1, item #1, 1/1:
    1 x 12345790063, "Model Ship - The Rubber Dingy"
    Confirm by replying with: "ci <qty>"
    """
    And the seller should be that outgoing text message's payer

  Scenario Outline: The supplier is also the seller of this product
    Given the mobile number: "Mara's number" <is_not_yet_or_was_already> verified
    And a product exists with seller: the seller, supplier: the seller, number: "12345790069", name: "Model Ship - The Titanic"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number' => '12345790069',
      'item_name' => 'Model Ship - The Titanic',
      'receiver_email'=>'mara@example.com',
      'quantity' => '1',
      'mc_currency' => 'AUD',
      'mc_gross' => '100.00'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller_order should exist
    And a supplier order should exist with seller_order_id: the seller order
    And a line item should exist with product_id: the product, quantity: 1, supplier_order_id: the supplier order
    And the supplier order should be unconfirmed
    And the supplier order should be amongst the seller_order's supplier_orders
    And the supplier order should be amongst the seller's supplier_orders
    And the line item should be unconfirmed
    And the line item should be amongst the supplier_order's line_items
    And the line item should be amongst the seller's line_items
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1:
    1 x 12345790069, "Model Ship - The Titanic", 100.00 AUD
    """
    And the outgoing text message <should_or_should_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    Examples:
      | is_not_yet_or_was_already | should_or_should_not_be |
      | was already               | should be               |
      | is not yet                | should not be           |

  Scenario Outline: The seller has not registered this product
    Given the mobile number: "Mara's number" <is_not_yet_or_was_already> verified
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number' => '12345790062',
      'item_name' => 'Model Ship - The Rubber Ducky',
      'receiver_email'=>'mara@example.com',
      'quantity'=>'1',
      'mc_currency' => 'AUD',
      'mc_gross' => '100.00'
    }
    """

    When the seller order paypal ipn is verified

    Then a product should exist with number: "12345790062", name: "Model Ship - The Rubber Ducky", price: "100.00", seller_id: the seller, supplier_id: the seller
    And a seller_order should exist
    And a supplier order should exist with seller_order_id: the seller order
    And a line item should exist with product_id: the product, quantity: 1, supplier_order_id: the supplier order
    And the supplier order should be unconfirmed
    And the supplier order should be amongst the seller_order's supplier_orders
    And the supplier order should be amongst the seller's supplier_orders
    And the line item should be unconfirmed
    And the line item should be amongst the supplier_order's line_items
    And the line item should be amongst the seller's line_items
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1:
    1 x 12345790062, "Model Ship - The Rubber Ducky", 100.00 AUD
    """
    And the outgoing text message <should_or_should_not_be> queued_for_sending
    And the seller should be that outgoing text message's payer

    Examples:
      | is_not_yet_or_was_already | should_or_should_not_be |
      | was already               | should be               |
      | is not yet                | should not be           |

  Scenario: The seller has registered this product name but the product number is different
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number' => '12345790062',
      'item_name' => 'Model Ship - The Rubber Dingy',
      'receiver_email' => 'mara@example.com',
      'quantity' => '1',
      'mc_currency' => 'AUD',
      'mc_gross' => '100.00'
    }
    """

    When the seller order paypal ipn is verified

    Then the product's number should be "12345790062"
    And the product's name should be "Model Ship - The Rubber Dingy"
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Order #1, item #1:
    1 x 12345790062, "Model Ship - The Rubber Dingy", 100.00 AUD
    Status: Sent to Dave (+66123555331)
    """
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Order #1, item #1:
    1 x 12345790062, "Model Ship - The Rubber Dingy"
    Confirm by replying with: "ci <qty>"
    """

  Scenario: The seller has registered this product number but the product name is different
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number' => '12345790063',
      'item_name' => 'Model Ship - The Rubber Ducky',
      'receiver_email' => 'mara@example.com',
      'quantity'=>'1',
      'mc_currency' => 'AUD',
      'mc_gross' => '100.00'
    }
    """

    When the seller order paypal ipn is verified

    Then the product's number should be "12345790063"
    And the product's name should be "Model Ship - The Rubber Ducky"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Order #1, item #1:
    1 x 12345790063, "Model Ship - The Rubber Ducky", 100.00 AUD
    Status: Sent to Dave (+66123555331)
    """
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Order #1, item #1:
    1 x 12345790063, "Model Ship - The Rubber Ducky"
    Confirm by replying with: "ci <qty>"
    """

  Scenario: The seller has registered this product number with a different product name and has also registered this product name with a different product number
    Given a product: "Titanic" exists with seller: the seller, supplier: the supplier, number: "12345790062", name: "Model Ship - The Titanic"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number' => '12345790063',
      'item_name' => 'Model Ship - The Titanic',
      'receiver_email' => 'mara@example.com',
      'quantity' => '1',
      'mc_currency' => 'AUD',
      'mc_gross' => '100.00'
    }
    """
    When the seller order paypal ipn is verified

    Then 1 products should exist
    And the product: "Rubber Dingy"'s number should be "12345790063"
    And the product: "Rubber Dingy"'s name should be "Model Ship - The Titanic"
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Order #1, item #1:
    1 x 12345790063, "Model Ship - The Titanic", 100.00 AUD
    Status: Sent to Dave (+66123555331)
    """
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Order #1, item #1:
    1 x 12345790063, "Model Ship - The Titanic"
    Confirm by replying with: "ci <qty>"
    """

