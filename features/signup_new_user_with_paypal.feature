Feature: Signup new user with paypal
  In order to avoid filling out forms when signing up and to automatically configure my permissions
  As a seller
  I want to be able to signup using paypal

  Scenario: I follow the 'sign up with paypal' link
    Given I am on the home page
    And I want to sign up with paypal

    When I follow "Signup with paypal"

    Then I should be redirected to sign in with paypal
    And permission should be requested to grant access to the masspay api

  Scenario: I grant the required permissions
    Given I have a paypal account with email: "mara@example.com", first_name: "Mara", last_name: "Mank"
    And I sign into paypal and grant the required permissions

    When I am redirected back to the application

    Then a user should exist with email: "mara@example.com", name: "Mara"
    And the user should be a seller
    And the user should be signed in

