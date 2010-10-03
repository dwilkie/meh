Feature: Send mobile number verification
  In order to verify that my mobile number is correct
  As a user
  I want to be able to verify my mobile number by texting in my name

  Background:
    Given a user: "Dave" exists with name: "Dave"
    And a mobile number exists with number: "66354668874", user: the user

  Scenario Outline: Successfully verify my number
    When I text "<message_text>" from "66354668874"

    Then the mobile number should be verified
    And the most recent outgoing text message destined for the mobile number should be a translation of "you successfully verified your mobile number" in "en" (English) where name_supplied: "<name_supplied>"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text              | name_supplied  |
      | vmn Dave                  | Dave           |
      | mn verify DAVE            | DAVE           |
      | mn v dave johnson         | dave           |
      | mobile_number verify dave | dave           |
      | MobileNumber v dave       | dave           |

  Scenario: Successfully verify my number as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "vmn Dave" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should be a translation of "you successfully verified your mobile number" in "en" (English) where name_supplied: "Dave"
    And the seller should be the outgoing text message's payer

  Scenario Outline: Try to verify my number texting the wrong name
    When I text "<message_text>" from "66354668874"

    Then the mobile number should not be verified
    And the most recent outgoing text message destined for the mobile number should include a translation of "name is incorrect" in "en" (English) where value: "<value>"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text                 | value   |
      | vmn David                    | David   |
      | mn verify david johnson      | david   |
      | mn v PETER johnson           | PETER   |
      | mobile_number verify johnson | johnson |
      | MobileNumber verify johnson  | johnson |

  Scenario: Try to verify my number texting the wrong name as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "vmn David" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should include a translation of "name is incorrect" in "en" (English) where value: "David"
    And the seller should be the outgoing text message's payer

  Scenario Outline: Try to verify my number omitting my name
    When I text "<message_text>" from "66354668874"

    Then the mobile number should not be verified
    And the most recent outgoing text message destined for the mobile number should be a translation of "the name is missing or incorrect" in "en" (English) where errors: "Name is required", topic: "<topic>", action: "<action>"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text         | topic          | action |
      | vmn                  | mn             | v      |
      | mn verify            | mn             | verify |
      | mn v                 | mn             | v      |
      | mobile_number verify | mobile_number  | verify |
      | MobileNumber v       | MobileNumber   | v      |

  Scenario: Try to verify my number omitting my name as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "vmn" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should be a translation of "the name is missing or incorrect" in "en" (English) where errors: "Name is required", topic: "mn", action: "v"
    And the seller should be the outgoing text message's payer

  Scenario Outline: Try to verify my number forgetting to supply an action
    When I text "<message_text>" from "66354668874"

    Then the mobile number should not be verified
    And the most recent outgoing text message destined for the mobile number should be a translation of "no action for mobile number" in "en" (English) where topic: "<message_text>"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text   |
      | mn             |
      | mobile_number  |
      | MobileNumber   |

  Scenario: Try to verify my number forgetting to supply an action as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "mn" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should be a translation of "no action for mobile number" in "en" (English) where topic: "mn"
    And the seller should be the outgoing text message's payer

  Scenario Outline: Try to accept an order supplying an invalid action
    When I text "<message_text>" from "66354668874"

    Then the mobile number should not be verified
    And the most recent outgoing text message destined for the mobile_number should be a translation of "invalid action for mobile number" in "en" (English) where topic: "<topic>", action: "<action>"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text                | topic         | action   |
      | mn z                        | mn            | z        |
      | mobile_number 4             | mobile_number | 4        |
      | pmn                         | mn            | p        |
      | MobileNumber maggot         | MobileNumber  | maggot   |

  Scenario: Try to accept an order supplying an invalid action as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "mn z" from "66354668874"

    Then the most recent outgoing text message destined for the mobile_number should be a translation of "invalid action for mobile number" in "en" (English) where topic: "mn", action: "z"
    And the seller should be the outgoing text message's payer

