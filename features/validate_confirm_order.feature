Feature: Validate confirming an order
  In order to avoid causing problems when making a mistake while confirming an order
           and to get feedback on the error I made
  As a supplier
  I want to make sure that I cant do anything I shouldn't be able to do

  Background:
    Given a supplier exists with name: "Phan"
    And a mobile_number exists with number: "66354668789", password: "9876", phoneable: the supplier
    And a supplier_order exists with id: 154674, supplier: the supplier

  Scenario Outline: Try to confirm an order with an incorrect order number
    When I text <text_message> from "66354668789"
    Then the supplier_order should not be confirmed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "order not found when confirming order" in "en" (English)
    And the outgoing_text_message should include "Phan"

    Examples:
      | text_message              |
      | "9876 acceptorder 154673" |
      | "9876 rejectorder 154673" |

  Scenario Outline: Try to confirm an order as a seller
    Given a seller exists with name: "Dave"
    And a mobile_number exists with phoneable: the seller, number: "66354668790", password: "3456"
    
    When I text <text_message> from "66354668790"
    Then the supplier_order should not be confirmed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "unauthorized message action" in "en" (English) where action: <action>, name: "Dave"

    Examples:
      | text_message       | action        |
      | "3456 acceptorder" | "acceptorder" |
      | "3456 rejectorder" | "rejectorder" |

  Scenario Outline: Try to confirm an order not belonging to me
    Given a supplier exists with name: "Keng"
    And a mobile_number exists with phoneable: the supplier, number: "66354668790", password: "5678"

    When I text <text_message> from "66354668790"
    Then the supplier_order should not be confirmed
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "order not found when confirming order" in "en" (English)
    And the outgoing_text_message should include "Keng"
    
    Examples:
      | text_message              |
      | "5678 acceptorder 154674" |
      | "5678 rejectorder 154674" |

  Scenario Outline: Try to confirm an already confirmed order
    Given a supplier exists with name: "Bruno"
    And a mobile_number exists with phoneable: the supplier, number: "66354668790", password: "4567"
    And a product exists with supplier: the supplier, verification_code: "xcvbyu"
    And a supplier_order exists with id: 654789, quantity: 5, product: that product, supplier: the supplier, status: <status>
    
    When I text <text_message> from "66354668790"
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "order already confirmed" in "en" (English) where confirmation: <status>, supplier: "Bruno"
    
    Examples:
      | status     | text_message                         |
      | "accepted" | "4567 acceptorder 654789 5 x xcvbyu" |
      | "accepted" | "4567 rejectorder 654789"            |
      | "rejected" | "4567 acceptorder 654789 5 x xcvbyu" |
      | "rejected" | "4567 rejectorder 654789"            |
