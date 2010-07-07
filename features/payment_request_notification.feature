Feature: Payment Request Notification
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with name: "Mara"
    And a mobile_number: "Mara's number" exists with phoneable: the seller
    And a supplier exists with name: "Dave"
    And a mobile_number: "Dave's number" exists with phoneable: the supplier, number: "665323568467"
    And a product exists with seller: the seller, supplier: the supplier, cents: "50000", currency: "THB", external_id: "blueshirt01"
    And a seller_order exists with id: 523321, seller: the seller
    And a supplier_order exists with id: 523322, supplier: the supplier, product: the product, quantity: "1", seller_order: the seller_order
    And a payment exists with cents: "50000", currency: "THB", supplier_order: the supplier_order, seller: the seller, supplier: the supplier
    And a payment_request exists with id: 234564, application_uri: "http://mara-payment-app.appspot.com", payment: the payment
    And the payment request has been sent to: "http://mara-payment-app.appspot.com"
    And all outgoing text messages have been sent

  Scenario: A payment request notification is received for an existing payment request
    When a payment request notification is received for 234564 with: "{'payment_request' => {'id' => '23'}}"
    Then a job should exist to verify it came from the remote application for this payment request

  Scenario: A payment request notification is received for an existing payment request and the remote application for this payment request replies that it sent the notification
    Given a payment request notification was received for 234564 with: "{'payment_request' => {'payment_response' => {'someresponse' => 'response'}, 'id' => '23'}}"
    And the remote application for this payment request sent the notification
    And the worker is about to process its job and verify the notification came from the remote application for this payment request

    When the worker completes its job

    Then there should be no jobs in the queue
    And the payment request notification should be verified
    And the payment_request should not be fraudulent

  Scenario: A payment request notification is received for an existing payment request and the remote application for this payment request replies that it did not send the notification
    Given a payment request notification was received for 234564 with: "{'payment_request' => {'payment_response' => {'someresponse' => 'response'}, 'id' => '23'}}"
    But the remote application for this payment request did not send the notification
    And the worker is about to process its job and verify the notification came from the remote application for this payment request

    When the worker completes its job

    Then the payment request notification should not be verified
    And the payment_request should be fraudulent

  Scenario: A payment request notification is received for a non existing payment request
    When a payment request notification is received for 234563
    Then a job should not exist to verify it came from the remote application for this payment request

  Scenario Outline: A payment request notification is received for an existing payment request but the notification is not formatted correctly
    When a payment request notification is received for 234564 with: <notification>
    Then a job should not exist to verify it came from the remote application for this payment request
    And the payment_request should be fraudulent

   Examples:
     | notification                                                                    |
     | "{'payment_response' => {'someresponse' => 'response'}, 'id' => '23'}"          |
     | "{'payment_request' => {'payment_response' => {'someresponse' => 'response'}}}" |

  Scenario: A notification is received originating from the remote payment application with a successful payment response
  Given the payment request got the following notification: "{'payment_response' => {'responseEnvelope.timestamp'=>'2010-06-04T09:55:36.507-07:00', 'responseEnvelope.ack'=>'Success', 'responseEnvelope.correlationId'=>'1ddf86263c63d', 'responseEnvelope.build'=>'1310729', 'payKey'=>'AP-4MV83827NG0173616', 'paymentExecStatus'=>'COMPLETED'}}"
  And the remote application for this payment request sent the notification

  When the notification gets verified
  Then the payment_request should be successful
  And a new outgoing text message should be created destined for the mobile_number: "Mara's number"
  And the outgoing_text_message should be a translation of "payment request notification" in "en" (English) where supplier: "Dave", seller: "Mara", supplier_order_number: "523322", supplier_contact_details: "+665323568467", amount: "500.00 THB", customer_order_number: "523321", product_code: "blueshirt01", quantity: "1"

  Scenario: A notification is received originating from the remote payment application with an unsuccessful payment response
  Given the payment request got the following notification: "{'payment_response'=>{'error(0).category'=>'Application', 'error(0).domain'=>'PLATFORM', 'error(0).errorId'=>'58903', 'error(0).message'=>'The email address seller3@example.com is invalid. It may not be registered in PayPals system yet', 'error(0).severity'=>'Error', 'responseEnvelope.ack'=>'Failure', 'responseEnvelope.build'=>'1310729', 'responseEnvelope.correlationId'=>'ec7f3ae427ee1', 'responseEnvelope.timestamp'=>'2010-06-12T02:16:26.587-07:00'}}"
  And the remote application for this payment request sent the notification

  When the notification gets verified
  Then the payment_request should not be successful
  And a new outgoing text message should be created destined for the mobile_number: "Mara's number"
  And the outgoing_text_message should include "The email address seller3@example.com is invalid. It may not be registered in PayPals system yet"

  Scenario Outline: A notification is received with errors originating from the remote payment application
    Given the payment request got the following notification: <error>
    And the remote application for this payment request sent the notification

    When the notification gets verified
    Then the payment_request should not be successful
    And a new outgoing text message should be created destined for the mobile_number: "Mara's number"
    And the outgoing_text_message should include a translation of <error_message> in "en" (English) where supplier: "Dave", application_uri: "http://mara-payment-app.appspot.com", currency: "THB"

    Examples:
    | error                                                     | error_message                  |
    | "{'errors' => {'payee_not_found' => true}}"               | "payee not found error"        |
    | "{'errors' => {'payee_maximum_amount_exceeded' => true}}" | "payee maximum amount exceeded error"                                                                                           |
    | "{'errors' => {'payee_currency_invalid' => true}}"        | "payee currency invalid error" |

