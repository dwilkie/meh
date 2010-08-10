Feature: Create supplier orders when a paypal ipn is verified
  In order to keep track of my orders
  As a supplier
  I want a new supplier order to be created when a paypal ipn containing a product that I am supplying is verified and the payment status is 'Completed'

  Background:
    Given a mobile_number: "seller's number" exists with number: "66354668789"
    And a seller exists with email: "some_seller@example.com", mobile_number: the mobile_number, name: "Dave"
    And a supplier exists
    And a product exists with seller: the seller, supplier: the supplier, external_id: "12345790063"

  Scenario: The payment status is 'Completed'
    Given a paypal_ipn exists with payment_status: "Completed"
    And the paypal_ipn has the following params: "{'item_number1'=>'12345790063', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}"

    When the paypal_ipn is verified

    Then a seller_order should exist
    And a supplier_order should exist with supplier_id: the supplier
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the supplier's supplier_orders

  Scenario: The payment status is not 'Completed'
    Given a paypal_ipn exists
    And the paypal_ipn has the following params: "{'item_number1'=>'12345790063', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}"

    When the paypal_ipn is verified

    Then a supplier_order should not exist

  Scenario: The seller has not registered this product
    Given a paypal_ipn exists with payment_status: "Completed"
    And the paypal_ipn has the following params: "{'item_number1'=>'12345790062', 'receiver_email'=>'some_seller@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}"

    When the paypal_ipn is verified

    Then a supplier_order should not exist
    But a seller_order should exist
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be a translation of "product not found" in "en" (English) where seller: "Dave", external_id: "12345790062"

