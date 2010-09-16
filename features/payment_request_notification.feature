Feature: Payment Request Notification
  In order to be sure that my payment was completed
  As a seller
  I want to receive notifications when a payment request was completed or when a payment request failed

  Background:
    Given a seller exists with name: "Dave"
    And a mobile_number: "Dave's number" exists with user: the seller, number: "662233445353"
    And a supplier exists with name: "Fon", email: "fon@example.com"
    And a mobile_number: "Fon's number" exists with user: the supplier, number: "665323568467"
    And a verified payment application exists with seller: the seller, uri: "http://dave-payment-app-example.com"
    And a product exists with seller: the seller, supplier: the supplier, number: "120848121933", name: "A Rubber Dingy"
    And a supplier order exists for the product with quantity: 1
    When a payment is created with cents: "50000", currency: "THB", supplier_order: the supplier order, seller: the seller, supplier: the supplier
    Then a payment request should exist with payment_id: the payment

  Scenario: A notification is received
    When a notification is received for the payment request

    Then the most recent job in the queue should be to notify the payment request

  Scenario Outline: A notification is received
    Given the payment request was already remote_application_received

    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

    Given the remote payment application for the payment request <sent_or_did_not_send> the notification and is currently up

    When the worker works off the job

    Then the job should be deleted from the queue

    And the payment request <should_or_should_not> have a notification_verified

    Examples:
      | sent_or_did_not_send | should_or_should_not |
      | sent                 | should               |
      | did not send         | should not           |

  Scenario Outline: A notification is received but the remote payment application for this payment request is currently down
    Given the payment request was already remote_application_received

    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

    Given the remote payment application for the payment request <sent_or_did_not_send> the notification but is currently down

    When the worker works off the job

    Then the job should not be deleted from the queue
    And the payment request should not have a notification_verified

    Examples:
      | sent_or_did_not_send |
      | sent                 |
      | did not send         |

  Scenario Outline: The worker gives up trying to reach the remote payment application for this payment request
    Given the mobile number: "Dave's number" was already verified
    And the payment request was already remote_application_received

    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

    Given the remote payment application for the payment request <sent_or_did_not_send> the notification but is currently down

    When the worker tries 9 times to work off the job

    Then the job should be deleted from the queue
    And the payment request should have given_up
    And the payment request should not have a notification verified
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should not be a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "payment url (http://dave-payment-app-example.com/payment_requests) can't be found"

    Examples:
      | sent_or_did_not_send |
      | sent                 |
      | did not send         |

  Scenario Outline: A notification containing an unsuccessful payment response is verified
    Given the mobile number: "Dave's number" <is_not_yet_or_was_already> verified
    And the payment request was already remote_application_received
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
    And the payment request should have a notification_verified
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <be_or_not_be> a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "email address dave@example.com is invalid. It may not be registered in PayPals system yet"

    Examples:
     | is_not_yet_or_was_already | be_or_not_be |
     | is not yet                | not be       |
     | was already               | be           |

  Scenario Outline: A notification containing errors originating from the remote payment application is verified
    Given the mobile number: "Dave's number" was already verified
    And the payment request was already remote_application_received
    And a notification was received for an existent payment request with:
    """
    {
     'payment_request' => {
        'errors' => {
          '<error>' => true,
        },
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

    Given the remote payment application for the payment request sent the notification and is currently up

    When the worker works off the job

    Then the job should be deleted from the queue
    And the payment request should have a notification_verified
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be a translation of "we did not pay your supplier" in "en" (English) where seller_name: "Dave", supplier_name: "Fon", supplier_mobile_number: "No verified number!", supplier_order_quantity: "1", product_number: "120848121933", product_name: "A Rubber Dingy", errors: "<error_message>"

    Examples:
      | error                         | error_message |
      | payee_not_found               | list of payees (configured at: http://dave-payment-app-example.com) does not include Fon (fon@example.com)  |
      | payee_maximum_amount_exceeded | maximum payment amount (configured at: http://dave-payment-app-example.com) for Fon was exceeded   |
      | payee_currency_invalid        | payment currency (configured at: http://dave-payment-app-example.com) for Fon is not THB |

  Scenario: A notification is received for a nonexistent payment request
    Given the payment request was already remote_application_received

    When a notification is received for a nonexistent payment request with:
    """
    {
      'payment_request' => {
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should not be to verify the notification came from the remote payment application for this payment request

  Scenario: An incorrectly formatted notification is received
    Given the payment request was already remote_application_received

    When a notification is received for an existent payment request with:
    """
    {
      'payment_response' => {
        'someresponse' => 'response',
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should not be to verify the notification came from the remote payment application for this payment request

  Scenario: A notification with a missing remote id is received
    Given the payment request was already remote_application_received

    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'someresponse' => 'response'
      }
    }
    """

    Then the most recent job in the queue should not be to verify the notification came from the remote payment application for this payment request

  Scenario: A notification for a payment request that was not sent to the remote application is received
    Given the payment request is not yet remote_application_received

    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'someresponse' => 'response',
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should not be to verify the notification came from the remote payment application for this payment request

  Scenario: A notification for a payment request that was already completed is received
    Given the payment request was already remote_application_received
    And the payment request was already notification_verified

    When a notification is received for an existent payment request with:
    """
    {
      'payment_request' => {
        'someresponse' => 'response',
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should not be to verify the notification came from the remote payment application for this payment request

  Scenario Outline: A notification is received containing a successful payment response
    Given the mobile number: "Dave's number" <seller_number_verified> verified
    And the mobile number: "Fon's number" <supplier_number_verified> verified
    And the payment request was already remote_application_received
    And a notification was received for an existent payment request with:
    """
    {
      'payment_request' => {
        'payment_response' => {
          'responseEnvelope.timestamp'=>'2010-06-04T09:55:36.507-07:00',
          'responseEnvelope.ack'=>'Success',
          'responseEnvelope.correlationId'=>'1ddf86263c63d',
          'responseEnvelope.build'=>'1310729',
          'payKey'=>'AP-4MV83827NG0173616',
          'paymentExecStatus'=>'COMPLETED'
        },
        'id' => '23'
      }
    }
    """

    Then the most recent job in the queue should be to verify the notification came from the remote payment application for this payment request

    Given the remote payment application for the payment request sent the notification and is currently up

    When the worker works off the job

    Then the job should be deleted from the queue
    And the payment request should be notification_verified
    And the payment request should have a successful_payment
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should <send_seller_message>
    """
    Hi Dave, a payment of 500.00 THB was made to Fon (<supplier_number>) for 1 x 120848121933 (A Rubber Dingy) which belongs to your customer order: #1
    """

    And the most recent outgoing text message destined for the mobile number: "Fon's number" should <send_supplier_message>
    """
    Hi Fon, you have received a payment of 500.00 THB from Dave (<seller_number>) for your product order: #1
    """

    Examples:
     | seller_number_verified | seller_number | supplier_number_verified |supplier_number | send_seller_message | send_supplier_message |
     | was already | +662233445353 | was already | +665323568467 | be | be |
     | was already | +662233445353 | is not yet  | No verified number! | be | not be |
     | is not yet  | No verified number! | was already | +665323568467 | not be | be |
     | is not yet  | No verified number! | is not yet  | No verified number! | not be | not be |

