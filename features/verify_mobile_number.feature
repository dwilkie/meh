Feature: Send mobile number verification
  In order to verify that my mobile number is correct
  As a user
  I want to be able to verify my mobile number by texting in my name

  Background:
    Given a user: "Dave" exists with name: "Dave"
    And a mobile number exists with number: "66354668874", user: the user

  Scenario Outline: Verify my number
    When I text "<message_text>" from "66354668874"

    Then the mobile number should be verified
    And the most recent outgoing text message destined for the mobile number should be a translation of "your mobile number is verified" in "en" (English) where user_name: "Dave"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text |
      | Dave         |
      | DAVE         |
      | dave         |

  Scenario: Verify my number as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "Dave" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should be a translation of "your mobile number is verified" in "en" (English) where user_name: "Dave"
    And the seller should be the outgoing text message's payer

  Scenario Outline: Try to verify my number texting the wrong name
    When I text "<message_text>" from "66354668874"

    Then the mobile number should not be verified
    And the most recent outgoing text message destined for the mobile number should include a translation of "name is incorrect" in "en" (English) where value: "<message_text>"
    And the user should be the outgoing text message's payer

    Examples:
      | message_text  |
      | David         |
      | david johnson |
      | PETER johnson |

  Scenario: Try to verify my number texting the wrong name as a supplier
    Given the user is also a supplier
    And a seller exists
    And a product exists with seller: the seller, supplier: user: "Dave"

    When I text "David" from "66354668874"

    Then the most recent outgoing text message destined for the mobile number should include a translation of "name is incorrect" in "en" (English) where value: "David"
    And the seller should be the outgoing text message's payer

  Scenario: Try to verify my number omitting my name
    When I text "" from "66354668874"

    Then the mobile number should not be verified
    And the most recent outgoing text message destined for the mobile number should include a translation of "is required" in "en" (English)
    And the user should be the outgoing text message's payer

