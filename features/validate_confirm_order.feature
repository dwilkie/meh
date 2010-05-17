Feature: Validate confirming an order
  In order to avoid causing problems when making a mistake while confirming an order
           and to get feedback on the error I made
  As a supplier
  I want to make sure that I cant do anything I shouldn't be able to do

  Background:
    Given a supplier exists with name: "Phan"
    And a mobile_number exists with number: "66354668789", phoneable: the supplier
    And a supplier_order exists with id: 154674, supplier: the supplier

  Scenario Outline: Try to confirm an order with an incorrect order number
    When I text <text_message> from "66354668789"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should include a translation of "order not found when confirming order" in "en" (English)
    And the outgoing_text_message should include "Phan"

    Examples:
      | text_message         |
      | "acceptorder 154673" |
      | "rejectorder 154673" |

  Scenario Outline: Try to confirm an order as a seller
    Given a seller exists with name: "Dave"
    And a mobile_number exists with phoneable: the seller, number: "66354668790"
    
    When I text <text_message> from "66354668790"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of "unauthorized message action" in "en" (English) where action: <action>, name: "Dave"

    Examples:
      | text_message  | action        |
      | "acceptorder" | "acceptorder" |
      | "rejectorder" | "rejectorder" |

  Scenario Outline: Try to confirm an order not belonging to me
    Given a supplier exists with name: "Keng"
    And a mobile_number exists with phoneable: the supplier, number: "66354668790"

    When I text <text_message> from "66354668790"
    Then the supplier_order should not be confirmed
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should include a translation of "order not found when confirming order" in "en" (English)
    And the outgoing_text_message should include "Keng"
    
    Examples:
      | text_message         |
      | "acceptorder 154674" |
      | "rejectorder 154674" |

  Scenario Outline: Try to confirm an already confirmed order
    Given a supplier exists with name: "Bruno"
    And a mobile_number exists with phoneable: the supplier, number: "66354668790"
    And a product exists with supplier: the supplier, verification_code: "xcvbyu"
    And a supplier_order exists with id: 654789, quantity: 5, product: that product, supplier: the supplier, status: <status>
    
    When I text <text_message> from "66354668790"
    And an outgoing_text_message should exist with smsable_id: the mobile_number
    And the outgoing_text_message should be a translation of "order already confirmed" in "en" (English) where confirmation: <status>, supplier: "Bruno"
    
    Examples:
      | status     | text_message                    |
      | "accepted" | "acceptorder 654789 5 x xcvbyu" |
      | "accepted" | "rejectorder 654789"            |
      | "rejected" | "acceptorder 654789 5 x xcvbyu" |
      | "rejected" | "rejectorder 654789"            |
