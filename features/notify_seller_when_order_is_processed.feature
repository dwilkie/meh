Feature: Notify seller when an order for a product they are selling is processed
  In order for me to take appropriate action when a supplier processes
           an order for a product I am selling
  As a seller
  I want to be informed
  
  Background:
    Given a supplier exists with name: "Bruno"
    And a mobile_number exists with number: "66354668789", password: "1234", phoneable: the supplier
  
  Scenario Outline: Notify seller when an order is processed by a supplier
    Given a seller exists with name: "Dave"
    And a mobile_number: "seller's number" exists with phoneable: the seller
    And a product exists with seller: the seller, supplier: the supplier, external_id: "567864ab"
    And a seller_order exists with id: 154670, seller: the seller
    And a supplier_order exists with id: 154671, supplier: the supplier, product: the product, status: "<status>", seller_order: the seller order
    
    When the supplier <processes> the supplier_order
    Then a new outgoing text message should be created destined for mobile_number: "seller's number"
    And the outgoing_text_message should be a translation of "supplier processed seller's order" in "en" (English) where seller: "Dave", supplier: "Bruno", supplier_contact_details: "+66354668789", processed: "<processed>", seller_order_number: "154670", supplier_order_number: "154671", product_code: "567864ab"

    Examples:
      | status       | processes | processed |
      | unconfirmed  | accept    | accepted  |
      | unconfirmed  | reject    | rejected  |
      | accepted     | complete  | completed |
    
  Scenario: Don't notify the seller if they are also the supplier of the product
    Given the supplier is also a seller
    And a product exists with seller: the supplier, supplier: the supplier, external_id: "567864ab"
    And a supplier_order exists with id: 154671, supplier: the supplier, product: the product
