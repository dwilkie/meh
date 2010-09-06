Feature: Send mobile number verification
  In order to verify that my mobile number is correct
  As a user
  I want to receive a verification message when I add a new mobile number or update an existing one

  Scenario: A mobile number is created for an existing user
    Given a user exists

    When a mobile number is created with user: the user
    Then the mobile number should be the user's active_mobile_number
    And the most recent outgoing text message destined for the mobile number should be a translation of "verify your mobile number" in "en" (English)

  Scenario: A mobile number is created but does not belong to an existing user
    When a mobile number is created

    Then an outgoing text message should not exist

  Scenario: A mobile number is updated for an existing user
    Given a user exists
    And a mobile number exists with number: "66122453311", user: the user

    When I update the mobile number with number: "66122453312"

    Then the mobile number should be the user's active_mobile_number
    And the most recent outgoing text message destined for the mobile number should be a translation of "verify your mobile number" in "en" (English)
    And the 2nd most recent outgoing text message destined for the mobile number should be a translation of "verify your mobile number" in "en" (English)

  Scenario: A mobile number is updated for an existing user with the same number
    Given a user exists
    And a mobile number exists with number: "66122453311", user: the user

    When I update the mobile number with number: "+006612-2453-311"

    Then the mobile number should be the user's active_mobile_number
    And the most recent outgoing text message destined for the mobile number should be a translation of "verify your mobile number" in "en" (English)
    But 1 outgoing text messages should exist with mobile_number_id: the mobile number

