Feature: Validate processing an order
  In order to avoid causing problems when making a mistake while processing an order and to get feedback on the error(s) I made
  As a supplier
  I want to make sure that I can't do anything I shouldn't be able to do while processing an order

  Background:
    Given a supplier exists with name: "Phan"
    And a mobile_number exists with number: "66354668789", password: "9876", phoneable: the supplier
    And a supplier_order exists with id: 154674, supplier: the supplier

  Scenario Outline: Try to process an order with an incorrect order number
    When I text <text_message> from "66354668789"
    Then the supplier_order should not be <processed>
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "order not found when processing order" in "en" (English)

    Examples:
      | text_message                | processed |
      | "9876 acceptorder 154673"   | accepted  |
      | "9876 rejectorder 154673"   | rejected  |
      | "9876 completeorder 154673" | completed |

  Scenario Outline: Try to process an order as a seller
    Given a seller exists with name: "Dave"
    And a mobile_number exists with phoneable: the seller, number: "66354668790", password: "3456"
    
    When I text <text_message> from "66354668790"
    Then the supplier_order should not be <processed>
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should be a translation of "unauthorized message action" in "en" (English) where name: "Dave"

    Examples:
      | text_message         | processed |
      | "3456 acceptorder"   | accepted  |
      | "3456 rejectorder"   | rejected  |
      | "3456 completeorder" | completed |

  Scenario Outline: Try to process an order not belonging to me
    Given a supplier exists with name: "Keng"
    And a mobile_number exists with phoneable: the supplier, number: "66354668790", password: "5678"

    When I text <text_message> from "66354668790"
    Then the supplier_order should not be <processed>
    And a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "order not found when processing order" in "en" (English)
    
    Examples:
      | text_message                | processed    |
      | "5678 acceptorder 154674"   | accepted     |
      | "5678 rejectorder 154674"   | rejected     |
      | "5678 completeorder 154674" | completed    |
