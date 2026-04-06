# nopCommerce Shopping Cart Management
# Feature Area: Add to Cart, Update Quantities, Discounts, Cart Persistence
# DeFOSPAM F04 | Business Goal: Reduce checkout abandonment and increase order accuracy

@shopping-cart @critical @smoke
Feature: Shopping Cart Management
  As a customer
  I want to add products to my cart, modify quantities, apply discounts, and review items before checkout
  So that I can control my purchase and ensure accuracy before payment

  Background:
    Given the shopping cart system is operational
    And the cart persists during the customer's session
    And quantity constraints are enforced based on inventory availability
    And coupon validation rules are configured in the system

  @cart @happy-path @smoke
  Scenario: Add Product with Available Quantity to Cart
    Given a customer has selected a product with available quantity
    When the customer adds the product to the shopping cart
      | quantity | 2 |
    Then the shopping cart contains the product with the requested quantity
    And the cart item total reflects the product price multiplied by quantity
    And the cart persists in the session

  @cart @happy-path @regression
  Scenario Outline: Add Multiple Products to Cart
    Given a customer is viewing the product catalog
    When the customer adds multiple products to the cart
      | productName           | SKU                | quantity | price    |
      | Samsung 32" Monitor   | SAMSUNG_MON32      | 1        | $299.99  |
      | USB Cable 2m          | CABLE_USB_2M       | 3        | $12.99   |
      | Wireless Mouse        | MOUSE_WIRELESS     | 2        | $24.99   |
    Then the shopping cart displays all three products
    And the cart item count shows 3 distinct items with total quantity 6
    And the cart subtotal is calculated correctly
      | product1Total | product2Total | product3Total | cartSubtotal |
      | $299.99       | $38.97        | $49.98        | $388.94      |

  @cart @happy-path @regression
  Scenario: Update Cart Item Quantity
    Given a customer has added a product to the cart
    When the customer updates the product quantity
      | from | to |
      | 1    | 3  |
    Then the cart item quantity reflects the new value
    And the cart item total is recalculated
    And the cart subtotal is updated

  @cart @negative @regression
  Scenario: Update Cart Quantity Beyond Available Stock
    Given a customer has added a product to the cart
    And the product has limited inventory available
    When the customer attempts to update the quantity to exceed available stock
      | currentQuantity | attemptedQuantity | availableStock |
      | 2               | 8                 | 5              |
    Then the update is rejected
    And the customer is informed of the maximum available quantity constraint
    And the quantity remains unchanged at the previous value

  @cart @happy-path @regression
  Scenario: Remove Item from Cart
    Given a customer has added multiple items to the cart
    When the customer removes a product from the cart
    Then the item is removed from the shopping cart
    And the cart subtotal is recalculated
    And the cart item count is updated

  @cart @happy-path @regression
  Scenario: Apply Valid Coupon Code
    Given a customer has items in the shopping cart
    And a valid coupon code exists that is applicable to the cart
    When the customer redeems the coupon code
      | couponCode | discount  |
      | SAVE20     | 20%       |
    Then the coupon discount is applied to the order total
    And the shopping cart order total is reduced by the discount amount
    And the coupon is visibly applied in the order summary

  @cart @happy-path @regression
  Scenario Outline: Apply Coupon with Various Discount Types
    Given a customer has cart subtotal <subtotal>
    And a valid coupon code applies <discountType> discount
    When the customer applies the coupon code <couponCode>
    Then the order total is reduced by the correct amount
      | couponCode | discountType      | subtotal | appliedAmount | finalTotal |
      | PERCENT30  | Percentage (30%)  | $100.00  | $30.00        | $70.00     |
      | FIXED15    | Fixed Amount ($15)| $100.00  | $15.00        | $85.00     |
      | BULK10     | Volume (10% over) | $150.00  | $15.00        | $135.00    |

  @cart @negative @regression
  Scenario: Apply Expired or Invalid Coupon
    Given a customer has items in the shopping cart
    When the customer attempts to redeem an invalid or expired coupon code
      | couponCode | status    |
      | EXPIRED999 | expired   |
    Then coupon validation fails
    And the coupon is not applied to the order
    And the shopping cart order total remains unchanged
    And the customer is notified that the coupon is invalid

  @cart @negative @regression
  Scenario: Apply Coupon with Minimum Order Amount Not Met
    Given a customer has cart subtotal $50.00
    And a coupon requires minimum order amount of $100.00
    When the customer attempts to apply the coupon
    Then the coupon validation fails
    And the system indicates the minimum order requirement
    And the customer is shown how much more they need to spend to qualify

  @cart @happy-path @regression
  Scenario: Apply Gift Card to Cart
    Given a customer has an active gift card with balance $250.00
    And the cart subtotal is $2,609.96
    When the customer applies the gift card code
      | giftCardCode  | balance   |
      | GC_ABC123XYZ  | $250.00   |
    Then the gift card is validated and applied successfully
    And the gift card balance is reserved
    And the order total is reduced by the gift card amount
      | subtotal   | giftCardApplied | newTotal  |
      | $2,609.96  | $250.00         | $2,359.96 |

  @cart @happy-path @regression
  Scenario Outline: Gift Card Partial and Full Redemption
    Given a customer has a gift card with balance <giftCardBalance>
    And the cart total is <orderTotal>
    When the customer applies the gift card
    Then the system calculates the redemption correctly
      | giftCardBalance | orderTotal | appliedAmount | remainingBalance | paymentRequired |
      | $100.00         | $200.00    | $100.00       | $0.00            | $100.00         |
      | $300.00         | $200.00    | $200.00       | $100.00          | $0.00           |

  @cart @negative @regression
  Scenario: Apply Expired Gift Card
    Given a customer has a gift card that has expired
    When the customer attempts to apply the expired gift card
    Then the gift card validation fails
    And the gift card is not applied
    And the customer is notified that the gift card is no longer valid

  @cart @happy-path @regression
  Scenario: View Cart Summary Before Checkout
    Given a customer has items in the shopping cart
    And discounts or gift cards have been applied
    When the customer views the cart summary
    Then the cart displays all items with:
      | detail            |
      | Product name      |
      | SKU               |
      | Quantity          |
      | Unit price        |
      | Line total        |
    And the order summary shows:
      | summaryItem  |
      | Subtotal     |
      | Discounts    |
      | Gift Card    |
      | Shipping     |
      | Tax          |
      | Grand Total  |
    And the Checkout button is enabled for valid cart state

  @cart @negative @regression
  Scenario: Attempt Checkout with Empty Cart
    Given the shopping cart is empty
    When the customer attempts to proceed to checkout
    Then checkout is blocked
    And the customer is notified that the cart is empty
    And the customer is returned to product browsing
