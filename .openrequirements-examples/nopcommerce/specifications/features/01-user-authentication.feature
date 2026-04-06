# nopCommerce User Authentication System
# Feature Area: User Registration, Login, Password Recovery, Account Security
# DeFOSPAM F02 | Business Goal: Establish secure customer authentication

@authentication @critical @smoke
Feature: User Authentication System
  As a customer
  I want to register for an account, log in securely, and recover my password
  So that I can maintain a persistent account with personalized features

  Background:
    Given the authentication system is operational
    And password complexity rules are enforced: minimum 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special character
    And the system tracks failed authentication attempts per account
    And accounts lock after configurable failed attempt threshold

  @authentication @happy-path @regression
  Scenario: Happy Path - Register with Valid Credentials
    Given a customer is on the registration page
    When the customer provides valid credentials
      | field             | value              |
      | firstName         | John               |
      | lastName          | Doe                |
      | email             | john@example.com   |
      | password          | SecurePass123!     |
      | passwordConfirm   | SecurePass123!     |
    And the customer submits the registration form
    Then the account is created and persisted in the system
    And the customer is authenticated in the current session
    And the customer gains access to registered customer features
      | feature       |
      | Wishlist      |
      | Order History |
      | Account Profile |

  @authentication @happy-path @regression
  Scenario Outline: Register with Various Valid Password Formats
    Given a customer is on the registration page
    When the customer provides valid credentials with password <password>
      | field       | value          |
      | firstName   | Jane           |
      | lastName    | Smith          |
      | email       | <email>        |
      | password    | <password>     |
    And the customer submits the registration form
    Then the account is created
    And the customer is authenticated

    Examples:
      | email                    | password           |
      | jane1@example.com        | MyPass@123         |
      | jane2@example.com        | Complex$Pass99     |
      | jane3@example.com        | Secure#2024Word    |

  @authentication @negative @regression
  Scenario: Registration with Invalid Email Format
    Given a customer is on the registration page
    When the customer provides invalid email format
      | field             | value              |
      | firstName         | John               |
      | lastName          | Doe                |
      | email             | invalid-email      |
      | password          | SecurePass123!     |
    And the customer submits the registration form
    Then the registration is rejected
    And the customer is notified of the validation error
    And the customer can correct the email and resubmit

  @authentication @negative @regression
  Scenario: Registration with Weak Password
    Given a customer is on the registration page
    When the customer provides a password that fails complexity requirements
      | password      |
      | weak123       |
    Then the registration is rejected
    And the customer is informed of password requirements
    And the password field indicates the specific failure
      | requirement       | status     |
      | Minimum 8 chars   | PASS       |
      | 1 uppercase       | FAIL       |
      | 1 lowercase       | PASS       |
      | 1 digit           | PASS       |
      | 1 special char    | FAIL       |

  @authentication @negative @regression
  Scenario: Login with Invalid Credentials
    Given a registered customer exists with email john@example.com
    When another user enters invalid credentials
      | field       | value              |
      | email       | john@example.com   |
      | password    | WrongPassword123!  |
    And the user attempts to authenticate
    Then authentication is rejected
    And the system does not reveal which field was invalid
    And a generic error message is displayed

  @authentication @negative @regression
  Scenario: Account Lockout After Failed Attempts
    Given a registered customer exists with email alice@example.com
    When the customer provides invalid credentials and attempts to authenticate 5 times
    Then the account enters a temporary locked state
    And subsequent login attempts are rejected with lockout message
    And the account remains locked for the configurable duration
    And the customer can request a password reset to regain access

  @authentication @happy-path @regression
  Scenario: Password Recovery Flow
    Given a registered customer has lost access to their account
    And the customer has registered email address jane@example.com
    When the customer requests password recovery
    Then the system sends a password recovery email containing a time-limited reset token
    And the recovery email is sent to the registered address
    And the reset token is valid for the configured duration

  @authentication @happy-path @regression
  Scenario: Reset Password with Valid Token
    Given a customer has received a password recovery email
    And the recovery token is valid and not expired
    When the customer uses the reset token to set a new password
      | oldPassword    | SecurePass123!      |
      | newPassword    | NewSecure456!       |
    Then the password is updated
    And the customer can resume authentication with the new password
    And the old password no longer works

  @authentication @negative @regression
  Scenario: Password Reset with Expired Token
    Given a customer has received a password recovery email
    And the recovery token has expired
    When the customer attempts to use the expired token
    Then the reset is rejected
    And the customer is notified that the token has expired
    And the customer can request a new recovery email

  @authentication @negative @regression
  Scenario: Login with Correct Email, Wrong Password, After Account Lock
    Given a customer's account is locked due to failed attempts
    When the customer attempts to login with correct email and correct password
    Then authentication is rejected
    And the system displays the lockout message
    And the customer is advised to use password recovery
