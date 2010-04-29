Feature: Notify the seller by sms when an item is payed for
  In order to ship my product and get paid
  As a supplier
  I want to be informed when a customer buys my product

  Scenario: Receive notification
  Given a supplier exists
  And a product exists belonging to the supplier with external_product_id: "12345"
  When a customer purchases a product on ebay with item_id: "12345"
  Then I should receive a text message which is a translation of "order received" in "en" (English)
