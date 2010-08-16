Feature: Notifications
  In order to communicate information effectively with myself and my suppliers
  As a seller
  I want to be able configure text message notifications for me and my suppliers for different events

  Scenario Outline: An order is accepted by a supplier
    Given a mobile_number: "seller's number" exists with number: "66354668789"
    And a seller exists with name: "Mara", mobile_number: mobile_number: "seller's number"
    And a mobile_number: "supplier's number" exists with number: "66256785325"
    And a supplier exists with name "Nok", mobile_number: mobile_number: "supplier's number"
    And a notification: "supplier's notification" exists with event: "supplier_order_accepted", seller: the seller, for: "supplier"
    And the notification: "supplier's notification" message includes all available attributes
    And a notification exists with event: "supplier_order_accepted", seller: the seller, for: "seller"
    And the notification: "seller's notification" message includes all available attributes
    And a product exists with verification_code: "hy456n", supplier_id: the supplier, seller: the seller
    And a seller_order exists with id: 154672, seller: the seller
    And a supplier_order exists with id: 154674, product_id: the product, quantity: 1

    When the supplier accepts the order

    Then a new outgoing text message should be created destined for mobile_number: "supplier's number"
    And the outgoing_text_message should be "154674 154672 Nok Mara +66256785325 +66354668789"
    And a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be ""

