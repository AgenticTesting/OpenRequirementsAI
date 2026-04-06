# nopCommerce Product Catalog Navigation and Display
# Feature Area: Categories, Manufacturers, Product Details, Reviews
# DeFOSPAM F06, F07, F19 | Business Goal: Simplify navigation and provide purchase confidence

@catalog @critical @regression
Feature: Product Catalog Navigation and Display
  As a customer
  I want to browse products by category and manufacturer, view detailed product information, and read reviews
  So that I can easily find items and make informed purchasing decisions

  Background:
    Given the product catalog contains thousands of products
    And category hierarchy is properly configured
    And manufacturer data is synchronized
    And product images and descriptions are complete
    And review system is operational

  @catalog @categories @happy-path @regression
  Scenario: Browse Products by Category
    Given a customer is on the store homepage
    When the customer selects a product category
      | category |
      | Electronics |
    Then the category page displays all products in that category
    And subcategories are available for drilling down
    And the product count is displayed
    And product filtering options are available

  @catalog @categories @happy-path @regression
  Scenario Outline: Navigate Category Hierarchy
    Given a customer is browsing product categories
    When the customer navigates the category hierarchy
      | path                           |
      | Electronics > Computers        |
      | Electronics > Peripherals      |
      | Apparel > Men > Shirts         |
    Then the appropriate subcategory page is displayed
    And breadcrumb navigation shows the current path
    And the customer can navigate back up the hierarchy
    And products in the selected category are displayed

  @catalog @manufacturers @happy-path @regression
  Scenario: Filter Products by Manufacturer
    Given a customer is viewing products in a category
    When the customer applies a manufacturer filter
      | manufacturer |
      | Dell         |
      | ASUS         |
      | LG           |
    Then the product list is filtered to show only products from selected manufacturers
    And the filter is displayed as active
    And the customer can remove the filter

  @catalog @details @happy-path @regression
  Scenario: View Comprehensive Product Details
    Given a customer is viewing a product page
    Then the product page displays:
      | element                    |
      | Product name               |
      | SKU                        |
      | Price                      |
      | Availability status        |
      | Product description        |
      | Product images/gallery     |
      | Specification attributes   |
      | Related products           |
      | Customer reviews/ratings   |
      | Add to cart button         |
      | Add to wishlist button     |

  @catalog @details @happy-path @regression
  Scenario: View Product Specification Attributes
    Given a customer is viewing a product with multiple specifications
      | product           | specifications                       |
      | Laptop            | CPU, RAM, Storage, Display, Weight  |
      | Monitor           | Size, Resolution, Panel Type, Refresh Rate |
    When the customer views the specifications section
    Then the specifications are displayed in a structured table format
    And each specification includes the attribute name and value
    And specifications are clearly readable and well-organized

  @catalog @details @happy-path @regression
  Scenario: View Product Images and Gallery
    Given a customer is viewing a product with multiple images
    When the customer views the product image gallery
    Then the main product image is displayed
    And thumbnail images are available for selection
    And the customer can click thumbnails to change the main image
    And image zoom functionality is available

  @catalog @details @happy-path @regression
  Scenario: View Related and Cross-Sell Products
    Given a customer is viewing a product detail page
    When the customer views the related products section
    Then related products are displayed with:
      | information |
      | Product name |
      | Price        |
      | Image        |
      | Rating       |
    And the customer can add related products to cart directly

  @catalog @breadcrumbs @happy-path @regression
  Scenario: Navigate Using Breadcrumb Navigation
    Given a customer is viewing a product
    When the customer views the breadcrumb navigation
    Then the breadcrumb path is displayed showing hierarchy
      | path                    |
      | Home > Electronics > Computers > Laptops |
    And each breadcrumb element is clickable
    And the customer can click any breadcrumb to navigate back

  @catalog @reviews @happy-path @regression
  Scenario: View Product Reviews and Ratings
    Given a customer is viewing a product with customer reviews
    When the customer views the reviews section
    Then the following information is displayed:
      | information          |
      | Overall rating (1-5) |
      | Number of reviews    |
      | Rating distribution  |
      | Individual reviews   |

  @catalog @reviews @happy-path @regression
  Scenario Outline: View Individual Product Reviews
    Given a customer is viewing product reviews
    When the customer examines individual reviews
    Then each review displays:
      | element        |
      | Reviewer name  |
      | Review date    |
      | Star rating    |
      | Review title   |
      | Review text    |
      | Helpful votes  |
    And reviews can be sorted or filtered
      | sortOption    |
      | Most Recent   |
      | Most Helpful  |
      | Highest Rating |
      | Lowest Rating  |

  @catalog @reviews @happy-path @regression
  Scenario: Submit a Product Review
    Given a customer has purchased a product
    When the customer navigates to the product page and selects "Write a Review"
    And provides review information
      | field       | value                    |
      | title       | Great product!           |
      | rating      | 5 stars                  |
      | reviewText  | Excellent quality...     |
    And submits the review
    Then the review is submitted for moderation or posted immediately
    And the customer is notified of the submission
    And the review appears on the product page (after moderation if applicable)

  @catalog @reviews @negative @regression
  Scenario: Prevent Duplicate Product Reviews
    Given a customer has already submitted a review for a product
    When the customer attempts to submit another review for the same product
    Then the system prevents the duplicate submission
    And the customer is notified that they have already reviewed this product
    And the customer is offered the option to edit their existing review

  @catalog @details @happy-path @regression
  Scenario: Select Product Attributes and Variants
    Given a customer is viewing a product with attributes (size, color, etc.)
    When the customer selects attribute values
      | attribute | value  |
      | Color     | Black  |
      | Size      | Medium |
    Then the SKU and price are updated based on selected attributes
    And the updated information reflects the chosen variant
    And the customer can add the variant to cart

  @catalog @details @negative @regression
  Scenario: Attempt to Add Out-of-Stock Product to Cart
    Given a customer is viewing an out-of-stock product
    When the customer attempts to add the product to cart
    Then the action is blocked
    And the customer is notified that the product is out of stock
    And the customer is offered options to:
      | option                  |
      | Notify when back in stock |
      | View similar products   |

  @catalog @compare @happy-path @regression
  Scenario: Compare Multiple Products
    Given a customer has selected multiple products for comparison
    When the customer initiates the product comparison
    Then a comparison table is displayed with:
      | column              |
      | Product name        |
      | Price               |
      | Key attributes      |
      | Specification details |
      | Rating              |
    And the customer can add compared products to cart directly

  @catalog @details @happy-path @regression
  Scenario: View Inventory and Availability Status
    Given a customer is viewing a product
    When the customer checks product availability
    Then one of the following statuses is displayed:
      | status                        |
      | In Stock - Ships in 1-2 days |
      | Limited Quantity Available    |
      | Out of Stock - Backorder Available |
      | Discontinued                  |
    And the availability is clearly visible to the customer
