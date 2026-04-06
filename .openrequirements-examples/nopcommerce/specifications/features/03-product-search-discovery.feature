# nopCommerce Product Search and Discovery
# Feature Area: Keyword Search, Filtering, Sorting, Results Display
# DeFOSPAM F05 | Business Goal: Reduce search friction and increase conversion

@search @critical @smoke
Feature: Product Search and Discovery
  As a customer
  I want to search for products using keywords, apply filters, and sort results
  So that I can quickly find products that meet my needs

  Background:
    Given the search system is operational
    And the product database contains over 10,000 products
    And search indexes are kept current
    And the search engine is configured with default sorting options

  @search @happy-path @smoke
  Scenario: Search Products with Keyword
    Given a customer is on the store homepage
    When the customer enters a search keyword "laptop"
    And the customer executes the search
    Then products matching the search criteria are retrieved and presented
    And the results display product information:
      | detail        |
      | Product image |
      | Product name  |
      | Price         |
      | Rating        |
    And the result count indicates total matching products

  @search @happy-path @regression
  Scenario Outline: Search with Various Keywords
    Given a customer is on the search page
    When the customer searches for <keyword>
    Then matching products are displayed
    And the result count is greater than zero
      | keyword           | expectedMinResults |
      | monitor           | 5                  |
      | wireless keyboard | 3                  |
      | usb               | 15                 |

  @search @happy-path @regression
  Scenario: Search with Filter by Category
    Given a customer has executed a search for "electronics"
    When the customer applies a category filter
      | category     |
      | Computers    |
      | Peripherals  |
    Then the results are filtered to show only products in the selected categories
    And the filter status is displayed to the customer
    And the result count is updated

  @search @happy-path @regression
  Scenario Outline: Search with Multiple Filter Combinations
    Given a customer has executed a search
    When the customer applies multiple filters
      | filterType | values                                      |
      | category   | <category>                                  |
      | price      | <priceRange>                                |
      | brand      | <brand>                                     |
    Then results are filtered to products matching ALL criteria
    And the filter summary shows applied filters
    And the customer can remove individual filters
      | category | priceRange      | brand                                |
      | Monitors | $200-$500       | Dell, ASUS, LG                       |
      | Laptops  | $800-$2000      | Dell, HP, Lenovo                     |

  @search @happy-path @regression
  Scenario: Sort Search Results by Price
    Given a customer has executed a search
    When the customer sorts the results by price
      | sortOrder |
      | Low to High |
    Then the results are reordered with lowest price first
    And each subsequent product has a price greater than or equal to the previous
    And the sort selection is reflected in the UI

  @search @happy-path @regression
  Scenario Outline: Sort Results by Various Criteria
    Given a customer has executed a search with multiple results
    When the customer sorts by <sortCriteria>
    Then results are reordered according to the selected criteria
    And the sorting is applied immediately without page reload
      | sortCriteria | expectedOrder         |
      | Price (Low to High)   | Ascending price       |
      | Price (High to Low)   | Descending price      |
      | Name (A-Z)    | Alphabetical          |
      | Rating (High) | Descending stars      |
      | Newest        | Most recent first     |

  @search @happy-path @regression
  Scenario: Change Results Per Page Display
    Given a customer has executed a search
    When the customer selects to display 24 items per page
    Then the results are reorganized to show 24 products per page
    And pagination controls are updated accordingly
    And the total page count is recalculated

  @search @negative @regression
  Scenario: Search with No Results
    Given a customer enters a search keyword that has no matching products
    When the customer executes the search
    Then a "no results" message is displayed
    And suggested alternatives are offered (did you mean, popular searches)
    And the customer is prompted to refine their search

  @search @happy-path @regression
  Scenario: Search with Autocomplete Suggestions
    Given a customer is on the search page
    When the customer begins typing a keyword
      | typed | laptop |
    Then the system displays autocomplete suggestions
    And suggestions include popular search terms and product names
    And the customer can select a suggestion to execute the search

  @search @negative @regression
  Scenario: Search with Special Characters
    Given a customer enters a search query with special characters
      | query | $400-$600 monitor |
    When the customer executes the search
    Then the system handles special characters appropriately
    And either displays results or provides a helpful error message
    And the search does not result in application errors

  @search @happy-path @regression
  Scenario: Maintain Search State During Pagination
    Given a customer has executed a search with filters applied
    When the customer navigates to page 2 of results
    Then the search query and all filters remain active
    And the URL reflects the current search state
    And the customer can navigate back and forth between pages

  @search @happy-path @regression
  Scenario: Search with Price Range Filter
    Given a customer has executed a search for "monitor"
    When the customer applies a price range filter
      | minPrice | maxPrice |
      | $200     | $500     |
    Then results display only products within the price range
    And each product price is between $200 and $500 inclusive
    And the filter is shown as active

  @search @happy-path @regression
  Scenario: Add Product Directly from Search Results to Cart
    Given a customer is viewing search results
    When the customer adds a product to cart from the search results
    Then the product is added to the shopping cart
    And a confirmation message is displayed
    And the customer can continue searching or proceed to checkout
