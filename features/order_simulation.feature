Feature: Order Simulation
  In order test out the system
  As a seller
  I want to be able simulate new orders

  Scenario: Navigate to the order simulation page
    Given I am logged in with password: "secret"

    When I follow "Launch Demo"

    Then I should be on the new order simulation page

  Scenario: Try to go to the order simulation page without logging in
    When I go to the order simulation page

    Then I should be on the login page

  @current
  Scenario: Create a new order simulation for yourself with no mobile number set up
    Given I am logged in with password: "secret"
    Then I should see "Your mobile number"

    When I fill in "Your mobile number" with "66123332221"
    And I press "Launch"

