Feature: Payment Request Verification
  In order to prevent unauthorized payment requests made to my external payment application from being executed
  As a seller
  I want to verify that the payment request was made by this application

  Background:
    Given a seller exists with email: "mara@example.com"
    And a supplier exists with email: "johnny@example.com"
    And a verified payment application exists with seller: the seller
    When a payment is created with seller: the seller, supplier: the supplier, cents: "500000", currency: "THB"
    Then a payment request should exist with payment_id: the payment

  Scenario Outline: Verification request is received with correct parameters
    Given the payment request <was_notified> notified
    And the payment request <notification_was_verified> notification_verified
    When a verification request is received for <existence> payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '5000.00',
        'currencyCode' => 'THB',
        'receiverList.receiver(0).email' => 'johnny@example.com',
        'senderEmail' => 'mara@example.com'
      },
      'payee' => {
        'email' => 'johnny@example.com',
        'amount' => '5000.00',
        'currency' => 'THB'}
      }
    """
    Then the response should be <status_code>

    Examples:
      | was_notified | notification_was_verified | status_code | existence     |
      | is not yet   | is not yet                | 200         | an existent   |
      | was already  | is not yet                | 200         | an existent   |
      | was already  | was already               | 404         | an existent   |
      | is not yet   | is not yet                | 404         | a nonexistent |

  Scenario Outline: Verification request is received for an existent payment request with an incorrect parameters
    When a verification request is received for an existent payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '<amount>',
        'currencyCode' => '<currency>',
        'receiverList.receiver(0).email' => '<receiver>',
        'senderEmail' => '<sender>'
      },
      'payee' => {
        'email' => '<receiver>',
        'amount' => '<amount>',
        'currency' => '<currency>'
      }
    }
    """
    Then the response should be 404

    Examples:
      | amount  | currency | receiver            | sender            |
      | 5000.01 | THB      | johnny@example.com  | mara@example.com  |
      | 5000.00 | USD      | johnny@example.com  | mara@example.com  |
      | 5000.00 | THB      | johnny1@example.com | mara@example.com  |
      | 5000.00 | THB      | johnny@example.com  | mara1@example.com |

