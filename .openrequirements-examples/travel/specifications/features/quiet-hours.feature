@quiet-hours @timing @major
Feature: Quiet Hours and Service-Critical Exemptions
  As a respectful notification system
  I want to enforce locale-specific quiet hours while allowing critical service notifications to bypass restrictions
  So that passengers are not disturbed during sleep hours unless the situation is urgent

  Background:
    Given the notification dispatch engine is running
    And quiet hours configuration is loaded per locale
    And service-critical classification rules are enabled

  @happy-path @smoke
  Scenario: Non-critical notification deferred during quiet hours
    Given a Case C42891 for passenger in US/Eastern timezone
    And quiet hours configured: 22:00-06:00 UTC (midnight-6am ET daily)
    And current time: 2026-03-19T23:30:00Z (11:30 PM ET, within quiet hours)
    And disruption: DELAY 30 minutes (Minor severity, NOT CANCELLATION)
    When dispatch is attempted at 23:30 UTC
    Then dispatch evaluation checks:
      | check              | result                       |
      | current_time       | 23:30 UTC (within quiet_hours)|
      | event_type         | DELAY (not CANCELLATION)     |
      | severity           | Minor (not Critical)         |
      | exemption_applies? | NO (not service-critical)    |
    And dispatch is DEFERRED until quiet hours end (06:00 UTC)
    And notification is queued for dispatch at 06:00 UTC (6 AM ET)
    And audit_log records: "Deferred to quiet hours end: notification queued for 2026-03-20T06:00:00Z"
    And passenger does NOT receive SMS at 23:30 UTC

  @happy-path
  Scenario: CANCELLATION event bypasses quiet hours and dispatches immediately
    Given a Case C42893 for passenger in US/Eastern timezone
    And quiet hours: 22:00-06:00 UTC
    And current time: 2026-03-19T23:45:00Z (within quiet hours)
    And disruption: CANCELLATION (event_type=CANCELLATION)
    And severity: Major
    When dispatch is attempted at 23:45 UTC
    Then dispatch evaluation checks:
      | check              | result                       |
      | event_type         | CANCELLATION                 |
      | exemption_applies? | YES (CANCELLATION always bypasses) |
    And dispatch proceeds immediately (NOT deferred)
    And notification is sent at 23:45 UTC
    And audit_log records: "Quiet hours bypassed: CANCELLATION event (service-critical)"
    And passenger receives notification despite quiet hours

  @happy-path
  Scenario: Critical severity notification bypasses quiet hours
    Given a Case C42895 for passenger in US/Pacific timezone
    And quiet hours: 22:00-06:00 UTC (3 PM - 11 PM PT)
    And current time: 2026-03-19T20:30:00Z (1:30 PM PT, within quiet hours)
    And disruption: DELAY 180 minutes
    And severity: Critical (delay > 3 hours)
    When dispatch is attempted
    Then dispatch evaluation checks:
      | check              | result                       |
      | event_type         | DELAY (not CANCELLATION)     |
      | severity           | Critical                     |
      | exemption_applies? | YES (Critical severity bypasses) |
    And dispatch proceeds immediately (NOT deferred)
    And notification is sent at 20:30 UTC
    And audit_log records: "Quiet hours bypassed: Critical severity case"
    And passenger receives urgent notification

  @edge-case
  Scenario: Notification at quiet hours boundary - exactly at end time
    Given quiet hours: 22:00-06:00 UTC
    And current time: 2026-03-20T06:00:00Z (exactly at quiet hours end)
    And disruption: DELAY 30 minutes (Minor)
    When dispatch is attempted at exactly 06:00 UTC
    Then quiet hours check: is_within_quiet_hours(06:00, [22:00-06:00])
    And the boundary condition: time >= 06:00 (no longer within quiet hours)
    And dispatch proceeds immediately (not deferred)
    And quiet hours enforcement is strict at boundaries

  @edge-case
  Scenario: Notification at quiet hours boundary - just before end time
    Given quiet hours: 22:00-06:00 UTC
    And current time: 2026-03-20T05:59:59Z (one second before end)
    And disruption: DELAY 30 minutes (Minor)
    When dispatch is attempted at 05:59:59 UTC
    Then time is still within quiet hours (before 06:00)
    And dispatch is deferred until 06:00 UTC (1 second deferral)
    And audit_log records deferral decision

  @regression
  Scenario Outline: Quiet hours enforcement matrix across severity and event types
    Given current_time within quiet_hours [22:00-06:00 UTC]
    And disruption with:
      | event_type    | <event_type>  |
      | severity      | <severity>    |
    When dispatch is evaluated
    Then dispatch:
      | action            | <expected_action> |

    Examples:
      | event_type    | severity  | expected_action |
      | DELAY         | Minor     | deferred        |
      | DELAY         | Major     | deferred        |
      | DELAY         | Critical  | immediate       |
      | CANCELLATION  | Major     | immediate       |
      | CANCELLATION  | Critical  | immediate       |
      | GATE_CHANGE   | Minor     | deferred        |

  @critical @audit
  Scenario: Locale-specific quiet hours configuration
    Given multiple locale configurations:
      | locale      | quiet_hours        | timezone     |
      | US/Eastern  | 22:00-06:00 UTC    | America/NY   |
      | US/Pacific  | 22:00-06:00 UTC    | America/LA   |
      | Europe/London | 22:00-06:00 UTC   | Europe/London|
      | Asia/Tokyo  | 22:00-06:00 UTC    | Asia/Tokyo   |
    When a Case in each locale is evaluated
    Then each locale's quiet_hours are applied correctly
    And times are converted to local timezone for comparison
    And deferral is calculated relative to local quiet hours end time

  @critical @audit
  Scenario: Quiet hours deferral queues notification for precise delivery
    Given a notification deferred due to quiet hours
    And deferral_time: 2026-03-19T23:30:00Z
    And quiet_hours_end: 2026-03-20T06:00:00Z
    When deferral is scheduled
    Then the notification is queued with:
      | field              | value                        |
      | case_id            | C42891                       |
      | deferred_until     | 2026-03-20T06:00:00Z         |
      | status             | queued_for_quiet_hours       |
      | reason             | quiet_hours_enforcement      |
    And at 06:00 UTC, the notification is automatically dispatched
    And audit_log records both deferral and subsequent dispatch
    And passenger receives notification exactly at quiet hours end (not before)

  @audit
  Scenario: Quiet hours bypass audit trail captures exemption reason
    Given a CANCELLATION notification dispatched at 2026-03-19T23:45:00Z
    When dispatch occurs during quiet hours
    Then audit_log records:
      | field              | value                        |
      | case_id            | C42893                       |
      | dispatch_timestamp | 2026-03-19T23:45:00Z         |
      | within_quiet_hours | true                         |
      | event_type         | CANCELLATION                 |
      | exemption_reason   | "CANCELLATION events bypass quiet hours" |
      | dispatch_allowed   | true                         |
    And audit entry proves business justification for exemption
    And exemption is auditable for compliance review
