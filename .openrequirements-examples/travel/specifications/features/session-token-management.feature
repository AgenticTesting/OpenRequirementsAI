@session-token @DeFOSPAM @critical
Feature: SSO Session Token Management
  As an authenticated user
  I want my session to persist across app restarts
  So that I can continue using the app without repeatedly logging in

  Background:
    Given the mobile app is installed

  @critical @smoke @persistence
  Scenario: Session Persists After App Restart
    Given a user has an active session from a prior Facebook SSO login
    When the user restarts the mobile app
    Then the session is still valid and the user is restored to the app home screen
    And no re-authentication is required

  @critical @smoke @expiry
  Scenario: Session Expiry Requires Re-Authentication
    Given a user's session has expired
    When the user launches the mobile app
    Then the app requires re-authentication and presents the login screen
    And no protected content is accessible without a valid session

  @critical @security @logout
  Scenario: User Logs Out and Session is Invalidated
    Given a user has an active session from Facebook SSO login
    When the user selects the logout option
    Then the session is invalidated and the user is presented with the login screen
    And subsequent app launches require re-authentication

  @major @boundary @protected-access
  Scenario: Protected Features Inaccessible Without Authentication
    Given a user has no active session
    When the user attempts to access a protected feature
    Then the system redirects to the login screen
    And protected content remains inaccessible

  @major @edge-case @token-refresh
  Scenario: Token Approaches Expiry - Silent Refresh Triggered
    Given a user is logged in with a session token that expires soon
    When the token validation logic detects expiry approaching
    Then the app silently refreshes the token without user interaction
    And the new token is stored and the user continues without re-authentication

  @major @edge-case @concurrency
  Scenario: User Attempts Login While Previous Login Is In Flight
    Given a user initiates a Facebook SSO login with OAuth flow in progress
    When the user taps the login button again before the first login completes
    Then the app prevents duplicate concurrent OAuth invocations
    And only the first OAuth flow completes with a single session token created

  @major @nfr @availability
  Scenario: Session Persistence Remains Valid for 7 Plus Days
    Given a user successfully logs in via Facebook SSO with a 7-day token lifetime
    When the user closes the app and waits 6 days without using it
    Then the session token is still valid when the user reopens the app
    And the user is logged in without re-authenticating

  @major @nfr @security
  Scenario: Session Tokens Stored Using Secure Device Storage
    Given a user has successfully logged in and received a session token
    When the app stores the token for persistence across app restart
    Then the token is stored in secure device storage with encryption
    And the token is accessible only by the app and cleared when appropriate

  @critical @nfr @compatibility
  Scenario: Token Remains Valid After SDK Version Update
    Given a user is logged in with a token issued by a previous SDK version
    When the app is updated to use a new Facebook SDK version
    Then the token remains valid and the user stays logged in
    And backend token validation handles both old and new SDK token formats
