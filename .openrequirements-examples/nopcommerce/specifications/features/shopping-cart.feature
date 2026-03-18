@feature-shopping-cart @DeFOSPAM @req004
Feature: Shopping Cart
  As a customer
  I want to assemble and modify my purchase
  So that I have control over my purchase and can modify selections before checkout

  Background:
    Given the system is operational
    And products are available in inventory

  @smoke @shopping-cart @happy-path @core-feature
  Scenario: User adds product to shopping cart
    Given A user is viewing a product
    When The user specifies a quantity and adds the product to their shopping cart
    Then The product is accumulated in the shopping cart with the specified quantity
    And The cart count is updated

  @regression @shopping-cart @cart-management @happy-path
  Scenario: User modifies product quantity in shopping cart
    Given A user has products accumulated in their shopping cart
    When The user modifies the quantity of a product
    Then The shopping cart updates the product quantity
    And The cart total is recalculated

  @regression @shopping-cart @cart-management @happy-path
  Scenario: User removes product from shopping cart
    Given A user has multiple products accumulated in their shopping cart
    When The user initiates removal of a product
    Then The product is removed from the shopping cart
    And The cart total is recalculated

  @regression @shopping-cart @inventory @validation @negative-case
  Scenario: System prevents adding insufficient inventory
    Given A product has limited inventory availability
    When A user attempts to add a quantity exceeding available inventory
    Then The system rejects the addition
    And An error message explains the inventory constraint

  @data-driven @examples
  Scenario Outline: Shopping Cart with various inputs
    Given User viewing Samsung Galaxy Buds2 Pro ($169.99), cart is empty
    When User selects quantity '2' and clicks 'Add to Cart'
    Then System adds 2 units to cart, displays 'Added 2 items to cart' confirmation, cart icon badge increments to 2, cart total shows $339.98

    Examples:
      | product_name | unit_price | quantity_selected | cart_total | confirmation_message |
      | Samsung Galaxy Buds2 Pro | 169.99 | 2 | 339.98 | Added 2 items to cart |
      | AirPods Pro | 2 | 249.99 | iPhone case | 24.99 |

  @edge-case @validation
  Scenario: Cart persists for non-logged-in user
    Given Guest user adds MacBook Air ($1,199) to cart without logging in, then leaves site
    When Guest returns to site after 15 days from same device/browser
    Then Cart still contains MacBook Air at original price, user can proceed to checkout or continue shopping
    And Cart persists via browser storage (localStorage) for 30 days; after 30 days, cart expires automatically
