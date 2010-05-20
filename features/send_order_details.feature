Feature: Notify the supplier of the order details when an order is accepted
  In order to ship my item, confirm a booking etc
  As a supplier
  I want to be notified with order details when I accept an order
  
  Scenario: Send order details
    Given a supplier exists with name: "Phil"
    And a mobile_number exists with number: "66745345423", phoneable: the supplier
    And a product exists with supplier: the supplier, external_id: "346754"
    And a supplier_order exists with id: 34325, supplier: the supplier, details: "Order details", product: the product
    When I accept the supplier_order
    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "order details" in "en" (English) where details: "Order details", supplier: "Phil", order_number: "34325", product_code: "346754"
