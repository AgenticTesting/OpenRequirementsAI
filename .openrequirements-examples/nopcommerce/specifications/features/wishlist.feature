@feature-wishlist-feature @DeFOSPAM @req003
Feature: Wishlist Feature
  As a logged-in customer
  I want to curate products for future consideration
  So that I can save products for future purchase and engagement

  Background:
    Given the system is operational
    And product listings are available for viewing

  @regression @wishlist @user-features @happy-path
  Scenario: Authenticated user preserves product for future consideration
    Given An authenticated user is viewing product details
    When The user initiates a wishlist action
    Then The product is added to the user's wishlist
    And A confirmation message is displayed

  @regression @wishlist @authentication-boundary @security
  Scenario: Unauthenticated user cannot access wishlist functionality
    Given An unauthenticated user is viewing product details
    When The user attempts to initiate a wishlist action
    Then The system requires authentication
    And The user is directed to the authentication gateway
