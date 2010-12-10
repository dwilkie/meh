Feature: Invalid or blank incoming text messages
  In order to be informed that my text message was invalid
  As an existing user
  I want to receive brief help containing examples of valid messages

  Background:
    Given a supplier exists with name: "Dave"
    And a verified mobile number exists with user: the user, number: "66322345211"

  Scenario: An incoming text message is received with blank text
    When I text "" from "66322345211"

    Then the most recent outgoing text message destined for the mobile number should include a translation of "is required" in "en" (English)
    And the supplier should be that outgoing text message's payer

  Scenario: An incoming text message is received with unknown text
    When I text "blah" from "66322345211"

    Then the most recent outgoing text message destined for the mobile number should include a translation of "message text is invalid" in "en" (English) where value: "blah"
    And the supplier should be that outgoing text message's payer

  Scenario: An incoming message is received from a supplier with a single seller with unknown text
    Given a seller exists
    And a partnership exists with seller: the seller, supplier: the supplier

    When I text "blah" from "66322345211"

    Then the most recent outgoing text message destined for the mobile number should include a translation of "message text is invalid" in "en" (English) where value: "blah"
    And the seller should be that outgoing text message's payer

