Feature: Update supplier payment from paypal ipn
  In order to receive notifications about payments made from me to my suppliers
  As a seller
  I want to link the paypal ipn to the payment

  Background:
    Given a seller exists with name: "Dave"
    And a verified mobile number: "Dave's number" exists with number: "66354668789", user: the seller
    And a supplier exists with name: "Fon", email: "fon@example.com"
    And a verified mobile number: "Fon's number" exists with number: "66123555331", user: the supplier
    And a partnership exists with seller: the seller, supplier: the supplier
    And a product exists with seller: the seller, partnership: the partnership
    And a line item exists for that product
    Then a supplier order should exist

    Given a payment agreement exists with seller: the seller, supplier: the supplier, fixed_amount: "500"
    And the line item was already confirmed
    Then a supplier payment should exist

    Given a supplier payment paypal ipn exists

  Scenario: The payment status is 'Completed'
    Given the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Completed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be the supplier payment paypal ipn's supplier_payment
    And the supplier payment should be completed

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Dave, a payment of 500.00 USD was received by Fon (+66123555331) for Order #1
    """
    And the seller should be that outgoing text message's payer

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should be
    """
    Fon, you have received a payment of 500.00 USD from Dave (+66354668789) for Order #1
    """
    And the seller should be that outgoing text message's payer

  Scenario: The payment status is 'Processed'
    Given the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Processed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should not be completed

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should not include "500.00 USD"

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should not include "500.00 USD"

  Scenario: The payment status is 'Unclaimed'
    Given the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Unclaimed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be unclaimed

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be a translation of "we paid your supplier but the payment was unclaimed" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "+66123555331", supplier_email: "fon@example.com", supplier_payment_amount: "500.00", supplier_payment_currency: "USD", seller_order_number: "1"
    And the seller should be that outgoing text message's payer

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should be a translation of "open a paypal account to claim your payment" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", seller_mobile_number: "+66354668789", seller_order_number: "1", supplier_payment_amount: "500.00", supplier_payment_currency: "USD"
    And the seller should be that outgoing text message's payer

  Scenario: 30 days have passed and the supplier still has not claimed their payment
    Given the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'txn_type' => 'masspay',
      'masspay_txn_id_1'=>'35D21472YD1820048',
      'status_1' => 'Unclaimed',
      'unique_id_1' => '1'
    }
    """
    And the supplier payment paypal ipn was already verified

    Then the supplier payment should be unclaimed

    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'payment_status' => 'Completed',
        'txn_type' => 'masspay',
        'masspay_txn_id_1'=>'35D21472YD1820048',
        'status_1' => 'Unclaimed',
        'unique_id_1' => '1'
      }
    }
    """
    Then the supplier payment paypal ipn should be verified
    And the supplier payment should be unclaimed

  Scenario: The supplier registers a paypal account and claims their payment
    Given the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'txn_type' => 'masspay',
      'masspay_txn_id_1'=>'35D21472YD1820048',
      'status_1' => 'Unclaimed',
      'unique_id_1' => '1'
    }
    """
    And the supplier payment paypal ipn was already verified

    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'payment_status' => 'Completed',
        'txn_type' => 'masspay',
        'masspay_txn_id_1'=>'35D21472YD1820048',
        'status_1' => 'Completed',
        'unique_id_1' => '1'
      }
    }
    """
    Then the supplier payment paypal ipn should not be verified

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be completed

