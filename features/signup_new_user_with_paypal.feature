@devise_paypal
Feature: Signup new user with paypal
  In order to ensure my details match up with Paypals when I sign up
  As a new seller
  I want to always signup using Paypal

  @current
  Scenario: I click the sign up with paypal link
    Given I am on the homepage
    When I follow "Signup/Login with Paypal"
    Then I should be redirected to sign in with paypal

  Scenario: I successfully signed in with Paypal
    Given I have a paypal account with first_name: "mara", email: "mara@example.com"
    And I successfully signed in with paypal

    When I am redirected back to the application from paypal

    Then a user should exist with email: "mara@example.com", name: "Mara"
    And I should be on the homepage
    And I should see "Welcome Mara! You are now signed in"

  Scenario: I cancel signing in with Paypal
    Given I have a paypal account with first_name: "mara", email: "mara@example.com"
    But I did not sign in with paypal

    When I am redirected back to the application from paypal

    Then I should be on the homepage
    And I should see "Not signed in"

  Scenario: I sign in with paypal and am returned to the application
    Given a user exists with name: "Mara", email: "mara@example.com"
    And I have a paypal account with name: "mara", email: "mara@example.com"
    And I successfully sign in with paypal

    When I am redirected back to the application from paypal

    Then I should be on the homepage
    And I should see "Welcome back Mara! You are now signed in"

