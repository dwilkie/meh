Feature: Payment Request Verification
  In order to prevent unauthorized payment requests made to my external payment application from being executed
  As a seller
  I want to verify that the payment request was made by this application

  Background:
    Given a seller exists with email: "mara@gmail.com"
    And a supplier exists with email: "johnny@gmail.com"
    And a verified payment application exists with seller: the seller
    When a payment is created with seller: the seller, supplier: the supplier, cents: "500000", currency: "THB"
    Then a payment request should exist with payment_id: the payment

  Scenario Outline: Verification request is made with correct parameters
    Given the payment request <is_not_yet_or_was_already> notified
    When a verification request is made for <existence> payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '5000.00',
        'currencyCode' => 'THB',
        'receiverList.receiver(0).email' => 'johnny@gmail.com',
        'senderEmail' => 'mara@gmail.com'
      },
      'payee' => {
        'email' => 'johnny@gmail.com',
        'amount' => '5000.00',
        'currency' => 'THB'}
      }
    """
    Then the response should be <status_code>

    Examples:
      | is_not_yet_or_was_already | status_code | existence     |
      | is not yet                | 200         | an existent   |
      | was already               | 404         | an existent   |
      | is not yet                | 404         | a nonexistent |

  Scenario: Verification request is made for correct resource with incorrect amount
    When a verification request is made for an existent payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '5000.01',
        'currencyCode' => 'THB',
        'receiverList.receiver(0).email' => 'johnny@gmail.com',
        'senderEmail' => 'mara@gmail.com'
      },
      'payee' => {
        'email' => 'johnny@gmail.com',
        'amount' => '5000.01',
        'currency' => 'THB'
      }
    }
    """
    Then the response should be 404

  Scenario: Verification request is made for correct resource with incorrect receiver
    When a verification request is made for an existent payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '5000.00',
        'currencyCode' => 'THB',
        'receiverList.receiver(0).email' => 'johnny2@gmail.com',
        'senderEmail' => 'mara@gmail.com'
      },
      'payee' => {
        'email' => 'johnny2@gmail.com',
        'amount' => '5000.00',
        'currency' => 'THB'
      }
    }
    """
    Then the response should be 404

  Scenario: Verification request is made for correct resource with incorrect sender
    When a verification request is made for an existent payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '5000.00',
        'currencyCode' => 'THB',
        'receiverList.receiver(0).email' => 'johnny@gmail.com',
        'senderEmail' => 'mara1@gmail.com'
      },
      'payee' => {
        'email' => 'johnny@gmail.com',
        'amount' => '5000.00',
        'currency' => 'THB'
      }
    }
    """
    Then the response should be 404

  Scenario: Verification request is made for correct resource with incorrect currency
    When a verification request is made for an existent payment request with:
    """
    {
      'payment' => {
        'receiverList.receiver(0).amount' => '5000.00',
        'currencyCode' => 'USD',
        'receiverList.receiver(0).email' => 'johnny@gmail.com',
        'senderEmail' => 'mara@gmail.com'
      },
      'payee' => {
        'email' => 'johnny@gmail.com',
        'amount' => '5000.00',
        'currency' => 'USD'
      }
    }
    """
    Then the response should be 404

