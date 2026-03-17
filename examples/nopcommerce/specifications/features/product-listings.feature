@feature-product-listings @DeFOSPAM @req008
Feature: Product Listings
  As a customer
  I want to evaluate products quickly
  So that I can evaluate products rapidly on the homepage

  @smoke @product-display @homepage @ux
  Scenario: User views product information in categorized sections
    Given A user is on the homepage
    When The product listings load
    Then Product information is displayed including images, descriptions, and pricing
    And Products are organized by category

  @regression @product-display @resilience @error-handling
  Scenario: System gracefully handles missing product images
    Given A product image is unavailable
    When The product listing is displayed
    Then A placeholder is shown in place of the missing image
    And All other product information remains accessible

  @data-driven @examples
  Scenario Outline: Product Listings with various inputs
    Given User is on homepage with product listings section loaded
    When Page renders product listings
    Then System displays 24 featured products across 4 categorized sections: Electronics (6 products), Computers (6), Apparel (6), Books (6)

    Examples:
      | total_products_displayed | category_sections | products_per_category | product_1_name | product_1_price | product_1_currency | product_1_stock | display_fields |
      | 24 | 4 | 6 | Sony WH-1000XM5 Headphones | 299.99 | USD | In Stock | ['image', 'name', 'price', 'currency', 'stock_status'] |
