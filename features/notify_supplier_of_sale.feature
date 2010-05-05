Feature: Notify the supplier by sms when an item is payed for on ebay
  In order to ship my product and get paid
  As a supplier
  I want to be informed when a customer buys my product

  Scenario: Receive notification
    Given a supplier exists
    And a product exists with supplier_id: that supplier, external_id: "12345"
    When a customer purchases a product on ebay with item id: "12345"
    Then an order should exist with product: that product, state: "new"
    And I should receive a text message which is a translation of "order received" in "en" (English)
