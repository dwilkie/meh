Feature: Allow the supplier to respond by text message to an order notification
  In order to confirm or reject an order without using the Internet
  As a supplier
  I want to be able to confirm or reject an order by sending a text message
  
  Scenario: Confirm an order correctly
   Given a supplier exists
   And a mobile_number exists with number: "66354668789", phoneable: the supplier
   And a product exists with external_id: "12345"
   And an order exists with supplier_id: the supplier, product_id: the product, quantity: 1, id: 3456787
   
   When text "acceptorder 3456878 1 12345 9" from "66354668789"
   
   Then an incoming_text_message should exist with smsable_id: the mobile_number, originator: "66354668789"
   And the incoming_text_message should be amongst the mobile_number's incoming_text_messages
   And an acceptorder_conversation should exist with with: the supplier, topic: "acceptorder"
   And the acceptorder_conversation should not be finished
   
   And the order should be confirmed

