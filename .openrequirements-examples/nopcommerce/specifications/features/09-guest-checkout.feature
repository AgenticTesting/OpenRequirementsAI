# nopCommerce Guest Checkout and Currency Selection
# Feature Area: Guest Checkout Flow, Unregistered Purchases, Currency Support
# DeFOSPAM F15, F01 | Business Goal: Reduce friction for first-time buyers, international transactions

@guest-checkout @critical @regression
Feature: Guest Checkout and Currency Selection
  As a guest customer
  I want to complete a purchase without creating an account
  So that I can quickly check out without registration friction

  Background:
    Given guest checkout is enabled in system configuration
    And currency conversion is operational
    And guest checkout flow is properly configured

  @guest @happy-path @smoke
  Scenario: Complete Purchase as Guest Without Account Creation
    Given a guest customer has items in the shopping cart
    When the customer chooses to checkout as guest
    Then the checkout process bypasses login/registration
    And proceeds directly to the billing address step
    And the customer completes checkout by entering:
      | step                | requirement           |
      | Billing Address     | Valid address         |
      | Shipping Address    | Valid address         |
      | Shipping Method     | Selection required    |
      | Payment Method      | Payment information   |
    And the order is created without requiring account registration

  @guest @happy-path @regression
  Scenario: Guest Cannot Access Account Features During Checkout
    Given a guest customer is in the checkout process
    When the guest completes their purchase
    Then the following account features are NOT available:
      | feature        |
      | Wishlist       |
      | Saved addresses|
      | Order history  |
      | Reward points  |
    And the guest receives order confirmation via email
    And the guest can track order using order number and email

  @guest @email @happy-path @regression
  Scenario: Guest Order Confirmation and Tracking
    Given a guest customer has completed an order
    When the order is successfully created
    Then an order confirmation email is sent to the guest email
    And the email includes:
      | content           |
      | Order number      |
      | Order details     |
      | Tracking number   |
      | Shipment ETA      |
    And the guest can use order number and email to track the order

  @guest @conversion @happy-path @regression
  Scenario: Offer Guest to Create Account After Purchase
    Given a guest customer has successfully completed an order
    When the customer receives the order confirmation
    Then the system offers the option to create an account
    And the offer includes benefits of registration:
      | benefit             |
      | Order history view  |
      | Wishlist creation   |
      | Faster checkout     |
      | Exclusive rewards   |
    And the customer can create an account or decline

  @guest @negative @regression
  Scenario: Guest Checkout with Address Validation Required
    Given a guest customer is entering billing address
    When the customer enters invalid address information
    Then address validation fails
    And the customer is notified of validation errors
    And the customer must correct the address before proceeding

  @currency @happy-path @smoke
  Scenario: Select and Display Preferred Currency
    Given a customer is on the store homepage
    When the customer selects their preferred currency
      | currency |
      | EUR      |
    Then all prices are displayed in the selected currency
    And exchange rates are applied for price conversion
    And the currency selection is persisted in the session

  @currency @happy-path @regression
  Scenario Outline: Currency Selection and Display
    Given a customer selects a currency
    When the customer views product prices
    Then prices are converted and displayed in the selected currency
    And the conversion uses current exchange rates
      | baseCurrency | selectedCurrency | basePrice | convertedPrice |
      | USD          | EUR              | $100.00   | €95.00         |
      | USD          | GBP              | $100.00   | £79.00         |
      | USD          | JPY              | $100.00   | ¥15,000        |

  @currency @happy-path @regression
  Scenario: Currency Persists Through Checkout
    Given a customer has selected a currency
    When the customer proceeds through checkout
    Then all prices remain in the selected currency
    And the order confirmation displays prices in the chosen currency
    And the order is processed in the selected currency

  @currency @cart @happy-path @regression
  Scenario: Update Cart Totals When Currency Changes
    Given a customer has items in cart in USD
    When the customer switches to a different currency
      | from | to  |
      | USD  | EUR |
    Then all cart item prices are converted
    And the cart subtotal is recalculated
    And the customer is notified of the currency change

  @currency @negative @regression
  Scenario: Invalid Currency Selection Handling
    Given a customer attempts to select an unsupported currency
    When an invalid currency is selected
    Then the system rejects the invalid selection
    And the system falls back to a default currency
    And the customer is notified of the fallback

  @currency @display @happy-path @regression
  Scenario: Currency Symbol Display Consistency
    Given a customer has selected a currency
    When the customer views product prices and cart totals
    Then the currency symbol is displayed consistently
      | currency | symbol   |
      | USD      | $        |
      | EUR      | €        |
      | GBP      | £        |
      | JPY      | ¥        |
    And the currency code is also displayed where appropriate

  @currency @decimal @happy-path @regression
  Scenario: Decimal Place Handling by Currency
    Given prices are converted to different currencies
    When the prices are displayed
    Then the decimal places match currency standards:
      | currency | decimalPlaces |
      | USD      | 2             |
      | EUR      | 2             |
      | JPY      | 0             |
      | GBP      | 2             |

  @guest @account-optional @happy-path @regression
  Scenario: Guest Checkout with Optional Newsletter Subscription
    Given a guest customer is checking out
    When the customer reaches the checkout process
    Then an optional newsletter signup is presented
    And the customer can opt-in to marketing communications
    And the customer is informed of how their email will be used
    And the newsletter preference is recorded with the order

  @guest @security @happy-path @regression
  Scenario: Guest Email Verification (Optional)
    Given a guest customer enters their email during checkout
    When email verification is enabled in system settings
    Then an email verification step may be required
    And the guest confirms their email address
    And the verified email is used for order confirmation and tracking
