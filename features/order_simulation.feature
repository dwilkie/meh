Feature: Order Simulation
  In order test out the system
  As a seller
  I want to be able simulate new orders

  @current
  Scenario: I navigate to the order simulation page
    Given I am logged in with password: "secret"
    And a mobile number exists with user: the user

    When I follow "Launch Demo"

    Then I should be on the new order simulation page

  Scenario: I try to go to the order simulation page without logging in
    When I go to the order simulation page

    Then I should be on the login page

  Scenario: I try to go to the order simulation page without a mobile number
    Given I am logged in with password: "secret"

    When I go to the order simulation page

    Then I should be on the new mobile number page

  Scenario: I create a new order simulation for myself with no mobile number set up
    Given I am logged in with password: "secret"
    And I am on the order simulation page
    Then I should see "Your Mobile Number"

    When I fill in "Your Mobile Number" with "66123332221"
    And I press "Start"

