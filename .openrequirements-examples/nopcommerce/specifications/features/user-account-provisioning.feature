@user-provisioning @DeFOSPAM @critical
Feature: User Account Provisioning via Facebook Identity
  As a new user
  I want to have an app account automatically created from my Facebook identity
  So that I can start using the app immediately without a separate registration step

  Background:
    Given the mobile app is installed and the user is on the login screen
    And the user has internet connectivity
    And the user has a valid Facebook account

  @critical @smoke @provisioning @happy-path
  Scenario: First-Time Facebook SSO Login Creates App Account
    Given a new user with a valid Facebook account has no prior app account
    When the user initiates Facebook SSO login and grants Facebook authorization
    Then a new app account is automatically provisioned and linked to the user's Facebook identity
    And the user authenticates and establishes an active session without explicit registration

  @critical @performance @provisioning
  Scenario: Account Provisioning Completes Within 2 Seconds
    Given a new user initiates Facebook SSO login for the first time
    When Facebook authorization is granted
    Then the account provisioning process completes within 2 seconds
    And the user is presented with the app home screen and onboarding flow

  @major @regression @data-capture
  Scenario: User Profile Data Captured from Facebook
    Given a new user completes Facebook authorization with public profile and email scopes
    When the system creates the user account
    Then the user's name, email, and Facebook ID are captured and stored
    And the account is linked to the Facebook identity with these profile fields

  @critical @edge-case @idempotence
  Scenario: Prevent Duplicate Account Creation on Repeated Login
    Given a user's Facebook account is already linked to an existing app account
    When the user initiates Facebook SSO login with that same Facebook account
    Then the system identifies the existing linked account
    And the user is authenticated to the existing account without creating a duplicate

  @major @boundary @partial-data
  Scenario: Account Creation with Minimal Required Data
    Given a new user completes Facebook authorization but grants only partial permissions
    When required profile fields are unavailable from Facebook
    Then the account is provisioned with available data
    And missing optional fields remain empty and can be updated later

  @major @nfr @first-login-conversion
  Scenario: New User Achieves Feature Access on First Login
    Given a new user completes account provisioning and receives a session
    When the user is presented with the app home screen
    Then the user can access basic app features and initiate the onboarding flow
    And the conversion from first login to feature access occurs within acceptable time

  @major @compliance @data-privacy
  Scenario: User Data Captured from Facebook Complies with GDPR
    Given a new user provisioning flow captures data from Facebook
    When the user later requests data deletion under GDPR Article 17
    Then the app processes the deletion request within 30 days
    And user data is anonymized and accounts are marked inactive

  @minor @regression @field-mapping
  Scenario: Facebook Profile Fields Mapped to App Account Fields
    Given Facebook provides user profile data: ID, name, email, profile picture URL
    When the app creates an account during provisioning
    Then each Facebook field is correctly mapped to corresponding app account fields
    And data types and formats are validated before storage
