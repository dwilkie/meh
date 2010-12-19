@devise_paypal
Feature: Signup with Paypal
  In order to ensure my details match up with Paypals when I sign up
  As a new seller
  I want to always signup using Paypal

  Scenario: I navigate to the sign up page
    Given I am on the homepage

    When I follow "Signup"

    Then I should be on the signup page
    And I should see "Mobile Number"

  Scenario: I give a valid mobile number
    Given I am on the signup page
    And I fill in "Mobile Number" with "13432123321"

    When I press "Signup through Paypal"

    Then I should be redirected to sign in with paypal

  Scenario: I don't give a valid mobile number
    Given I am on the signup page
    And I fill in "Mobile Number" with "hello"

    When I press "Signup through Paypal"

    Then I should see "is required"

  Scenario: I try to signup with a mobile number that already exists
    Given a mobile number exists with number: "331234456653"
    And I am on the signup page
    And I fill in "Mobile Number" with "+33-1234456653"

    When I press "Signup through Paypal"

    Then I should see "already been taken"

  Scenario: I successfully sign up through Paypal
    Given I have a paypal account with first_name: "mara", email: "mara@example.com"
    And I signed up with mobile number: "+33-122133332"
    And I successfully signed in with paypal

    When I am redirected back to the application from paypal

    Then a user should exist with email: "mara@example.com", name: "Mara"
    And a mobile number should exist with user: the user, number: "33122133332"
    And I should be on the overview page
    And I should see "Welcome Mara! You're now signed in"
    And "seller" should be one of the user's roles

  Scenario: I try to sign up with a mobile number that already exists
    Given a user exists
    And a mobile number exists with number: "+33-122133332"
    And I have a paypal account with first_name: "mara", email: "mara@example.com"
    And I signed up with mobile number: "+33-122133332"
    And I successfully signed in with paypal

    When I am redirected back to the application from paypal

    Then a user should not exist with email: "mara@example.com"
    And I should be on the homepage

  Scenario: I already signed up and I try to sign up again
    Given a user exists with email: "mara@example.com"
    And I have a paypal account with first_name: "mara", email: "mara@example.com"
    And I signed up with mobile number: "+33-122133332"
    And I successfully signed in with paypal

    When I am redirected back to the application from paypal

    Then I should be on the overview page
    And I should see "Welcome Mara! You're now signed in"
    But a mobile number should not exist with number: "33122133332"

  Scenario: I cancel signing in with Paypal
    Given I have a paypal account with first_name: "mara", email: "mara@example.com"
    But I did not sign in with paypal

    When I am redirected back to the application from paypal

    Then a user should not exist
    And I should be on the homepage
    And I should see "Sorry, could not authorize you from Paypal."

