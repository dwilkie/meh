Feature: Supplier order invalid messages
  In order to be informed that my text message for a supplier order was invalid
  As a supplier
  I want to receive brief help containing examples of valid messages for a supplier order

  Background:
    Given a seller exists
    And a supplier exists with name: "Nok"
    And a product exists with seller: the seller, supplier: the supplier
    And a verified mobile number exists with number: "66354668874", user: the supplier

  Scenario Outline: Try to process an order forgetting to supply an action
    When I text "<message_text>" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should be a translation of "what would you like to do with the supplier order?" in "en" (English) where topic: "<message_text>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text    |
      | po              |
      | ProductOrder    |

  Scenario Outline: Try to process an order supplying an invalid action
    When I text "<message_text>" from "66354668874"

    Then the most recent outgoing text message destined for the mobile_number should be a translation of "invalid action given for the supplier order" in "en" (English) where topic: "<topic>", action: "<action>"
    And the seller should be that outgoing text message's payer

    Examples:
      | message_text                    | topic         | action         |
      | product_order z                 | product_order | z              |
      | po 4                            | po            | 4              |
      | po invalid_action               | po            | invalid_action |

  Scenario: Try to process an order without a verified mobile number
    Given the mobile number is not yet verified

    When I text "po" from "66354668874"

    Then the most recent outgoing text message destined for the mobile_number should be a translation of "you must verify your mobile number to use this feature" in "en" (English)
    And the seller should be that outgoing text message's payer

