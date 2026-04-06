# nopCommerce Checkout - Payment Selection and Information
# Feature Area: Payment Methods, Card Entry, Security, PCI Compliance
# DeFOSPAM F12, F13 | Business Goal: Enable secure payment and reduce fraud risk

@checkout @payment @critical @smoke
Feature: Checkout Process - Payment Method Selection and Information
  As a customer
  I want to select a payment method and securely enter payment information
  So that I can complete the transaction with confidence

  Background:
    Given the payment system is operational
    And payment processors are integrated and configured
    And payment methods are available and tested
    And PCI-DSS compliance controls are in place
    And HTTPS/TLS encryption is enforced for payment data

  @checkout @payment @happy-path @smoke
  Scenario: Select Credit Card as Payment Method
    Given a customer has completed address and shipping selection
    And is on the Payment Method selection step
    When the customer views available payment methods
    Then payment methods are displayed with descriptions
      | method          |
      | Credit Card     |
      | Debit Card      |
      | PayPal          |
    And the customer selects "Credit Card"
    Then the payment method is persisted in the order
    And checkout proceeds to payment information entry

  @checkout @payment @happy-path @regression
  Scenario Outline: Select Various Payment Methods
    Given a customer is on the Payment Method selection step
    When the customer selects <paymentMethod>
    Then the payment method is persisted
    And the appropriate payment form is displayed
    And checkout can proceed to the next step
      | paymentMethod      |
      | Credit Card        |
      | PayPal             |
      | Bank Transfer      |
      | Check/Money Order  |

  @checkout @payment @negative @regression
  Scenario: Proceed Without Selecting Payment Method
    Given a customer is on the Payment Method selection step
    When the customer attempts to continue without selecting a method
    Then the action is blocked
    And the customer is notified that payment method selection is required

  @checkout @payment @happy-path @smoke
  Scenario: Enter Valid Credit Card Information
    Given a customer has selected credit card as payment method
    When the customer provides valid credit card details
      | field              | value              |
      | cardType           | Visa               |
      | cardholderName     | John Doe           |
      | cardNumber         | 4532123456789010   |
      | expirationMonth    | 12                 |
      | expirationYear     | 2027               |
      | cvv                | 123                |
    And the customer submits the payment form
    Then the system validates the payment information against security and format rules
    And valid payment information is encrypted and prepared for authorization
    And plaintext card data is not persisted to the system

  @checkout @payment @happy-path @regression
  Scenario Outline: Validate Card Number Formats
    Given a customer is entering credit card information
    When the customer enters a valid card number for <cardType>
    Then the card type is automatically detected or confirmed
    And the card number passes validation
    And the system accepts the card for processing
      | cardType        | sampleNumber       |
      | Visa            | 4532123456789010   |
      | Mastercard      | 5425233010103442   |
      | American Express| 374245455400126    |

  @checkout @payment @negative @regression
  Scenario: Enter Invalid Credit Card Number
    Given a customer is entering credit card information
    When the customer enters an invalid card number
      | cardNumber      |
      | 4532123456789999|
    Then the card number validation fails
    And the customer is notified of the validation failure
    And the form submission is blocked
    And the customer can correct the card number and retry

  @checkout @payment @negative @regression
  Scenario: Enter Expired Card
    Given a customer is entering credit card information
    When the customer enters a card with expiration date in the past
      | expirationMonth | expirationYear |
      | 6               | 2020           |
    Then expiration date validation fails
    And the customer is notified that the card is expired
    And the form does not submit

  @checkout @payment @negative @regression
  Scenario: Enter Invalid CVV
    Given a customer is entering credit card information
    When the customer enters an invalid CVV
      | cardType        | cvv   |
      | Visa            | 1     |
    Then CVV validation fails for the card type
    And the customer is notified of the invalid format
    And the form does not submit

  @checkout @payment @negative @regression
  Scenario: Submit Payment Form with Missing Required Fields
    Given a customer is entering credit card information
    When the customer submits the form with missing fields
      | field              |
      | cardholderName     |
      | cardNumber         |
      | cvv                |
    Then the submission is rejected
    And validation errors are indicated for each missing field
    And the customer can complete the fields and resubmit

  @checkout @payment @happy-path @regression
  Scenario: Secure Card Data Handling - No Plaintext Storage
    Given a customer has submitted valid credit card information
    When the payment processor receives the card data
    Then the system validates that:
      | validation                           |
      | Card number is NOT stored in logs    |
      | Card number is NOT stored in DB      |
      | CVV is transmitted to processor ONLY |
      | Payment token is stored, not card    |
      | All payment data is encrypted        |

  @checkout @payment @happy-path @regression
  Scenario: Payment Processing with Encryption in Transit
    Given a customer is on the payment information page
    When the customer is transmitting card data
    Then the transmission is protected by:
      | security_measure            |
      | HTTPS/TLS 1.2 encryption    |
      | Strong cipher suites        |
      | Certificate validation      |
      | No mixed content (HTTP)     |

  @checkout @payment @happy-path @regression
  Scenario: Payment Method Verification Before Order Confirmation
    Given a customer has entered payment information
    When the customer advances to the Order Confirmation step
    Then the payment method is displayed for verification
      | detail          |
      | Payment method  |
      | Last 4 digits   |
      | Cardholder name |
    And the customer can proceed to place the order with confidence

  @checkout @payment @negative @regression
  Scenario: Reuse Previously Saved Payment Method
    Given a registered customer has stored a payment method from a previous order
    When the customer selects "Use saved payment method"
    Then the stored payment method is applied
    And the customer is not required to re-enter card details
    And the payment can proceed with the stored method

  @checkout @payment @happy-path @regression
  Scenario: Save Payment Method for Future Use
    Given a customer is entering new payment information
    When the customer checks "Save this card for future purchases"
    And submits the payment form
    Then the payment method is securely stored for future use
    And the payment proceeds with the current transaction
    And the customer can reuse this payment method in future orders

  @checkout @payment @regression
  Scenario: Payment Processing Timeout Handling
    Given a customer has submitted payment information
    When the payment processor takes longer than expected to respond
    Then the system implements a timeout mechanism
    And if no response is received within the timeout window, the transaction is rolled back
    And the customer is notified of the timeout
    And the customer can retry the payment
