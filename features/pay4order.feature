Feature: Pay4order
  In order to pay a supplier for an order they supplied
  As a supplier
  I want to be able to pay by sending in a text message pay4order
  
  Background:
    Given a seller exists with name: "Dave"
    And a supplier exists with name: "Kikie"
    And a mobile_number: "Dave's number" exists with phoneable: the seller, number: "66542345789", password: "1234"
    And a mobile_number: "Kikie's number" exists with phoneable: the supplier, number: "66743578456"
    And a seller_order exists with id: 65433, seller: the seller
    And a product exists with supplier: the supplier, seller: the seller, cents: 50000, currency: "THB", external_id: "thaibudda34"
    And a supplier_order exists with id: 65434, seller_order: the seller_order, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product
  
  Scenario: pay4order
    When I text "1234 pay4order 65433 65434" from "66542345789"
    
    Then a payment should not exist
    But a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should be a translation of "confirm payment" in "en" (English) where seller: "Dave", supplier_order_number: "65434", processed: "unconfirmed", supplier_contact_details: "+66743578456", amount: "2,000.00 THB", quantity: "4", product_code: "thaibudda34", customer_order_number: "65433", supplier: "Kikie"
    
  Scenario: Confirm payment
    When I text "1234 pay4order 65433 65434 CONFIRM!" from "66542345789"
    
    Then a payment should exist

  Scenario Outline: Try to pay for an order with incorrect order numbers
    When I text <text_message> from "66542345789"

    Then a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "order not found when pay4order" in "en" (English)
    
    Examples:
      | text_message                 |
      | "1234 pay4order"             |
      | "1234 pay4order 65433"       |
      | "1234 pay4order 65433 65433" |
      | "1234 pay4order 65432 65434" |
      | "1234 pay4order 65434 65433" |
      
  Scenario: Try to pay for an order as a supplier
    When I text "1234 pay4order 65433 65434" from "66743578456"

    Then a new outgoing text message should be created destined for the mobile_number: "Kikie's number"
    And the outgoing_text_message should be a translation of "unauthorized message action" in "en" (English) where name: "Kikie"
    
  Scenario Outline: Try to confirm paying for an an order incorrectly
    When I text <text_message> from "66542345789"
 
    Then a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "confirmation invalid when pay4order" in "en" (English) 

      Examples:
      | text_message                               |
      | "1234 pay4order 65433 65434 CONFIRM"       |
      | "1234 pay4order 65433 65434 anything else" |
      
  Scenario: Try to trigger a payment for someone elses order
    Given a seller exists
    And a mobile_number: "Another sellers number" exists with phoneable: the seller, number: "6698654568", password: "1234"
    When I text "1234 pay4order 65433 65434" from "6698654568"

    Then a new outgoing text message should be created destined for the mobile_number: "Another sellers number"
    And the outgoing_text_message should include a translation of "order not found when pay4order" in "en" (English)
    
  Scenario: Try to pay for an order where the product has no supplier price
    Given a product exists with supplier: the supplier, seller: the seller
    And a supplier_order exists with id: 65435, seller_order: the seller_order, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

    When I text "1234 pay4order 65433 65435" from "66542345789"

    Then a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "payment not greater than" in "en" (English) where count: 0
    
  Scenario: Do not create a payment if there is already a payment for this order
    Given a product exists with supplier: the supplier, seller: the seller, cents: 500000, currency: "KHR"
    And a supplier_order exists with id: 65435, seller_order: the seller_order, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product
    And a payment exists with cents: 2000000, currency: "KHR", supplier_order: the supplier_order, seller: the seller, supplier: the supplier

    When I text "1234 pay4order 65433 65435" from "66542345789"

    Then a new outgoing text message should be created destined for the mobile_number: "Dave's number"
    And the outgoing_text_message should include a translation of "payment already exists for this order" in "en" (English) where value: "65435"
