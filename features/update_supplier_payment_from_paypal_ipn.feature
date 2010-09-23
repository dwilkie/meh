Feature: Update supplier payment from paypal ipn
  In order to receive notifications about payments made from me to my suppliers
  As a seller
  I want to link the paypal ipn to the payment

  Background:
    Given a seller exists with name: "Dave"
    And a mobile number: "Dave's number" exists with number: "66354668789", user: the seller
    And a supplier exists with name: "Fon"
    And a mobile number: "Fon's number" exists with number: "66123555331", user: the supplier
    And a product: "Rubber Dingy" exists with seller: the seller, supplier: the supplier, number: "12345790063", name: "Model Ship - A Rubber Dingy"
    And a supplier order exists for the product
    And a supplier payment exists with supplier_order: the supplier order, supplier: the supplier, seller: the seller, cents: "50000", currency: "THB"

  Scenario Outline: The payment status is 'Completed'
    Given the mobile number: "Dave's number" <seller_number_verified> verified
    And the mobile number: "Fon's number" <supplier_number_verified> verified
    And a supplier payment paypal ipn exists
    And the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Completed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be the supplier payment paypal ipn's supplier_payment

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <send_seller_message>
    """
    Hi Dave, a payment of 500.00 THB was made to Fon (<supplier_number>) for 1 x 12345790063 (Model Ship - A Rubber Dingy) which belongs to your customer order: #1
    """

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should <send_supplier_message>
    """
    Hi Fon, you have received a payment of 500.00 THB from Dave (<seller_number>) for your product order: #1
    """
    Examples:
     | seller_number_verified | seller_number | supplier_number_verified |supplier_number | send_seller_message | send_supplier_message |
     | was already | +66354668789 | was already | +66123555331 | be | be |
#     | was already | +66354668789 | is not yet  | No verified number! | be | not be |
#     | is not yet  | No verified number! | was already | +66123555331 | not be | be |
#     | is not yet  | No verified number! | is not yet  | No verified number! | not be | not be |

  Scenario: The payment status is 'Processed'
    Given the mobile number: "Dave's number" is verified
    And the mobile number: "Fon's number" is verified

    And a supplier payment paypal ipn exists
    And the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Processed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be the supplier payment paypal ipn's supplier_payment

    But the most recent outgoing text message destined for the mobile number: "Dave's number" should not be
    """
    Hi Dave, a payment of 500.00 THB was made to Fon (+66123555331) for 1 x 12345790063 (Model Ship - A Rubber Dingy) which belongs to your customer order: #1
    """

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should not be
    """
    Hi Fon, you have received a payment of 500.00 THB from Dave (+66354668789) for your product order: #1
    """

  Scenario: The payment status is 'Unclaimed'
    Given the mobile number: "Dave's number" is verified
    And the mobile number: "Fon's number" is verified

    And a supplier payment paypal ipn exists
    And the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Unclaimed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be the supplier payment paypal ipn's supplier_payment

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, a payment of 500.00 THB to Fon (+66123555331) for 1 x 12345790063 (Model Ship - A Rubber Dingy) was unclaimed because Fon does not have a paypal account with the email: fon@example.com
    """

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should be
    """
    Hi Fon, you have received a payment of 500.00 THB from Dave (+66354668789) for your product order: #1. To claim the payment go to paypal.com
    """

  Scenario: 30 days has passed and still the supplier has not claimed their payment
    Given the mobile number: "Dave's number" is verified
    And the mobile number: "Fon's number" is verified
    And a supplier payment paypal ipn: "Processed IPN" exists with supplier_payment: the supplier payment
    And the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Processed',
      'status_1' => 'Unclaimed',
      'unique_id_1' => '1'
    }
    """

    And a supplier payment paypal ipn: "Completed IPN" exists
    And the supplier payment paypal ipn has the following params:
    """
    {
      'payment_status' => 'Completed',
      'status_1' => 'Unclaimed',
      'unique_id_1' => '1'
    }
    """

    When the supplier payment paypal ipn is verified

    Then the supplier payment should be the supplier payment paypal ipn's supplier_payment

    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, a payment of 500.00 THB to Fon (+66123555331) for 1 x 12345790063 (Model Ship - A Rubber Dingy) was unclaimed because Fon does not have a paypal account with the email: fon@example.com
    """

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should be
    """
    Hi Fon, you have received a payment of 500.00 THB from Dave (+66354668789) for your product order: #1. To claim the payment go to paypal.com
    """

