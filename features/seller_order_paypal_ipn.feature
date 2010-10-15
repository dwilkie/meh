Feature: Seller Order Paypal IPN
  In order to receive notifications about payments made to me from my customers
  As a seller
  I want to keep a record of all paypal ipns where I am the receiver

  Scenario Outline: A paypal ipn is received for a registered seller
    Given a seller exists with email: "mara@example.com"

    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'mc_gross'=>'54.00',
        'protection_eligibility'=>'Eligible',
        'for_auction'=>'true',
        'address_status'=>'confirmed',
        'item_number1'=>'12345790063',
        'payer_id'=>'T23XXY2DVKA6J',
        'tax'=>'0.00',
        'address_street'=>'address',
        'payment_date'=>'08:30:40 May 06, 2010 PDT',
        'payment_status'=>'<payment_status>',
        'charset'=>'windows-1252',
        'auction_closing_date'=>'08:27:08 Jun 05, 2010 PDT',
        'address_zip'=>'98102',
        'first_name'=>'Test',
        'auction_buyer_id'=>'testuser_mehbuyer',
        'mc_fee'=>'2.41',
        'address_country_code'=>'US',
        'address_name'=>'Test User',
        'notify_version'=>'2.9',
        'custom'=>'',
        'payer_status'=>'verified',
        'business'=>'mara@example.com',
        'num_cart_items'=>'1',
        'address_country'=>'United States',
        'address_city'=>'city',
        'quantity'=>'1',
        'verify_sign'=>'Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C',
        'payer_email'=>'mehbuy_1272942317_per@gmail.com',
        'txn_id'=>'35D21472YD1820048',
        'payment_type'=>'instant',
        'last_name'=>'User',
        'item_name1'=>'Yet another piece of mank',
        'address_state'=>'WA',
        'receiver_email'=>'mara@example.com',
        'payment_fee'=>'2.41',
        'quantity1'=>'1',
        'insurance_amount'=>'0.00',
        'receiver_id'=>'8AYM8ZN48AARJ',
        'txn_type'=>'web_accept',
        'item_name'=>'Yet another piece of mank',
        'mc_currency'=>'USD',
        'item_number'=>'12345790063',
        'residence_country'=>'AU',
        'test_ipn'=>'1',
        'transaction_subject'=>'Yet another piece of mank',
        'payment_gross'=>'54.00',
        'shipping'=>'20.00'
      }
    }
    """

    Then a paypal ipn should exist with transaction_id: "35D21472YD1820048"
    And the paypal ipn's payment_status should <be_or_not_be> "Completed"
    And the most recent job in the queue should be to verify the paypal ipn
    And the paypal ipn should have the following params:
    """
    {
      'mc_gross'=>'54.00',
      'protection_eligibility'=>'Eligible',
      'for_auction'=>'true',
      'address_status'=>'confirmed',
      'item_number1'=>'12345790063',
      'payer_id'=>'T23XXY2DVKA6J',
      'tax'=>'0.00',
      'address_street'=>'address',
      'payment_date'=>'08:30:40 May 06, 2010 PDT',
      'payment_status'=>'<payment_status>',
      'charset'=>'windows-1252',
      'auction_closing_date'=>'08:27:08 Jun 05, 2010 PDT',
      'address_zip'=>'98102',
      'first_name'=>'Test',
      'auction_buyer_id'=>'testuser_mehbuyer',
      'mc_fee'=>'2.41',
      'address_country_code'=>'US',
      'address_name'=>'Test User',
      'notify_version'=>'2.9',
      'custom'=>'',
      'payer_status'=>'verified',
      'business'=>'mara@example.com',
      'num_cart_items'=>'1',
      'address_country'=>'United States',
      'address_city'=>'city',
      'quantity'=>'1',
      'verify_sign'=>'Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C',
      'payer_email'=>'mehbuy_1272942317_per@gmail.com',
      'txn_id'=>'35D21472YD1820048',
      'payment_type'=>'instant',
      'last_name'=>'User',
      'item_name1'=>'Yet another piece of mank',
      'address_state'=>'WA',
      'receiver_email'=>'mara@example.com',
      'payment_fee'=>'2.41',
      'quantity1'=>'1',
      'insurance_amount'=>'0.00',
      'receiver_id'=>'8AYM8ZN48AARJ',
      'txn_type'=>'web_accept',
      'item_name'=>'Yet another piece of mank',
      'mc_currency'=>'USD',
      'item_number'=>'12345790063',
      'residence_country'=>'AU',
      'test_ipn'=>'1',
      'transaction_subject'=>'Yet another piece of mank',
      'payment_gross'=>'54.00',
      'shipping'=>'20.00'
    }
    """

    Examples:
     | payment_status | be_or_not_be |
     | Completed      | be           |
     | Pending        | not be       |

  Scenario: A paypal ipn is received for an unregistered seller
    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'receiver_email'=>'mara@example.com',
        'txn_id'=>'35D21472YD1820048',
        'item_number1'=>'12345790063',
        'quantity1'=>'1',
        'num_cart_items'=>'1',
        'item_name1'=>'Yet another piece of mank'
      }
    }
    """
    Then a paypal ipn should not exist

  Scenario Outline: A paypal ipn is received with an existing transaction id belonging to a verified paypal ipn with a 'Completed' payment status
    Given a seller exists with email: "mara@example.com"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'receiver_email'=>'mara@example.com',
      'txn_id'=>'35D21472YD1820048',
      'payment_status' => 'Completed',
      'item_number'=>'12345790063',
      'quantity'=>'1',
      'item_name'=>'Yet another piece of mank'
    }
    """
    And the seller order paypal ipn was already verified

    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'payment_status' => '<payment_status>',
        'receiver_email'=>'mara@example.com',
        'txn_id'=>'35D21472YD1820048',
        'item_number'=>'435665322343',
        'quantity'=>'5',
        'item_name'=>'Some other item name'
      }
    }
    """
    Then 1 paypal ipns should exist with transaction_id: "35D21472YD1820048"
    And the seller order paypal ipn should have the following params:
    """
    {
      'receiver_email'=>'mara@example.com',
      'txn_id'=>'35D21472YD1820048',
      'payment_status' => 'Completed',
      'item_number'=>'12345790063',
      'quantity'=>'1',
      'item_name'=>'Yet another piece of mank'
    }
    """
    And the seller order paypal ipn should be verified

    Examples:
      | payment_status |
      | Processed      |
      | Unclaimed      |

  Scenario Outline: A paypal ipn is received with an existing transaction id belonging to a paypal ipn that is fraudulent or has an uncompleted payment status
    Given a seller exists with email: "mara@example.com"
    And a seller order paypal ipn exists
    And the seller order paypal ipn has the following params:
    """
    {
      'receiver_email'=>'mara@example.com',
      'txn_id'=>'35D21472YD1820048',
      'payment_status' => '<original_payment_status>',
      'item_number'=>'12345790063',
      'quantity'=>'1',
      'item_name'=>'Yet another piece of mank'
    }
    """
    And the seller order paypal ipn <is_not_yet_or_was_already> fraudulent

    When a paypal ipn is received with:
    """
    {
      'paypal_ipn' => {
        'payment_status' => '<updated_payment_status>',
        'receiver_email'=>'mara@example.com',
        'txn_id'=>'35D21472YD1820048',
        'item_number'=>'435665322343',
        'quantity'=>'5',
        'item_name'=>'Some other item name'
      }
    }
    """
    Then 1 paypal ipns should exist with transaction_id: "35D21472YD1820048"
    And the seller order paypal ipn should have the following params:
    """
    {
      'payment_status' => '<updated_payment_status>',
      'receiver_email'=>'mara@example.com',
      'txn_id'=>'35D21472YD1820048',
      'item_number'=>'435665322343',
      'quantity'=>'5',
      'item_name'=>'Some other item name'
    }
    """
    And the seller order paypal ipn should not be verified
    And the seller order paypal ipn should not be fraudulent
    And the most recent job in the queue should be to verify the paypal ipn
    And the 2nd most recent job in the queue should be to verify the paypal ipn

    Examples:
      | is_not_yet_or_was_already | original_payment_status | updated_payment_status |
      | was already | Completed | Unclaimed  |
      | is not yet  | Unclaimed | Completed  |
      | is not yet  | Processed | Unclaimed  |
      | is not yet  | Unclaimed | Completed  |

  @current
  Scenario Outline: A paypal ipn is created
    When a seller order paypal ipn is created
    Then the most recent job in the queue should be to verify the paypal ipn

    Given paypal <sent_or_did_not_send> the IPN

    When the worker works off the job

    Then the seller order paypal ipn should <be_or_not_be_verified>
    And the seller order paypal ipn should <be_or_not_be_fraudulent>
    And the last request should contain the seller order paypal ipn params

    Examples:
      | sent_or_did_not_send | be_or_not_be_verified | be_or_not_be_fraudulent |
      | sent | be verified | not be fraudulent |
#      | did not send | not be verified | be fraudulent |

