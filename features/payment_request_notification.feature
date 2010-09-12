Feature: Payment Request Notification
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with name: "Dave"
    And a mobile_number: "Dave's number" exists with user: the seller
    And a supplier exists with name: "Fon"
    And a mobile_number: "Fon's number" exists with user: the supplier, number: "665323568467"
    And a verified payment application exists with seller: the seller
    And a product exists with seller: the seller, supplier: the supplier, number: "120848121933", name: "A Rubber Dingy"
    And a supplier order exists for the product with quantity: 1
    When a payment is created with cents: "50000", currency: "THB", supplier_order: the supplier order, seller: the seller, supplier: the supplier
    Then a payment request should exist with payment_id: the payment

  Scenario: A notification is received for an existent payment request
    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'id' => '23'
      }
    }
    """
    And the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

  Scenario Outline: A notification containing an unsuccessful payment response is verified
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified
    And a notification was received for an existent payment request with:
    """
    {
     'payment_request' => {
        'payment_response' => {
          'error(0).category'=>'Application',
          'error(0).domain'=>'PLATFORM',
          'error(0).errorId'=>'58903',
          'error(0).message'=>'The email address dave@example.com is invalid. It may not be registered in PayPals system yet',
          'error(0).severity'=>'Error',
          'responseEnvelope.ack'=>'Failure',
          'responseEnvelope.build'=>'1310729',
          'responseEnvelope.correlationId'=>'ec7f3ae427ee1',
          'responseEnvelope.timestamp'=>'2010-06-12T02:16:26.587-07:00'
        },
        'id' => '23'
      }
    }
    """
    Then the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

    Given the remote payment application for the payment request sent the notification and is currently up

    When the worker works off the job

    Then the job should be deleted from the queue
    And the payment request notification should be verified
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "email address dave@example.com is invalid. It may not be registered in PayPals system yet"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: A notification containing errors originating from the remote payment application is verified
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified
    And a notification was received for an existent payment request with:
    """
    {
     'payment_request' => {
        'errors' => {
          <error>,
        },
        'id' => '23'
      }
    }
    """

    Examples:
      | error           | error_message                  |
      | 'payee_not_found' => true  | ""                  |
      | 'payee_maximum_amount_exceeded' => true | "" |
      | 'payee_currency_invalid' => true} | "" |


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

