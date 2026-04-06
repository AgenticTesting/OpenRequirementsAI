# nopCommerce Order Management and Confirmation
# Feature Area: Order Confirmation, Review, Placement, History
# DeFOSPAM F14, F18 | Business Goal: Reduce returns and increase post-purchase satisfaction

@orders @critical @smoke
Feature: Order Management and Confirmation
  As a customer
  I want to review my order before purchase and access my order history
  So that I can ensure accuracy and monitor my purchases

  Background:
    Given the order system is operational
    And order numbering is unique and sequential
    And order persistence is reliable
    And order status tracking is configured

  @orders @confirmation @happy-path @smoke
  Scenario: Review Complete Order Before Purchase
    Given a customer has completed all checkout steps
    When the customer is on the Order Confirmation/Review step
    Then the system presents a complete order summary for verification
    And the order summary includes:
      | section           |
      | Billing address   |
      | Shipping address  |
      | Shipping method   |
      | Payment method    |
      | Order items       |
      | Order totals      |

  @orders @confirmation @happy-path @regression
  Scenario: Order Confirmation with Item Details Display
    Given a customer is reviewing their order
    When the customer views the order items section
    Then each cart item is displayed with:
      | detail        |
      | Product name  |
      | SKU           |
      | Quantity      |
      | Unit price    |
      | Line total    |
    And all prices are accurate

  @orders @confirmation @happy-path @regression
  Scenario: Order Total Calculation Verification
    Given a customer is reviewing their order
    When the customer examines the order totals
    Then the system displays an itemized breakdown:
      | item          | amount    |
      | Subtotal      | $150.00   |
      | Discounts     | -$30.00   |
      | Subtotal w/d  | $120.00   |
      | Shipping      | $9.99     |
      | Tax           | $9.60     |
      | Grand Total   | $139.59   |
    And the grand total is calculated correctly

  @orders @confirmation @happy-path @regression
  Scenario: Apply Last-Minute Coupon Before Order Confirmation
    Given a customer is reviewing their order
    And the customer remembers an applicable coupon code
    When the customer applies a coupon
    Then the order totals are recalculated
    And the discount is reflected in the order summary
    And the customer can confirm the order with updated totals

  @orders @confirmation @happy-path @regression
  Scenario: Modify Cart During Order Review (Back Navigation)
    Given a customer is on the Order Confirmation step
    When the customer clicks "Back to Cart" to modify items
    Then the customer is returned to the shopping cart
    And all cart items are intact
    And the customer can modify quantities or remove items
    And the customer can return to checkout with updated cart

  @orders @confirmation @negative @regression
  Scenario: Attempt Order Confirmation Without Terms Acceptance
    Given a customer is on the Order Confirmation step
    And the Terms of Service checkbox is unchecked
    When the customer clicks "Place Order"
    Then the order placement is blocked
    And the customer is prompted to accept the Terms of Service
    And the customer can check the box and retry

  @orders @confirmation @happy-path @smoke
  Scenario: Successfully Place Order and Receive Confirmation
    Given a customer has reviewed all order details
    And all information is correct
    When the customer clicks "Confirm Order" or "Place Order"
    Then the system validates the order for completeness and business rule compliance
    And a valid order is created with a unique order identifier
    And the order is persisted in the system
    And the customer is presented with an order confirmation page
    And the confirmation page displays:
      | information        |
      | Order number       |
      | Order date/time    |
      | Order status       |
      | Estimated delivery |

  @orders @confirmation @happy-path @regression
  Scenario: Order Confirmation Email Sent
    Given an order has been successfully created
    When the order confirmation is generated
    Then a confirmation email is sent to the customer's email address
    And the email includes:
      | content             |
      | Order number        |
      | Order items         |
      | Total amount        |
      | Shipping address    |
      | Expected delivery   |
      | Order tracking link |

  @orders @history @happy-path @regression
  Scenario: View Order History
    Given a registered customer has made multiple purchases
    When the customer navigates to their order history
    Then a list of all orders is displayed with:
      | column         |
      | Order number   |
      | Order date     |
      | Order status   |
      | Order total    |
      | Actions button |
    And orders are listed in reverse chronological order

  @orders @history @happy-path @regression
  Scenario Outline: View Individual Order Details
    Given a customer is viewing order history
    When the customer selects an order to view details
    Then the order details page displays comprehensive information:
      | detail                  |
      | Order number            |
      | Order date              |
      | Order status            |
      | Billing address         |
      | Shipping address        |
      | Shipping method         |
      | Payment method          |
      | Items ordered           |
      | Order totals            |
      | Tracking information    |
    And order details include:
      | orderNumber | orderStatus | total    |
      | #1001       | Shipped     | $139.59  |
      | #1000       | Delivered   | $99.99   |

  @orders @history @happy-path @regression
  Scenario: Track Order Status and Shipping Progress
    Given a customer is viewing an active order
    When the customer checks the order status
    Then the current order status is displayed
      | possible_statuses  |
      | Processing         |
      | Shipped            |
      | Delivered          |
    And if applicable, tracking information is provided
      | information       |
      | Carrier name      |
      | Tracking number   |
      | Estimated arrival |

  @orders @history @negative @regression
  Scenario: Attempt to View Another Customer's Order
    Given a logged-in customer
    When the customer attempts to access an order that doesn't belong to them
    Then the system blocks access
    And a "Not Found" or "Unauthorized" error is displayed
    And the customer cannot view another customer's order details

  @orders @confirmation @negative @regression
  Scenario: Handle Order Placement Failure - Inventory Becomes Unavailable
    Given a customer has confirmed the order
    And inventory validation initially passed
    When the system performs final inventory check before order creation
    And an item is no longer available due to concurrent sale
    Then the order placement fails
    And the customer is informed that the item is no longer available
    And the customer is returned to the cart for adjustment

  @orders @confirmation @negative @regression
  Scenario: Handle Order Placement Failure - Payment Declined
    Given a customer has submitted payment information
    When the payment processor declines the transaction
    Then the order placement fails
    And the customer is notified that payment was declined
    And the customer is returned to the payment information step
    And the customer can update payment method and retry

  @orders @confirmation @happy-path @regression
  Scenario: Order Tax Calculation Accuracy
    Given a customer has completed checkout with items from different tax categories
    When the order is confirmed
    Then tax is calculated based on:
      | factor                |
      | Product tax class     |
      | Customer location     |
      | Applicable tax rules  |
    And tax is calculated to 2 decimal places
    And the tax amount is displayed and explained
