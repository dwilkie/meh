Feature: Signup new user with paypal
  In order to avoid filling out forms when signing up and to automatically configure my permissions
  As a seller
  I want to be able to signup using paypal

  @current
  Scenario: I follow the 'sign up with paypal' link
    Given I am on the home page
    And I want to sign up with paypal

    When I follow "Signup with paypal"

    Then I should be redirected to sign in with paypal
    And permission should be requested to grant access to the masspay api

  Scenario: I grant the required permissions
    Given I have a paypal account with email: "mara@example.com", first_name: "mara", last_name: "Mank"
    And I sign into paypal and grant the required permissions

    When I am redirected back to the application from paypal

    Then a user should exist with email: "mara@example.com", name: "Mara"
    And the user should have 1 roles
    And "seller" should be one of the user's roles
    #And I should see "logged in as Mara"

  Scenario: I do not grant the required permissions
    Given I have a paypal account with email: "mara@example.com", first_name: "mara", last_name: "Mank"
    And I sign into paypal but do not grant the required permissions
    When I am redirected back to the application from paypal

    Then a user should not exist with email: "mara@example.com", name: "Mara"
    And I should be on the home page
    And I should see "Unable to"

  @current
  Scenario: I do not sign into paypal
    Given I do not sign into paypal

    When I am redirected back to the application from paypal

    Then a user should not exist with email: "mara@example.com", name: "Mara"

