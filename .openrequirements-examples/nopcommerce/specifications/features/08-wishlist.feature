# nopCommerce Wishlist Management
# Feature Area: Wishlist CRUD, Sharing, Integration with Cart
# DeFOSPAM F03 | Business Goal: Increase engagement and drive future sales

@wishlist @critical @regression
Feature: Wishlist Management
  As a customer
  I want to save products to a wishlist, manage items, and share my preferences
  So that I can organize products of interest and share my preferences with others

  Background:
    Given the wishlist system is operational
    And wishlist functionality requires user registration
    And wishlists are persistent across sessions
    And wishlist sharing is enabled

  @wishlist @add @happy-path @regression
  Scenario: Add Product to Wishlist
    Given a registered customer is viewing a product
    When the customer clicks "Add to Wishlist"
    Then the product is added to the customer's wishlist
    And the customer is notified of the successful addition
    And the wishlist item count is updated

  @wishlist @add @happy-path @regression
  Scenario: Add Product with Selected Attributes to Wishlist
    Given a registered customer is viewing a product with attributes
    When the customer selects attribute values
      | attribute | value |
      | Color     | Blue  |
      | Size      | Large |
    And clicks "Add to Wishlist"
    Then the product variant with selected attributes is added to wishlist
    And the variant details are preserved in the wishlist

  @wishlist @view @happy-path @regression
  Scenario: View Wishlist Contents
    Given a customer is logged in
    When the customer navigates to their wishlist
    Then the wishlist page displays all wishlist items with:
      | detail        |
      | Product name  |
      | Product image |
      | Price         |
      | SKU           |
      | Quantity      |
      | Date added    |
      | Actions       |

  @wishlist @view @happy-path @regression
  Scenario: View Empty Wishlist
    Given a customer with no items in their wishlist
    When the customer navigates to their wishlist
    Then an empty wishlist message is displayed
    And the customer is prompted to start adding products
    And a link to browse products is provided

  @wishlist @update @happy-path @regression
  Scenario: Update Wishlist Item Quantity
    Given a customer has items in their wishlist
    When the customer updates the quantity of a wishlist item
      | from | to |
      | 1    | 3  |
    Then the quantity is updated in the wishlist
    And the wishlist is persisted with the new quantity

  @wishlist @remove @happy-path @regression
  Scenario: Remove Item from Wishlist
    Given a customer has items in their wishlist
    When the customer removes a product from the wishlist
    Then the item is removed from the wishlist
    And the wishlist item count is updated
    And the customer is notified of the removal

  @wishlist @clear @happy-path @regression
  Scenario: Clear Entire Wishlist
    Given a customer has multiple items in their wishlist
    When the customer selects "Clear Wishlist"
    And confirms the action
    Then all items are removed from the wishlist
    And the wishlist is now empty
    And the customer is notified of the action

  @wishlist @cart-integration @happy-path @regression
  Scenario: Move Product from Wishlist to Cart
    Given a customer has items in their wishlist
    When the customer selects "Add to Cart" for a wishlist item
    Then the product is added to the shopping cart
    And the product remains in the wishlist
    And the customer can proceed to checkout or continue shopping

  @wishlist @cart-integration @happy-path @regression
  Scenario: Move Product from Wishlist to Cart with Quantity
    Given a customer has a wishlist item with quantity 3
    When the customer moves the item to cart
    Then the product is added to cart with the same quantity
    And the item remains in the wishlist

  @wishlist @share @happy-path @regression
  Scenario: Share Wishlist via URL
    Given a customer has created a wishlist with items
    When the customer selects "Share Wishlist"
    Then a unique shareable URL is generated
    And the customer can copy or email the URL
    And the URL points to a public wishlist view

  @wishlist @share @happy-path @regression
  Scenario: Access Shared Wishlist as Guest
    Given a customer has shared their wishlist URL
    When another person accesses the shared wishlist URL
    Then the wishlist is displayed in read-only mode showing:
      | item      |
      | Products  |
      | Prices    |
      | Images    |
      | Quantities |
    And the guest can add items from the wishlist to their own cart
    And the guest can create an account or continue as guest

  @wishlist @share @happy-path @regression
  Scenario: Email Wishlist to Friend
    Given a customer has items in their wishlist
    When the customer selects "Email Wishlist"
    And provides recipient email address
      | field      | value              |
      | recipient  | friend@example.com |
      | message    | Check out my items |
    And submits the email
    Then an email is sent to the recipient with:
      | content             |
      | Wishlist items      |
      | Product links       |
      | Personalized message |

  @wishlist @permissions @negative @regression
  Scenario: Attempt to Access Another Customer's Private Wishlist
    Given a customer's wishlist is set to private
    When another customer attempts to access the private wishlist URL
    Then the access is denied
    And a "Not Found" or "Access Denied" message is displayed

  @wishlist @permissions @happy-path @regression
  Scenario: Toggle Wishlist Privacy Settings
    Given a customer has created a wishlist
    When the customer changes the wishlist privacy setting
      | from    | to      |
      | Private | Public  |
    Then the wishlist can be shared with others
    And the privacy setting is updated

  @wishlist @notifications @happy-path @regression
  Scenario: Receive Price Drop Notification for Wishlist Item
    Given a customer has an item in their wishlist
    And the customer has opted in to price notifications
    When the item's price is reduced
    Then the customer receives a notification
    And the notification includes:
      | information     |
      | Product name    |
      | Old price       |
      | New price       |
      | Savings amount  |
      | Product link    |

  @wishlist @collaboration @happy-path @regression
  Scenario: Add Wishlist Items as Gift Registry
    Given a customer is creating a gift registry wishlist
    When the customer adds products to the registry
    And marks items as purchased when bought
    Then the registry status is updated
    And other users can see which items have been purchased
    And the registry serves as a collaborative gift list

  @wishlist @organization @happy-path @regression
  Scenario: Organize Wishlist with Categories or Folders
    Given a customer has multiple items in their wishlist
    When the customer organizes items into categories
      | category |
      | Personal |
      | Home     |
      | Work     |
    Then items are grouped by category
    And the customer can view and manage items by category
