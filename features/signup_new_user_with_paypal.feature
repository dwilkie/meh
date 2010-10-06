Feature: Signup new user with paypal
  In order to avoid filling out forms when signing up and to automatically configure my permissions
  As a seller
  I want to be able to signup using paypal

  Scenario: New user follows the 'sign up with paypal' link
    Given I am on the home page
    And I want to sign up with paypal

    When I follow "Signup with paypal"

    Then I should be redirected to sign in with paypal
    And permission should be requested to grant access to the masspay api

