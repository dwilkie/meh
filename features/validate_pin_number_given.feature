Feature: Validate pin code given
  In order to prevent someone impersonating me by spoofing my number or
           using my phone
  As a user interacting with the system over SMS
  I want to make sure enter my pin number for each SMS request for authentication
  
  Background:
    Given a user exists
    And a mobile_number exists with number: "667788654342", password: "4321", phoneable: the user
  
  Scenario: User sends a blank text message
    When I text "" from "667788654342"
    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "mobile pin number blank" in "en" (English)
    
  Scenario: User forgets or sends and invalid pin number
    When I text "something" from "667788654342"
    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "mobile pin number format invalid" in "en" (English)

  Scenario: User sends the wrong pin
    When I text "4320" from "667788654342"
    Then a new outgoing text message should be created destined for the mobile_number
    And the outgoing_text_message should include a translation of "mobile pin number incorrect" in "en" (English)
