# nopCommerce Checkout - Address Entry and Shipping Selection
# Feature Area: Billing/Shipping Address, Validation, Shipping Methods
# DeFOSPAM F10, F11 | Business Goal: Ensure accurate order delivery, increase customer confidence

@checkout @critical @smoke
Feature: Checkout Process - Address Entry and Shipping Selection
  As a customer
  I want to enter billing and shipping addresses and select a shipping method
  So that my order is delivered to the correct location with the delivery option I prefer

  Background:
    Given the checkout system is operational
    And address validation rules are configured for multiple countries
    And shipping method options are available and configured
    And the checkout session persists across steps

  @checkout @address @happy-path @smoke
  Scenario: Enter Valid Billing Address - Domestic
    Given a customer is on the Billing Address checkout step
    When the customer provides a valid billing address
      | field        | value                  |
      | firstName    | John                   |
      | lastName     | Doe                    |
      | email        | john@example.com       |
      | country      | United States          |
      | state        | California             |
      | city         | San Francisco          |
      | address      | 123 Main Street        |
      | zipCode      | 94105                  |
    And the customer submits the billing address
    Then the billing address is validated for completeness and format rules
    And the billing address is persisted
    And checkout proceeds to the shipping address step

  @checkout @address @happy-path @regression
  Scenario Outline: Enter Valid Billing Address - International
    Given a customer is on the Billing Address checkout step
    When the customer provides a valid address for <country>
      | field        | value              |
      | firstName    | <firstName>        |
      | lastName     | <lastName>         |
      | email        | <email>            |
      | country      | <country>          |
      | state        | <state>            |
      | city         | <city>             |
      | address      | <address>          |
      | zipCode      | <postalCode>       |
    And the customer submits the address
    Then the address is validated for country-specific format rules
    And the address is persisted
      | country | firstName | lastName  | city    | postalCode |
      | France  | Marie     | Dupont    | Paris   | 75000      |
      | Germany | Hans      | Mueller   | Berlin  | 10115      |
      | Canada  | James     | Smith     | Toronto | M5H 2N2    |

  @checkout @address @negative @regression
  Scenario: Submit Incomplete Billing Address
    Given a customer is on the Billing Address checkout step
    When the customer submits an incomplete billing address missing required fields
      | firstName | lastName | country       | city | zipCode |
      | John      | (empty)  | United States | (empty) | (empty) |
    Then the submission is rejected
    And validation errors are indicated for missing fields
      | field     | error              |
      | lastName  | Field is required  |
      | city      | Field is required  |
      | zipCode   | Field is required  |
    And the customer retains the opportunity to correct and resubmit

  @checkout @address @negative @regression
  Scenario: Submit Invalid Email Format
    Given a customer is on the Billing Address checkout step
    When the customer submits a billing address with invalid email
      | email           |
      | invalid-email   |
    Then email validation fails
    And the customer is notified of the invalid format
    And the form does not submit

  @checkout @address @happy-path @regression
  Scenario: Use Same Address for Billing and Shipping
    Given a customer has entered a valid billing address
    When the customer selects "Ship to same address as billing"
    Then the shipping address is automatically populated with billing address values
    And the customer is advanced to the shipping method selection step
    And no additional address entry is required

  @checkout @address @happy-path @regression
  Scenario: Enter Different Shipping Address
    Given a customer has entered a valid billing address
    When the customer selects "Use different shipping address"
    And provides a shipping address
      | field        | value                  |
      | firstName    | John                   |
      | lastName     | Doe                    |
      | country      | United States          |
      | state        | Texas                  |
      | city         | Austin                 |
      | address      | 456 Oak Avenue         |
      | zipCode      | 78701                  |
    And submits the shipping address
    Then the shipping address is validated for completeness and format
    And the shipping address is persisted separately from billing
    And checkout proceeds to shipping method selection

  @checkout @address @negative @regression
  Scenario: Submit Shipping Address with Invalid Zip Code Format
    Given a customer is entering a shipping address for United States
    When the customer enters a zip code with invalid format
      | zipCode      |
      | ABC12        |
    Then zip code validation fails
    And the customer is notified of the required format (5 or 9 digits)
    And the form does not submit

  @checkout @shipping @happy-path @smoke
  Scenario: Select Shipping Method with Cost Display
    Given a customer has completed address entry
    And is on the Shipping Method selection step
    When the customer views available shipping options
    Then the shipping methods are displayed with:
      | attribute              |
      | Method name            |
      | Estimated delivery     |
      | Associated cost        |
    And the customer selects a shipping method
      | method       | cost   |
      | Ground       | $9.99  |
    Then the shipping method is persisted in the order
    And the order total is updated to reflect the shipping cost

  @checkout @shipping @happy-path @regression
  Scenario Outline: Select Various Shipping Methods
    Given a customer is on the Shipping Method selection step
    When the customer selects <shippingMethod>
    Then the method is applied to the order
    And the order total is updated with <shippingCost>
    And the estimated delivery timeline is displayed
      | shippingMethod | shippingCost | deliveryDays   |
      | Ground         | $9.99        | 5-7 business   |
      | 2-Day Air      | $19.99       | 2 business     |
      | Next Day Air   | $29.99       | 1 business     |
      | Overnight      | $49.99       | 1 business     |

  @checkout @shipping @negative @regression
  Scenario: Proceed Without Selecting Shipping Method
    Given a customer is on the Shipping Method selection step
    When the customer attempts to continue without selecting a method
    Then the action is blocked
    And the customer is notified that shipping method selection is required
    And the customer is prompted to select a method before proceeding

  @checkout @shipping @happy-path @regression
  Scenario: Shipping Method Updates Order Total Dynamically
    Given a customer has selected a default shipping method costing $9.99
    When the customer changes the shipping method
      | from    | to                    |
      | Ground  | Next Day Air          |
    Then the order total is recalculated
    And the new shipping cost $29.99 is reflected
    And the updated grand total is displayed immediately

  @checkout @address @happy-path @regression
  Scenario: Navigation Between Checkout Steps
    Given a customer is on the Shipping Method step
    When the customer clicks the "Back" button
    Then the customer is returned to the Address Entry step
    And all previously entered data is retained
    And the customer can modify the address and proceed again

  @checkout @address @regression
  Scenario: Address Validation for Restricted Shipping Regions
    Given a customer selects a country with shipping restrictions
      | country |
      | Cuba    |
    When the customer completes the address entry
    Then the system validates shipping availability for the address
    And if shipping is not available, appropriate message is displayed
    And checkout cannot proceed until a valid address is entered

  @checkout @shipping @happy-path @regression
  Scenario: Shipping Cost Calculation Includes Tax
    Given a customer has selected a shipping method
    When the order total is calculated
    Then the shipping cost is included in the subtotal calculation
    And tax is calculated on the subtotal including shipping
    And the order summary clearly shows the calculation breakdown
      | item         | amount    |
      | Subtotal     | $100.00   |
      | Shipping     | $9.99     |
      | Subtotal w/s | $109.99   |
      | Tax          | $8.79     |
      | Grand Total  | $118.78   |
