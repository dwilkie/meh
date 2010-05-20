Feature: Notify the supplier by text message when a supplier order is created
  In order to precure an item before shipping
  As a supplier
  I want to be notified when an order is created with my product

  Background:
    Given a supplier exists with name: "Bob"
    And a mobile_number: "supplier's number" exists with phoneable: the supplier
 
  Scenario: I am not the seller of this item
    Given a seller exists with name: "John"
    And a mobile_number: "seller's number" exists with phoneable: the seller, number: "66123456789"
    And a product exists with supplier: the supplier, seller: the seller, external_id: "12345"

    When a supplier_order is created with id: 567843, supplier_id: the supplier, product_id: the product, quantity: 1

    Then a new outgoing text message should be created destined for mobile_number: "supplier's number"
    And the outgoing_text_message should be a translation of "supplier order notification" in "en" (English) where seller: "John", seller_contact_details: "+66123456789", supplier: "Bob", product_code: "12345", quantity: "1", order_number: "567843"

  Scenario: I am also the seller of this item
    Given the supplier is also a seller
    And a product exists with supplier: the supplier, seller: the supplier, external_id: "12345"

    When a supplier_order is created with id: 567843, supplier_id: the supplier, product_id: the product, quantity: 1

    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "supplier order notification" in "en" (English) where supplier: "Bob", product_code: "12345", quantity: "1", order_number: "567843"
