@feature-online-documentation @DeFOSPAM @req010
Feature: Online Documentation
  As a user
  I want to find answers and learn the platform
  So that I can resolve questions independently and learn the platform

  Background:
    Given the system is operational
    And documentation resources are accessible

  @smoke @help @support @documentation
  Scenario: User accesses help resources
    Given A user is on the platform
    When The user accesses the help resources link
    Then The system displays documentation including guides and FAQs

  @regression @help @search @documentation
  Scenario: User discovers answers within documentation
    Given A user is viewing the documentation
    When The user searches for relevant topics
    Then The system displays matching guides and FAQs

  @data-driven @examples
  Scenario Outline: Online Documentation with various inputs
    Given New user just registered account and is unfamiliar with platform
    When User clicks 'Getting Started Guide' from documentation hub
    Then System displays step-by-step guide with sections: Create Account (completed), Set Currency Preference, Browse Categories, Add Items to Wishlist, Use Search Function, Manage Cart, View Orders

    Examples:
      | guide_title | step_1 | step_1_status | step_2 | step_3 | step_4 | step_5 | step_6 | step_7 | content_includes |
      | Getting Started Guide | Create Account | completed | Set Currency Preference | Browse Categories | Add Items to Wishlist | Use Search Function | Manage Cart | View Orders | ['video_tutorials', 'screenshots', 'clickable_navigation'] |
