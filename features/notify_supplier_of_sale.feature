Feature: Notify the supplier by text message when an item is payed for via paypal
  In order to ship my product and get paid from my seller
  As a supplier
  I want to be informed when a buyer has paid for a product that I should deliver

  Scenario: Buyer purchases a single item
    Given a seller exists with email: "seller@gmail.com"
    And a supplier exists with seller: the seller
    And a product exists with seller: the seller, supplier: the supplier, external_id: "12345"
    When a buyer successfully purchases the product through paypal with external_id: "12345"
    Then a paypal_ipn should exist with payment_status: "Completed"
    And an order should exists with product: the product
    And I should receive a text message which is a translation of "order received" in "en" (English)
