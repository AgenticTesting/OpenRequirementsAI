@feature-product-categories @DeFOSPAM @req006
Feature: Product Categories
  As a customer
  I want to browse by product type
  So that I can browse efficiently by product type

  @smoke @navigation @product-discovery @categorization
  Scenario: User navigates product categories
    Given A user is on the homepage
    When The user accesses the product categories section
    Then The system displays available product categories for navigation

  @smoke @navigation @filtering @happy-path
  Scenario: User selects product category to filter results
    Given A user is viewing available product categories
    When The user selects a specific category
    Then The system displays all products belonging to that category

  @data-driven @examples
  Scenario Outline: Product Categories with various inputs
    Given New user lands on homepage
    When User views the product categories section
    Then System displays 7 main category tiles: Computers (with icon), Electronics, Apparel, Digital Downloads, Books, Jewelry, Gift Cards

    Examples:
      | category_1 | category_1_count | category_2 | category_2_count | category_3 | category_3_count | category_4 | category_5 | category_6 | category_7 |
      | Computers | 342 | Electronics | 1205 | Apparel | 3456 | Digital Downloads | Books | Jewelry | Gift Cards |
