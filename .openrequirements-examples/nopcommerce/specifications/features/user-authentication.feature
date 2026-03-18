@feature-user-authentication @DeFOSPAM @req002
Feature: User Authentication
  As a new or returning user
  I want to authenticate securely to my account
  So that my account is secure and my data is protected

  Background:
    Given the system is operational
    And the registration and login interfaces are accessible

  @regression @authentication @registration @happy-path
  Scenario: New user successfully registers
    Given A new user has access to the registration page
    When The user provides valid credentials and confirms registration
    Then The system establishes a secure user account
    And A confirmation message is displayed to the user

  @smoke @authentication @login @happy-path
  Scenario: Existing user authenticates with valid credentials
    Given A registered user is attempting to authenticate
    When The user provides valid credentials
    Then The system authenticates the user
    And The user gains access to their account

  @regression @authentication @login @negative-case @security
  Scenario: User authentication fails with invalid credentials
    Given A registered user is attempting to authenticate
    When The user provides invalid credentials
    Then The system rejects the authentication request
    And An error message is displayed

  @data-driven @examples
  Scenario Outline: User Authentication with various inputs
    Given New user arrives at registration page
    When User enters email 'sarah.johnson@example.com', password 'SecurePass123!', confirms password, and submits
    Then System creates account, displays 'Account Created Successfully' message, sends verification email, and redirects to dashboard

    Examples:
      | email | password | password_length | contains_uppercase | contains_number | contains_special_char | success_message |
      | sarah.johnson@example.com | SecurePass123! | 13 | True | True | True | Account Created Successfully |
