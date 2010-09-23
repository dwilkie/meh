Feature: Supplier Payment Paypal IPN
  In order to receive notifications about payments made from me to my suppliers
  As a seller
  I want to keep a record of all paypal ipns relating to my supplier payments

  Scenario Outline: A paypal ipn is received for a supplier payment
    Given a supplier payment exists with id: 125632

    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'txn_type' => 'masspay',
        'payment_gross_1' => '',
        'payment_date' => '23:50:44 Sep 19, 2010 PDT',
        'last_name' => 'Cash',
        'mc_fee_1' => "1.25",
        'masspay_txn_id_1' => '88F92775HW360771N',
        'receiver_email_1' => 'dave@example.com',
        'residence_country' => 'AU',
        'verify_sign' => 'Aqp6zSq-O1GQ.vVMXvyw-sPcSzacA7IFmr7hpaa6HFEpfPn5wUtvqlWY',
        'payer_status' => 'verified',
        'test_ipn' => '1',
        'payer_email' => 'mara@example.com',
        'first_name' => 'Johnnie',
        'payment_fee_1' => '',
        'payer_id' => '6TFGKMB94YKU2',
        'payer_business_name' => "Johnnie Cash's Test Store",
        'payment_status' => '<payment_status>',
        'status_1' => 'Completed',
        'mc_gross_1' => '100.00',
        'charset' => 'windows-1252',
        'notify_version' => '3.0',
        'mc_currency_1' => 'AUD',
        'unique_id_1' => '125632'
      }
    }
    """

    Then a paypal ipn should exist with transaction_id: "88F92775HW360771N"
    And the paypal ipn's payment_status should <be_or_not_be> "Completed"
    And the most recent job in the queue should be to verify the paypal ipn
    And the paypal ipn should have the following params:
    """
    {
      'txn_type' => 'masspay',
      'payment_gross_1' => '',
      'payment_date' => '23:50:44 Sep 19, 2010 PDT',
      'last_name' => 'Cash',
      'mc_fee_1' => "1.25",
      'masspay_txn_id_1' => '88F92775HW360771N',
      'receiver_email_1' => 'dave@example.com',
      'residence_country' => 'AU',
      'verify_sign' => 'Aqp6zSq-O1GQ.vVMXvyw-sPcSzacA7IFmr7hpaa6HFEpfPn5wUtvqlWY',
      'payer_status' => 'verified',
      'test_ipn' => '1',
      'payer_email' => 'mara@example.com',
      'first_name' => 'Johnnie',
      'payment_fee_1' => '',
      'payer_id' => '6TFGKMB94YKU2',
      'payer_business_name' => "Johnnie Cash's Test Store",
      'payment_status' => '<payment_status>',
      'status_1' => 'Completed',
      'mc_gross_1' => '100.00',
      'charset' => 'windows-1252',
      'notify_version' => '3.0',
      'mc_currency_1' => 'AUD',
      'unique_id_1' => '125632'
    }
    """

    Examples:
      | payment_status | be_or_not_be |
      | Completed      | be           |
      | Processed      | not be       |

  Scenario Outline: A paypal ipn is received for a duplicate transaction id
    Given a supplier payment paypal ipn exists with transaction_id: "45D21472YD1820048"
    And the supplier payment paypal ipn has the following params:
    """
    {
      'txn_type' => 'masspay',
      'masspay_txn_id_1'=>'45D21472YD1820048',
      'payment_status' => '<original_payment_status>'
    }
    """
    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'txn_type' => 'masspay',
        'masspay_txn_id_1'=>'45D21472YD1820048',
        'payment_status' => '<new_payment_status>',
        'unique_id_1' => '1'
      }
    }
    """

    Then the supplier payment paypal ipn's payment_status should be "Completed"
    And the most recent job in the queue should be to verify the paypal ipn

    Examples:
      | original_payment_status | new_payment_status |
      | Processed               | Completed          |
      | Completed               | Processed          |

  Scenario Outline: A paypal ipn is received
    When a supplier payment paypal ipn is created
    Then the most recent job in the queue should be to verify the paypal ipn

    Given paypal <sent_or_did_not_send> the IPN

    When the worker works off the job

    Then the supplier payment paypal ipn should <be_or_not_be_verified>
    And the supplier payment paypal ipn should <be_or_not_be_fraudulent>
    And the last request should contain the supplier payment paypal ipn params

    Examples:
      | sent_or_did_not_send | be_or_not_be_verified | be_or_not_be_fraudulent |
      | sent | be verified | not be fraudulent |
      | did not send | not be verified | be fraudulent |

