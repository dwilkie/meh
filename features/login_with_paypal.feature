@devise_paypal
Feature: Login with Paypal
  In order to make it simpler to login
  As a seller
  I want to be able to login using Paypal

  Background:
    Given a user exists with name: "Mara", email: "mara@example.com", sign_in_count: 1
    And I have a paypal account with first_name: "mara", email: "mara@example.com"

  Scenario: I click the login with paypal link
    Given I am on the homepage

    When I follow "Login through Paypal"

    Then I should be redirected to sign in with paypal

  Scenario: I sign in with paypal
    Given I successfully signed in with paypal

    When I am redirected back to the application from paypal

    Then I should be on the overview page
    And I should see "Welcome back Mara! You're now signed in."

  Scenario: I cancel signing in with Paypal
    Given I did not sign in with paypal

    When I am redirected back to the application from paypal

    And I should be on the homepage
    And I should see "Sorry, could not authorize you from Paypal"

  Scenario: I try and sign in without registering
    Given no users exist
    But I successfully signed in with paypal

    When I am redirected back to the application from paypal

    Then I should be on the homepage
    And I should see "Sorry, could not authorize you from Paypal"

