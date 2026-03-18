@facebook-oauth @DeFOSPAM @critical
Feature: Facebook OAuth Authorization
  As a user
  I want to authorize the app to access my Facebook identity
  So that my identity can be securely verified and linked to my app account

  Background:
    Given the mobile app is installed and the user is on the login screen
    And the user has internet connectivity

  @critical @smoke @happy-path
  Scenario: Facebook OAuth Authorization Redirect
    Given a user is on the login screen without an active session
    When the user initiates Facebook SSO login
    Then the system delegates to Facebook's OAuth authorization flow
    And the user is presented with Facebook's authorization consent screen showing requested permissions

  @critical @error @permission-denied
  Scenario: User Denies Facebook Permission During Authorization
    Given a user is authorizing Facebook SSO and withdraws consent
    When the user denies or cancels Facebook authorization
    Then Facebook SSO login fails and the user is returned to the login screen
    And an error message informs the user that authorization is required and no session is established

  @major @error @token-validation
  Scenario: Facebook Authorization Fails Due to Invalid or Expired Credentials
    Given the user completes Facebook authorization but Facebook returns invalid or expired credentials
    When the system validates the returned Facebook credentials
    Then login fails and the user is returned to the login screen
    And an error message informs the user that Facebook authentication was unsuccessful

  @major @boundary @scope-mismatch
  Scenario: User Grants Limited Permissions - Email Not Accessible
    Given the app requests OAuth scopes for public profile and email
    When the user grants only partial permissions and denies email scope
    Then the app receives the authorization with limited granted scopes
    And the app account may be provisioned without email field if email is required for account creation

  @major @error @configuration
  Scenario: Invalid Redirect URI Configured in Facebook App Settings
    Given the Facebook app is configured with an incorrect redirect URI
    When the user completes the Facebook OAuth authorization
    Then Facebook's redirect to the mobile app fails due to scheme mismatch
    And the user cannot complete login until configuration is corrected

  @critical @error @service-degradation
  Scenario: Facebook Native App Becomes Unresponsive - Fallback Triggered
    Given the user is on Android and the Facebook native app is installed but unresponsive
    When the Facebook SDK timeout is triggered after 10 seconds
    Then the SDK switches from native app deeplink to web-based OAuth fallback
    And the app opens the Facebook OAuth web flow and the user completes authentication successfully

  @major @nfr @performance
  Scenario: OAuth Redirect and Return Completes in Less Than 3 Seconds
    Given a user is on the login screen with a good WiFi connection
    When the user initiates Facebook SSO login
    Then the OAuth flow completes within 3 seconds from initial action
    And the user receives authorization credentials or cancellation feedback
