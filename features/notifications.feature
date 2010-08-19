Feature: Notifications
  In order to communicate information effectively with myself and my suppliers
  As a seller
  I want to be able configure text message notifications for me and my suppliers for different events

  Scenario: A supplier order is accepted
    Given a mobile_number: "seller's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", email: "mara@example.com", mobile_number: mobile_number: "seller's number"
    And a mobile_number: "supplier's number" exists with number: "66256785325"
    And a supplier exists with name: "Nok", email: "nok@example.com", mobile_number: mobile_number: "supplier's number"
    And a paypal_ipn exists
    And the paypal_ipn has the following params: "{'receiver_email'=>'mara@example.com', 'address_name' => 'Johnny Knoxville', 'address_street' => '14 Mank St', 'address_city' => 'Mankville', 'address_state' => 'VIC', 'address_country' => 'Australia', 'address_zip' => '1234'}"
    And a product exists with verification_code: "hy456n", supplier: the supplier, seller: the seller
    And a seller_order exists with id: 154672, seller: the seller, order_notification: the paypal_ipn
    And a supplier_order exists with id: 154674, product_id: the product, quantity: 1, seller_order: the seller_order
    And a notification: "supplier's notification" exists with event: "supplier_order_accepted", seller: the seller, for: "supplier"
    And the notification: "supplier's notification" message includes all available attributes
    And a notification: "seller's notification" exists with event: "supplier_order_accepted", seller: the seller, for: "seller"
    And the notification: "seller's notification" message includes all available attributes

    When the supplier accepts the supplier_order

    Then a new outgoing text message should be created destined for mobile_number: "supplier's number"
    And the outgoing_text_message should be
    """
    154674 154672 Nok Mara +66256785325 +66354668789 nok@example.com mara@example.com Johnny Knoxville,
    14 Mank St,
    Mankville,
    VIC,
    Australia,
    1234 Johnny Knoxville 14 Mank St Mankville VIC Australia 1234
    """
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing text message should be
    """
    154674 154672 Nok Mara +66256785325 +66354668789 nok@example.com mara@example.com Johnny Knoxville,
    14 Mank St,
    Mankville,
    VIC,
    Australia,
    1234 Johnny Knoxville 14 Mank St Mankville VIC Australia 1234
    """

