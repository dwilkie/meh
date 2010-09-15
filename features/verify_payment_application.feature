Feature: Verify payment application
  In order to be sure that the url I entered is correct and points to a valid payment application
  As a seller
  I want my payment application to be verified when I create or edit the url

  Scenario: I create a payment application
    When I create a payment application

    Then the payment application should not be verified
    But the most recent job in the queue should be to verify the payment application
    And the job's priority should be "3"

  Scenario: I update my unverified payment application url
    Given a payment application exists

    When I update the payment application with uri: "http://google.com"

    Then the payment application should not be verified
    But the most recent job in the queue should be to verify the payment application
    And the 2nd most recent job in the queue should be to verify the payment application

  Scenario: I update my verified payment application url
    Given a verified payment application exists

    When I update the payment application with uri: "http://google.com"

    Then the payment application should not be verified
    But the most recent job in the queue should be to verify the payment application

  Scenario: I enter a url that points to a valid payment application
    When I create a payment application

    Then the most recent job in the queue should be to verify the payment application

    Given the url resolves to a valid payment application

    When the worker works off the job

    Then the job should be deleted from the queue
    And the payment application should be verified

  Scenario: I enter a url that does not resolve
    When I create a payment application

    Then the most recent job in the queue should be to verify the payment application

    Given the url does not resolve

    When the worker works off the job
    And the worker works off the job again

    Then the job should be deleted from the queue
    And the payment application should not be verified

 Scenario: I enter a url that does not have a 'payment_requests' resource
    When I create a payment application

    Then the most recent job in the queue should be to verify the payment application

    Given the url does not have a "payment_requests" resource

    When the worker works off the job

    Then the job should be deleted from the queue
    And the payment application should not be verified

