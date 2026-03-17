@feature-learn-more-button @DeFOSPAM @req009
Feature: Learn More Button
  As a customer
  I want to access detailed product information
  So that I can quickly access comprehensive product information

  @smoke @navigation @promotion @happy-path
  Scenario: User accesses detailed product page via promotional banner
    Given A user is viewing a promotional banner
    When The user initiates the Learn More action
    Then The system navigates to the detailed product page

  @regression @error-handling @resilience @edge-case
  Scenario: System handles unavailable product page gracefully
    Given A promotional banner references a product that is no longer available
    When The user initiates the Learn More action
    Then The system detects the missing product
    And The user is directed to an alternative location

  @data-driven @examples
  Scenario Outline: Learn More Button with various inputs
    Given User viewing 'New MacBook Pro M4 Launch' promotional banner on homepage
    When User clicks 'Learn More' button on banner
    Then System navigates to MacBook Pro 16 (M4) product detail page showing full specs, pricing ($3,499), customer reviews, related products

    Examples:
      | banner_title | button_label | destination_page | destination_product | product_price | page_load_time_seconds | available_actions |
      | New MacBook Pro M4 Launch | Learn More | product_detail | MacBook Pro 16 (M4) | 3499.0 | 2 | ['add_to_cart', 'add_to_wishlist', 'view_reviews', 'check_related'] |
