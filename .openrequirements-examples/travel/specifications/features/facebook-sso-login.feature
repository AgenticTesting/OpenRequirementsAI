@facebook-sso @DeFOSPAM @critical
Feature: Facebook SSO Login
  As a user
  I want to authenticate using my Facebook account
  So that I can quickly access the app without creating separate credentials

  Background:
    Given the mobile app is installed and the user is on the login screen
    And the user has internet connectivity
    And the user has a valid Facebook account

  @critical @smoke @returning-user
  Scenario: Successful Facebook SSO Login - Returning User
    Given a registered user with a Facebook account linked to their app account
    When the user initiates Facebook SSO login and grants Facebook authorization
    Then the user authenticates successfully and establishes an active session
    And the user is presented with the app home screen

  @critical @new-user @provisioning
  Scenario: First-Time Facebook SSO Login - New User Account Provisioning
    Given a user with a valid Facebook account has not previously linked to the app
    When the user initiates Facebook SSO login and grants Facebook authorization
    Then a new app account is automatically provisioned and linked to the user's Facebook identity
    And the user authenticates and establishes an active session without explicit registration

  @major @boundary @fallback
  Scenario: Facebook SSO Login Without Facebook App Installed - Web Fallback
    Given a user without the Facebook native app installed initiates Facebook SSO login
    When the user grants Facebook authorization via the web-based OAuth flow
    Then the system uses the Facebook web-based OAuth fallback
    And the user authenticates successfully and establishes a session

  @critical @error @connectivity
  Scenario: Login Attempt with No Internet Connectivity
    Given the user is on the login screen with no internet connectivity
    When the user initiates Facebook SSO login
    Then the system detects the network failure and displays an error message
    And no session is established and the login screen remains active

  @major @boundary @edge-case
  Scenario: Facebook Account Linked to Multiple App Accounts - Prevent Duplicates
    Given a user's Facebook account is already linked to an existing app account
    When the user initiates Facebook SSO login with that Facebook account
    Then the system identifies the linked app account and authenticates the user to that account
    And no new account is created

  @major @performance @nfr
  Scenario: Login Performance Within 5 Seconds
    Given a user is on the login screen on a 3G network
    When the user initiates Facebook SSO login and grants authorization
    Then the entire authentication sequence completes within 5 seconds
    And the user is presented with the app home screen

  @major @regression @ios
  Scenario: Facebook SSO Login on iOS with Native App Installed
    Given a user on an iOS device with the Facebook app installed initiates Facebook SSO login
    When the user grants Facebook authorization
    Then the user authenticates successfully via the native Facebook integration
    And the user is presented with the app home screen

  @major @regression @android
  Scenario: Facebook SSO Login on Android with Native App Installed
    Given a user on an Android device with the Facebook app installed initiates Facebook SSO login
    When the user grants Facebook authorization
    Then the user authenticates successfully via the native Facebook integration
    And the user is presented with the app home screen
