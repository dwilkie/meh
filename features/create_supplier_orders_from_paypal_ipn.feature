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
  Scenario Outline: The payment status is completed
    Given the mobile number: "Mara's number" <seller_number_verified> verified
    And the mobile number: "Dave's number" <supplier_number_verified> verified
    And a seller order paypal ipn exists
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
    Order #1, item #1:
    1 x 12345790063, "Model Ship - The Rubber Dingy", 100.00 AUD
    Status: Sent to Dave (<supplier_number>)
    """
    And the outgoing text message <send_to_seller> be queued_for_sending
    And the seller should be that outgoing text message's payer
    And the 2nd most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, u have a new order (ref: #1) from Mara (<seller_number>) for 1 item(s). Order details and shipping instructions will be sent to u shortly
    """
    And the outgoing text message <send_to_supplier> be queued_for_sending
    And the seller should be that outgoing text message's payer

    Examples:
      | seller_number_verified | seller_number | supplier_number_verified | supplier_number | send_to_seller | send_to_supplier |
      | was already | +66354668789 | was already | +66123555331        | should | should               |
      | was already | +66354668789 | is not yet  | No verified number! | should | should not           |
      | is not yet | No verified number! | was already  | +66123555331 | should not | should           |
      | is not yet | No verified number! | is not yet  | No verified number! | should not | should not |

  Scenario Outline: The supplier is also the seller of this product
    Given the mobile number: "Mara's number" <is_not_yet_or_was_already> verified
    And a product exists with seller: the seller, supplier: the seller, number: "12345790069", name: "Model Ship - The Titanic"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number1' => '12345790069',
      'item_name1' => 'Model Ship - The Titanic',
      'receiver_email'=>'mara@example.com',
      'quantity1' => '1',
      'num_cart_items' => '1'
    }
    """

    When the seller order paypal ipn is verified

    Then a seller_order should exist
    And a line_item should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the line_item should be unconfirmed
    And the line_item should be amongst the seller_order's line_items
    And the line_item should be amongst the seller's line_items
    And the most recent outgoing text message destined for the mobile number: "Mara's number" <should_or_should_not_be>
    """
    Hi Mara, the customer bought 1 x 12345790069 (Model Ship - The Titanic) as part of the customer order: #1. A new line item: #1, was created to help you track the progress of this item. To mark this line item as completed, reply with: "cpo"
    """
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
      'item_number1' => '12345790062',
      'item_name1' => 'Model Ship - The Rubber Ducky',
      'receiver_email'=>'mara@example.com',
      'quantity1'=>'1',
      'num_cart_items'=>'1'
    }
    """

    When the seller order paypal ipn is verified

    Then a product should exist with number: "12345790062", name: "Model Ship - The Rubber Ducky", seller_id: the seller, supplier_id: the seller
    And a seller_order should exist
    And a line_item should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the line_item should be unconfirmed
    And the line_item should be amongst the seller_order's line_items
    And the line_item should be amongst the seller's line_items
    And the most recent outgoing text message destined for the mobile number: "Mara's number" <should_or_should_not_be>
    """
    Hi Mara, the customer bought 1 x 12345790062 (Model Ship - The Rubber Ducky) as part of the customer order: #1. A new line item: #1, was created to help you track the progress of this item. To mark this line item as completed, reply with: "cpo"
    """
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
      'item_number1' => '12345790062',
      'item_name1' => 'Model Ship - The Rubber Dingy',
      'receiver_email' => 'mara@example.com',
      'quantity1' => '1',
      'num_cart_items' => '1'
    }
    """

    When the seller order paypal ipn is verified

    Then the product's number should be "12345790062"
    And the product's name should be "Model Ship - The Rubber Dingy"
    And a seller_order should exist
    And a line_item should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the line_item should be unconfirmed
    And the line_item should be amongst the seller_order's line_items
    And the line_item should be amongst the supplier's line_items
    And the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, FYI: a new line item for 1 x 12345790062 (Model Ship - The Rubber Dingy) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, you have a new line item: #1, from Mara (+66354668789) for 1 x 12345790062 (Model Ship - The Rubber Dingy). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """
    And the seller should be that outgoing text message's payer

  Scenario: The seller has registered this product number but the product name is different
    Given a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number1' => '12345790063',
      'item_name1' => 'Model Ship - The Rubber Ducky',
      'receiver_email' => 'mara@example.com',
      'quantity1'=>'1',
      'num_cart_items'=>'1'
    }
    """

    When the seller order paypal ipn is verified

    Then the product's number should be "12345790063"
    And the product's name should be "Model Ship - The Rubber Ducky"
    And a seller_order should exist
    And a line_item should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the line_item should be unconfirmed
    And the line_item should be amongst the seller_order's line_items
    And the line_item should be amongst the supplier's line_items
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, FYI: a new line item for 1 x 12345790063 (Model Ship - The Rubber Ducky) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for mobile_number: "Dave's number" should be
    """
    Hi Dave, you have a new line item: #1, from Mara (+66354668789) for 1 x 12345790063 (Model Ship - The Rubber Ducky). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """
    And the seller should be that outgoing text message's payer

  Scenario: The seller has registered this product number with a different product name and has also registered this product name with a different product number
    Given a product: "Titanic" exists with seller: the seller, supplier: the supplier, number: "12345790062", name: "Model Ship - The Titanic"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'item_number1' => '12345790063',
      'item_name1' => 'Model Ship - The Titanic',
      'receiver_email' => 'mara@example.com',
      'quantity1' => '1',
      'num_cart_items' => '1'
    }
    """
    When the seller order paypal ipn is verified

    Then 1 products should exist
    And the product: "Rubber Dingy"'s number should be "12345790063"
    And the product: "Rubber Dingy"'s name should be "Model Ship - The Titanic"
    And a seller_order should exist
    And a line_item should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the line_item should be unconfirmed
    And the line_item should be amongst the seller_order's line_items
    And the line_item should be amongst the supplier's line_items
    And the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, FYI: a new line item for 1 x 12345790063 (Model Ship - The Titanic) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the seller should be that outgoing text message's payer
    And the most recent outgoing text message destined for mobile_number: "Dave's number" should be
    """
    Hi Dave, you have a new line item: #1, from Mara (+66354668789) for 1 x 12345790063 (Model Ship - The Titanic). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """
    And the seller should be that outgoing text message's payer

