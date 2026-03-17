@feature-homepage-banner @DeFOSPAM @req007
Feature: Homepage Banner
  As a website visitor
  I want to view promotional offers
  So that I stay aware of current promotions and featured products

  @smoke @homepage @marketing @promotion
  Scenario: User views promotional offers on homepage
    Given A user arrives at the homepage
    When The page loads
    Then Promotional banners are displayed to highlight current marketing initiatives

  @regression @homepage @promotion @edge-case
  Scenario: System accommodates multiple concurrent promotional campaigns
    Given Multiple promotional campaigns are active
    When The user views the homepage
    Then All promotional banners are displayed without layout issues

  @data-driven @examples
  Scenario Outline: Homepage Banner with various inputs
    Given New visitor arrives at homepage
    When Page loads above product listings
    Then System displays 3 promotional banners in carousel format, rotating every 5 seconds: Banner 1 'Spring Sale - Up to 40% Off Electronics', Banner 2 'New MacBook Pro M4 Launch', Banner 3 'Free Shipping on Orders Over $50'

    Examples:
      | banner_count | display_format | rotation_interval_seconds | banner_1_title | banner_2_title | banner_3_title | elements_per_banner |
      | 3 | carousel | 5 | Spring Sale - Up to 40% Off Electronics | New MacBook Pro M4 Launch | Free Shipping on Orders Over $50 | ['title', 'offer_text', 'learn_more_button', 'product_image'] |

  @edge-case @validation
  Scenario: Multiple promotional banners display without layout break
    Given 5 promotional campaigns are active simultaneously (Spring Sale, Summer Flash, New Arrivals, Clearance, Bundle Deals)
    When Homepage loads with all 5 banners configured
    Then System displays first 3 banners in carousel rotation (5-second intervals), 4th and 5th banners queued for rotation cycle
    And Page layout remains stable, no content jumping or displacement; carousel automatically cycles through all 5 banners
