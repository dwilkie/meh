Feature: Create supplier partnerships
  In order to get suppliers to deliver my products
  As a seller
  I want to be able to create partnerships with suppliers

  Scenario: I navigate to the new supplier page
    Given I am logged in with password: "secret"
    And I am on the suppliers page

    When I follow "New Supplier"

    Then I should be on the new supplier page
    And I should see "Name"
    And I should see "Number"

  Scenario: I try to go to the suppliers page without logging in
    Given I am not logged in

    When I go to the new supplier page

    Then I should be on the login page

  Scenario: I add a new supplier
    Given I am logged in with password: "secret"
    And I am on the new supplier page
    And I fill in "Name" with "John"
    And I fill in "Number" with "+1 32222-11234"

    When I press "Create Supplier"

    Then a supplier should exist with name: "John"
    And a mobile number should exist with user: the supplier, number: "13222211234"
    And a partnership should exist with seller: the seller, supplier: the supplier
    But the partnership should not be confirmed
    And I should be on the suppliers page

  Scenario Outline: I add a supplier that already exists
    Given a <role>: "Peter" exists with name: "Peter"
    And a mobile number exists with user: the <role>, number: "13222211234"
    And I am logged in with password: "secret"
    And I am on the new supplier page
    And I fill in "Name" with "John"
    And I fill in "Number" with "+1 32222-11234"

    When I press "Create Supplier"

    Then a partnership should exist with seller: the seller, supplier: the <role>: "Peter"
    But the partnership should not be confirmed
    But the <role>: "Peter"'s name should be "Peter"
    And I should be on the suppliers page

    Examples:
      | role     |
      | seller   |
      | supplier |

  Scenario Outline: I add a supplier who is already a partner
    Given a supplier exists
    And a mobile number exists with user: the supplier, number: "13222211234"
    And I am logged in with password: "secret"
    And a partnership exists with seller: the seller, supplier: the supplier
    And the partnership <was_already_or_is_not_yet> confirmed
    And I am on the new supplier page
    And I fill in "Number" with "+1 32222-11234"

    When I press "Create Supplier"

    Then a partnership should exist with seller: the seller, supplier: the supplier
    And the partnership should <be_or_not_be> confirmed
    And I should be on the suppliers page

    Examples:
      | was_already_or_is_not_yet | be_or_not_be |
      | was already               |  be          |
      | is not yet                |  not be      |

