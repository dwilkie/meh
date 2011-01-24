Feature: Sign up through Paypal
  In order sign up quickly and easily
  As a new seller
  I want to be able to signup through my Paypal account

  Scenario: I navigate to the sign up page
    Given I am on the homepage

    When I follow "Sign up for free"

    Then I should be on the signup page
    And I should see "Sign up for free through Paypal"
    And I should see "Enter your Mobile Number"
    And I should see "International format" within "#new_user span.hint"
    And I should see the alt text "Paypal_logo"

  Scenario Outline: I try to sign up with an invalid mobile number
    Given I am on the signup page
    And I fill in "Mobile Number" with "<invalid_number>"

    When I press "Sign Up"

    Then I should see "<error_message>" within "#new_user span.error"

    Examples:
      | invalid_number | error_message |
      |                | is required   |
      | maggot         | is required   |
      | 12345          | is invalid    |

  Scenario: I try to signup with a mobile number which has already been taken
    Given a mobile number exists with number: "331234456653"
    And I am on the signup page
    And I fill in "Mobile Number" with "+33-1234456653"

    When I press "Sign Up"

    Then I should see "already been taken" within "#new_user span.error"

  Scenario: I sign up with a valid mobile number
    Given no paypal authentications exist
    And I am on the signup page
    And I fill in "Mobile Number" with "+122544331"

    When I press "Sign Up"

    Then a paypal authentication should exist
    But the paypal authentication's token should be nil
    And the most recent job in the queue should be to get an authentication token
    And the job's priority should be "5"
    And I should be on the paypal authentication's show page
    And I should see "Please wait while we redirect you to Paypal..."

  Scenario: Paypal returns a token
    Given I signed up
    Then the most recent job in the queue should be to get an authentication token
    Given paypal will return an authentication token
    When the worker works off the job
    Then the job should be deleted from the queue
    And the paypal authentication's token should be the authentication token

  Scenario: Paypal does not return a token
    Given I signed up
    Then the most recent job in the queue should be to get an authentication token
    Given paypal will not return an authentication token
    When the worker works off the job
    Then the job should not be deleted from the queue

  Scenario: I follow "redirect you to Paypal..." after a token has been created
    Given I signed up
    And the paypal authentication has a token

    When I follow "redirect you to Paypal..."

    Then I should be redirected to sign in with Paypal

  Scenario: I follow "redirect you to Paypal" before a token has been created
    Given I signed up
    And the paypal authentication does not have a token

    When I follow "redirect you to Paypal..."
    Then I should be on the paypal authentication's show page

  Scenario: I am redirected back to the app from Paypal
    Given I signed up
    And the paypal authentication has a token

    When I am redirected back from paypal with the paypal authentication's token

    Then I should see "Please wait while we check your details..."

#  Scenario: I successfully sign up through Paypal
#    Given I have a paypal account with first_name: "mara", email: "mara@example.com"
#    And I signed up with mobile number: "+33-122133332"
#    And I successfully signed in with paypal

#    When I am redirected back to the application from paypal

#    Then a user should exist with email: "mara@example.com", name: "Mara"
#    And a mobile number should exist with user: the user, number: "33122133332"
#    And I should be on the overview page
#    And I should see "Welcome Mara! You're now signed in"
#    And "seller" should be one of the user's roles

#  Scenario: I try to sign up with a mobile number that already exists
#    Given a user exists
#    And a mobile number exists with number: "+33-122133332"
#    And I have a paypal account with first_name: "mara", email: "mara@example.com"
#    And I signed up with mobile number: "+33-122133332"
#    And I successfully signed in with paypal

#    When I am redirected back to the application from paypal

#    Then a user should not exist with email: "mara@example.com"
#    And I should be on the homepage

#  Scenario: I already signed up and I try to sign up again
#    Given a user exists with email: "mara@example.com"
#    And I have a paypal account with first_name: "mara", email: "mara@example.com"
#    And I signed up with mobile number: "+33-122133332"
#    And I successfully signed in with paypal

#    When I am redirected back to the application from paypal

#    Then I should be on the overview page
#    And I should see "Welcome Mara! You're now signed in"
#    But a mobile number should not exist with number: "33122133332"

#  Scenario: I cancel signing in with Paypal
#    Given I have a paypal account with first_name: "mara", email: "mara@example.com"
#    But I did not sign in with paypal

#    When I am redirected back to the application from paypal

#    Then a user should not exist
#    And I should be on the homepage
#    And I should see "Sorry, could not authorize you from Paypal."

