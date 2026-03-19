@notification-eligibility @consent @critical
Feature: Notification Eligibility - Consent-Based Channel Selection
  As a compliance-conscious notification system
  I want to evaluate notification eligibility by checking passenger contact consent states
  So that I only send messages through channels where passengers have explicitly opted in

  Background:
    Given a Case has been created successfully
    And the Lead Contact is identified from the booking
    And the consent database is available
    And consent evaluation is enabled

  @happy-path @smoke
  Scenario: SMS channel eligible when contact has SMS opt_in consent
    Given Case C42891 for passenger P8847 (Robert Chen)
    And the Lead Contact phone number is +1-404-555-0127
    And consent_state for SMS channel:
      | field              | value                        |
      | contact_id         | P8847                        |
      | channel            | SMS                          |
      | consent_state      | opt_in                       |
      | captured_at        | 2025-12-01T10:15:00Z         |
      | source             | mobile_app                   |
    When the system evaluates notification eligibility before dispatch
    Then SMS channel is ELIGIBLE for notification
    And dispatch may proceed via SMS
    And consent_state and capture_timestamp are recorded in dispatch audit

  @happy-path
  Scenario: Email channel eligible when contact has email opt_in consent
    Given Case C42892 for passenger P12445 (James Rodriguez)
    And consent_state for EMAIL channel:
      | field              | value                        |
      | contact_id         | P12445                       |
      | channel            | EMAIL                        |
      | consent_state      | opt_in                       |
      | captured_at        | 2025-11-15T14:30:00Z         |
      | source             | web_portal                   |
    When notification eligibility is evaluated
    Then EMAIL channel is ELIGIBLE
    And dispatch may proceed via EMAIL

  @edge-case
  Scenario: SMS channel blocked when contact has not provided consent
    Given Case C42893 for passenger P5923 (Maria Santos)
    And no consent record exists for SMS channel for this contact
    When notification eligibility is evaluated
    Then SMS channel is NOT ELIGIBLE (no opt_in consent)
    And SMS notification is NOT sent
    And audit_log records: "SMS channel blocked: no consent_state found"
    And Case remains open for manual escalation

  @critical @compliance
  Scenario: SMS channel completely blocked when contact has opt_out consent
    Given Case C42892 for passenger P5923 (Maria Santos), booking BK-2026-AA215-0319
    And consent_state for SMS channel:
      | field              | value                        |
      | contact_id         | P5923                        |
      | channel            | SMS                          |
      | consent_state      | opt_out                      |
      | captured_at        | 2026-01-20T14:45:00Z         |
      | source             | web_portal                   |
    When the system evaluates notification eligibility
    Then SMS channel is BLOCKED (consent_state='opt_out')
    And SMS notification is NOT sent
    And audit_log records: "Notification blocked by consent: Case C42892, channel SMS, consent_state opt_out (captured 2026-01-20T14:45:00Z via web_portal)"
    And Case timeline shows status transition to "Notification_Blocked_By_Consent"
    And Case remains open for manual review by support

  @edge-case
  Scenario: Multiple channels - partial eligibility
    Given Case C42894 for passenger P7634 (David Thompson), booking BK-2026-UA1847-0319
    And consent states:
      | channel  | consent_state | captured_at              |
      | SMS      | opt_in        | 2025-12-01T10:15:00Z     |
      | EMAIL    | opt_out       | 2025-10-20T09:30:00Z     |
      | PUSH     | opt_in        | 2026-02-15T16:45:00Z     |
    When notification eligibility is evaluated
    Then SMS channel is ELIGIBLE
    And EMAIL channel is BLOCKED
    And PUSH channel is ELIGIBLE
    And notification may be sent via SMS and/or PUSH, but NOT EMAIL
    And audit_log captures all three channel evaluations

  @critical @compliance
  Scenario: Consent re-verification on each dispatch attempt
    Given Case C42891 has previous SMS opt_in consent on record
    And consent_state has since been updated to opt_out
    When a retry dispatch is attempted
    Then current consent_state is re-evaluated (not cached)
    And the updated opt_out state is honored
    And SMS notification is blocked
    And audit_log records: "Consent re-verified at dispatch time: SMS opt_out (updated since Case creation)"

  @regression
  Scenario Outline: Consent eligibility matrix across channels
    Given Case exists for passenger with following consent states:
      | channel          | consent_state |
      | SMS              | <sms_state>   |
      | EMAIL            | <email_state> |
      | PUSH             | <push_state>  |
    When notification eligibility is evaluated
    Then notification dispatch:
      | channel | eligible     |
      | SMS    | <sms_eligible>|
      | EMAIL  | <email_eligible>|
      | PUSH   | <push_eligible>|

    Examples:
      | sms_state | email_state | push_state | sms_eligible | email_eligible | push_eligible |
      | opt_in    | opt_in      | opt_in     | yes          | yes            | yes           |
      | opt_out   | opt_in      | opt_in     | no           | yes            | yes           |
      | opt_in    | opt_out     | opt_in     | yes          | no             | yes           |
      | (absent)  | opt_in      | opt_out    | no           | yes            | no            |
      | opt_out   | opt_out     | opt_out    | no           | no             | no            |

  @audit @critical
  Scenario: Consent state audit trail
    Given a notification is being dispatched via SMS
    When consent eligibility is evaluated and SMS is confirmed as opt_in
    Then audit_log records:
      | field              | value                        |
      | contact_id         | (passenger ID)               |
      | channel            | SMS                          |
      | consent_state      | opt_in                       |
      | consent_captured   | 2025-12-01T10:15:00Z         |
      | consent_source     | mobile_app                   |
      | evaluated_at       | (dispatch evaluation time)   |
      | eligibility        | ELIGIBLE                     |
    And this audit entry is immutable
    And timestamp proves consent was current at dispatch time

  @compliance
  Scenario: GDPR compliance - opt_in requirement documented
    Given any notification dispatch
    When it occurs
    Then the audit trail proves:
      | principle          | verification                 |
      | opt_in required    | consent_state='opt_in' checked|
      | no implicit consent| missing consent blocks dispatch|
      | opt_out honored    | consent_state='opt_out' blocks|
      | timestamp captured | consent captured_at recorded |
      | source captured    | consent source recorded      |
    And compliance auditor can verify GDPR compliance via audit log
