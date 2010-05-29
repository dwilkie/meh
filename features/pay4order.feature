Feature: Pay4order
  In order to pay a supplier for an order they supplied
  As a supplier
  I want to be able to pay by sending in a text message pay4order
  
  Background:
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Kikie"
    And a mobile_number: "Dave's number" exists with phoneable: the seller, number: "66542345789", password: "1234"
    And a mobile_number: "Kikie's number" exists with phoneable: the supplier, number: "66743578456"
    And a product exists with supplier: the supplier, seller: the seller, cents: 50000, currency: "THB", external_id: "thaibudda34"
    And a seller_order exists with id: 65433, seller: the seller
    And a supplier_order exists with id: 65434, seller_order: the seller_order, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product
  
  Scenario: pay4order
    When I text "1234 pay4order 65433 65434" from "66542345789"
    
    Then a payment should not exist
    But a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should be a translation of "confirm payment" in "en" (English) where seller: "Dave", supplier_order_number: "65434", processed: "unconfirmed", supplier_contact_details: "+66743578456", amount: "2,000.00 THB", quantity: "4", product_code: "thaibudda34", customer_order_number: "65433", supplier: "Kikie"
    
  Scenario: Confirm pay4order
    When I text "1234 pay4order 65433 65434 CONFIRM!" from "66542345789"
    
    Then a payment should exist
