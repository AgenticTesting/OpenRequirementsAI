@feature-currency-selection @DeFOSPAM @req001
Feature: Currency Selection
  As a international customer
  I want to set my preferred currency
  So that I see prices in my preferred currency, reducing purchase friction

  @smoke @currency-selection @user-preference @persistence
  Scenario: User establishes preferred currency
    Given A user accesses the homepage without an established preferred currency
    When The user selects a currency from the available options
    Then The system displays all prices in the selected currency
    And The user's preferred currency persists across subsequent sessions

  @data-driven @examples
  Scenario Outline: Currency Selection with various inputs
    Given A Japanese visitor arrives at the homepage
    When The user selects JPY (Japanese Yen) from currency dropdown
    Then Product prices display in JPY format without decimal places (e.g., 'Apple MacBook Pro 16": ¥399,000') and preference is retained across sessions

    Examples:
      | selected_currency | product_original_price_usd | converted_price_jpy | currency_format |
      | JPY | 3299.0 | 399000 | ¥XXX,XXX |

  @edge-case @validation
  Scenario: EUR selection persists across multiple visits
    Given A user from France has previously selected EUR currency
    When The user returns to the site after 7 days without logging in
    Then Currency preference remains set to EUR on homepage load, prices display in EUR (e.g., '€249.99'), no re-selection needed
    And Persistence mechanism preserves choice via browser cookie or local storage with 1-year expiration
