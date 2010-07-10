Feature: Paypal IPN
  In order to avoid unregistered and duplicate Paypal IPNs from having an adverse affect on the system
  I want to ignore Paypal IPNs where the recipient is not a registered seller and where the Paypal IPN is a duplicate and I want to verify all other Paypal IPNs

  Scenario: A paypal IPN is received for a registered seller
    Given a seller exists with email: "some_seller@example.com"

    When a paypal ipn is received with: "{'paypal_ipn'=>{'mc_gross'=>'54.00', 'protection_eligibility'=>'Eligible', 'for_auction'=>'true', 'address_status'=>'confirmed', 'item_number1'=>'12345790063', 'payer_id'=>'T23XXY2DVKA6J', 'tax'=>'0.00', 'address_street'=>'address', 'payment_date'=>'08:30:40 May 06, 2010 PDT', 'payment_status'=>'Completed', 'charset'=>'windows-1252', 'auction_closing_date'=>'08:27:08 Jun 05, 2010 PDT', 'address_zip'=>'98102', 'first_name'=>'Test', 'auction_buyer_id'=>'testuser_mehbuyer', 'mc_fee'=>'2.41', 'address_country_code'=>'US', 'address_name'=>'Test User', 'notify_version'=>'2.9', 'custom'=>'', 'payer_status'=>'verified', 'business'=>'some_seller@example.com', 'num_cart_items'=>'1', 'address_country'=>'United States', 'address_city'=>'city', 'quantity'=>'1', 'verify_sign'=>'Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C', 'payer_email'=>'mehbuy_1272942317_per@gmail.com', 'txn_id'=>'45D21472YD1820048', 'payment_type'=>'instant', 'last_name'=>'User', 'item_name1'=>'Yet another piece of mank', 'address_state'=>'WA', 'receiver_email'=>'some_seller@example.com', 'payment_fee'=>'2.41', 'quantity1'=>'1', 'insurance_amount'=>'0.00', 'receiver_id'=>'8AYM8ZN48AARJ', 'txn_type'=>'web_accept', 'item_name'=>'Yet another piece of mank', 'mc_currency'=>'USD', 'item_number'=>'12345790063', 'residence_country'=>'AU', 'test_ipn'=>'1', 'transaction_subject'=>'Yet another piece of mank', 'payment_gross'=>'54.00', 'shipping'=>'20.00'}}"

    Then a paypal_ipn should exist with transaction_id: "45D21472YD1820048"

  Scenario: A Paypal IPN is received for an unregistered seller
    When a paypal ipn is received with: "{'paypal_ipn'=>{'mc_gross'=>'54.00', 'protection_eligibility'=>'Eligible', 'for_auction'=>'true', 'address_status'=>'confirmed', 'item_number1'=>'12345790063', 'payer_id'=>'T23XXY2DVKA6J', 'tax'=>'0.00', 'address_street'=>'address', 'payment_date'=>'08:30:40 May 06, 2010 PDT', 'payment_status'=>'Completed', 'charset'=>'windows-1252', 'auction_closing_date'=>'08:27:08 Jun 05, 2010 PDT', 'address_zip'=>'98102', 'first_name'=>'Test', 'auction_buyer_id'=>'testuser_mehbuyer', 'mc_fee'=>'2.41', 'address_country_code'=>'US', 'address_name'=>'Test User', 'notify_version'=>'2.9', 'custom'=>'', 'payer_status'=>'verified', 'business'=>'some_seller@example.com', 'num_cart_items'=>'1', 'address_country'=>'United States', 'address_city'=>'city', 'quantity'=>'1', 'verify_sign'=>'Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C', 'payer_email'=>'mehbuy_1272942317_per@gmail.com', 'txn_id'=>'45D21472YD1820048', 'payment_type'=>'instant', 'last_name'=>'User', 'item_name1'=>'Yet another piece of mank', 'address_state'=>'WA', 'receiver_email'=>'some_seller@example.com', 'payment_fee'=>'2.41', 'quantity1'=>'1', 'insurance_amount'=>'0.00', 'receiver_id'=>'8AYM8ZN48AARJ', 'txn_type'=>'web_accept', 'item_name'=>'Yet another piece of mank', 'mc_currency'=>'USD', 'item_number'=>'12345790063', 'residence_country'=>'AU', 'test_ipn'=>'1', 'transaction_subject'=>'Yet another piece of mank', 'payment_gross'=>'54.00', 'shipping'=>'20.00'}}"

  Then a paypal_ipn should not exist

  Scenario: A Paypal IPN is received for a duplicate transaction id
    Given a seller exists with email: "some_seller@example.com"
    And a paypal_ipn exists with seller: the seller, transaction_id: "45D21472YD1820048"

    When a paypal ipn is received with: "{'paypal_ipn'=>{'mc_gross'=>'54.00', 'protection_eligibility'=>'Eligible', 'for_auction'=>'true', 'address_status'=>'confirmed', 'item_number1'=>'12345790063', 'payer_id'=>'T23XXY2DVKA6J', 'tax'=>'0.00', 'address_street'=>'address', 'payment_date'=>'08:30:40 May 06, 2010 PDT', 'payment_status'=>'Completed', 'charset'=>'windows-1252', 'auction_closing_date'=>'08:27:08 Jun 05, 2010 PDT', 'address_zip'=>'98102', 'first_name'=>'Test', 'auction_buyer_id'=>'testuser_mehbuyer', 'mc_fee'=>'2.41', 'address_country_code'=>'US', 'address_name'=>'Test User', 'notify_version'=>'2.9', 'custom'=>'', 'payer_status'=>'verified', 'business'=>'some_seller@example.com', 'num_cart_items'=>'1', 'address_country'=>'United States', 'address_city'=>'city', 'quantity'=>'1', 'verify_sign'=>'Aa4P7UnWW85EE9W0YVKVAc7z1v8OAkejFXqE2AlDChXtbvZRHTHaiH4C', 'payer_email'=>'mehbuy_1272942317_per@gmail.com', 'txn_id'=>'45D21472YD1820048', 'payment_type'=>'instant', 'last_name'=>'User', 'item_name1'=>'Yet another piece of mank', 'address_state'=>'WA', 'receiver_email'=>'some_seller@example.com', 'payment_fee'=>'2.41', 'quantity1'=>'1', 'insurance_amount'=>'0.00', 'receiver_id'=>'8AYM8ZN48AARJ', 'txn_type'=>'web_accept', 'item_name'=>'Yet another piece of mank', 'mc_currency'=>'USD', 'item_number'=>'12345790063', 'residence_country'=>'AU', 'test_ipn'=>'1', 'transaction_subject'=>'Yet another piece of mank', 'payment_gross'=>'54.00', 'shipping'=>'20.00'}}"

    Then 1 paypal_ipns should exist

