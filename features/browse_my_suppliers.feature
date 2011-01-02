Feature: Browse my suppliers
  In order to easily get information about my suppliers and manage their orders
  As a seller
  I want to be able see my suppliers at a glance

  Scenario: I navigate to the suppliers page
    Given I am logged in with password: "secret"

    When I follow "Suppliers"

    Then I should be on the suppliers page
    And I should see "New Supplier"

  Scenario: I try to go to the suppliers page without logging in
    Given I am not logged in

    When I go to the suppliers page

    Then I should be on the login page

  Scenario Outline: I have existing suppliers
    Given a <role>: "Mark" exists with name: "Mark"
    And a mobile number exists with user: the <role>, number: "661234433121"
    And I am logged in with password: "secret"
    And a partnership exists with seller: the seller, supplier: <role>: "Mark"

    When I go to the suppliers page

    Then I should see "Mark"
    And I should see "+661234433121"
    And I should see "Awaiting Confirmation"

    Examples:
      | role     |
      | seller   |
      | supplier |

