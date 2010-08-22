Feature: Notifications
  In order to communicate information effectively with myself and my suppliers
  As a seller
  I want to be able configure text message notifications for me and my suppliers for different events

  Background:
    Given a mobile_number: "seller's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", email: "mara@example.com", mobile_number: mobile_number: "seller's number"
    And a mobile_number: "supplier's number" exists with number: "66256785325"
    And a supplier exists with name: "Nok", email: "nok@example.com", mobile_number: mobile_number: "supplier's number"
    And no notifications exist with seller_id: the seller
    And a paypal_ipn exists with seller: the seller
    And the paypal_ipn has the following params: "{'address_name' => 'Johnny Knoxville', 'address_street' => '14 Mank St', 'address_city' => 'Mankville', 'address_state' => 'VIC', 'address_country' => 'Australia', 'address_zip' => '1234'}"
    And a product exists with number: "19023445673", name: "Oriental Fishing Rod", verification_code: "hy456n", supplier: the supplier, seller: the seller
    And a seller_order exists with id: 154672, seller: the seller, order_notification: the paypal_ipn

  Scenario Outline: A supplier order (product order)
    Given a notification exists with event: "<event>", seller: the seller, for: "supplier", purpose: "product order notification"
    And a notification: "special notification for this supplier" exists with event: "<event>", seller: the seller, for: "supplier", purpose: "product order notification", supplier: the supplier
    And the notification: "special notification for this supplier" message includes all available attributes
    And a notification exists with event: "<event>", seller: the seller, for: "seller", product: the product, purpose: "product order notification", message: "special notification for this product: <product_number>, <product_name>"
    And a notification exists with event: "<event>", seller: the seller, for: "seller", purpose: "product order notification", supplier: the supplier
    And a notification exists with event: "<event>", seller: the seller, for: "seller", purpose: "product order notification"
    And a supplier_order exists with id: 154674, product_id: the product, quantity: 1, seller_order: the seller_order

    When the supplier <transitions> the supplier_order

    Then 2 notifications should exist with event: "<event>", for: "supplier", seller_id: the seller, purpose: "product order notification"
    And 3 notifications should exist with event: "<event>", for: "seller", seller_id: the seller, purpose: "product order notification"
    But 1 outgoing_text_messages should exist with mobile_number_id: mobile_number: "supplier's number"
    And 1 outgoing_text_messages should exist with mobile_number_id: mobile_number: "seller's number"
    And a new outgoing text message should be created destined for mobile_number: "supplier's number"
    And the outgoing_text_message should be
    """
    154674 154672 Nok Mara +66256785325 +66354668789 nok@example.com mara@example.com 1 19023445673 Oriental Fishing Rod hy456n Johnny Knoxville,
    14 Mank St,
    Mankville,
    VIC,
    Australia,
    1234 Johnny Knoxville 14 Mank St Mankville VIC Australia 1234
    """
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing text message should be "special notification for this product: 19023445673, Oriental Fishing Rod"

    Examples:
      | event                   | transitions  |
      | product_order_created   | dreams_about |
      | product_order_accepted  | accepts      |
      | product_order_rejected  | rejects      |
      | product_order_completed | completes    |

