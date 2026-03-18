@feature-search-functionality @DeFOSPAM @req005
Feature: Search Functionality
  As a customer
  I want to discover products efficiently
  So that I find products quickly without excessive navigation

  @smoke @search @discovery @ux-feature
  Scenario: User discovers products via search with dynamic suggestions
    Given A user is on the platform and searches for products
    When The user enters a search query
    Then The system provides autocomplete suggestions based on matching products
    And Suggestions include related search patterns

  @regression @search @validation @edge-case
  Scenario: System handles search with no matching products
    Given A user has submitted a search query
    When No products match the query criteria
    Then The system communicates that no matches were found
    And Alternative search options are suggested

  @data-driven @examples
  Scenario Outline: Search Functionality with various inputs
    Given User types 'air' in search bar (3 characters minimum)
    When User sees autocomplete suggestions: 'AirPods Pro', 'AirPods Max', 'AirTag', 'Air Fryer Oven'
    Then User clicks 'AirPods Pro' suggestion and sees 4 product results (all AirPods Pro variants in different colors)

    Examples:
      | search_input | input_length | suggestion_1 | suggestion_2 | suggestion_3 | suggestion_4 | click_suggestion | results_count |
      | air | 3 | AirPods Pro | AirPods Max | AirTag | Air Fryer Oven | AirPods Pro | 4 |

  @edge-case @validation
  Scenario: User searches for non-existent product
    Given User searches for 'vintage typewriter model XYZ9999' which doesn't exist in catalog
    When User presses Enter to submit search
    Then System displays 'No products found for "vintage typewriter model XYZ9999"' with suggestions: 'Did you mean: typewriter?' and category recommendations showing Computers, Electronics, Books
    And User can refine search or browse suggested categories
