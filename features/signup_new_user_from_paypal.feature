Feature: Signup new user from paypal
  In order to avoid filling out forms when signing up and to automatically configure my permissions
  As a seller
  I want to be able to signup using paypal

  Scenario: New user navigates to the signup page
    Given I am on the home page
    When I follow "Signup with paypal"

#    Then I should be redirected to paypal

