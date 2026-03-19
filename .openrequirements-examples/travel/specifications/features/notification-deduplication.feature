@notification-deduplication @idempotency @critical
Feature: Idempotent Notification Deduplication
  As the notification system
  I want to deduplicate notifications using idempotency keys based on Case + channel + template
  So that duplicate disruption signals never result in duplicate notifications to passengers

  Background:
    Given the notification dispatch engine is running
    And the deduplication store is available
    And idempotency keys are computed per Case + channel + template_version

  @happy-path @smoke
  Scenario: Suppress duplicate notification via idempotency key match
    Given Case C42891 for passenger Robert Chen (P8847), booking BK-2026-DL427-0319
    And initial SMS notification dispatched at 2026-03-19T14:48:15Z:
      | field              | value                        |
      | case_id            | C42891                       |
      | channel            | SMS                          |
      | template_name      | DELAY_SINGLE_LEG_SMS_v2      |
      | idempotency_key    | C42891+SMS+DELAY_SINGLE_LEG_SMS_v2 |
      | dispatch_status    | delivered at 2026-03-19T14:49:30Z |
    And idempotency_key is stored in dispatch_history
    When a duplicate disruption event (same service DL427, same date) is received at 2026-03-19T14:52:30Z
    And the event correlates to the same Case C42891
    And dispatch is attempted a second time
    Then deduplication check finds matching idempotency_key in dispatch_history
    And SMS notification is NOT queued (suppressed by idempotency)
    And audit_log records: "Idempotency match: C42891+SMS+DELAY_SINGLE_LEG_SMS_v2 - duplicate suppressed at 2026-03-19T14:52:37Z"
    And passenger Robert Chen receives exactly one SMS (not two)

  @happy-path
  Scenario: Allow different channels to dispatch for same Case
    Given Case C42891 eligible for both SMS and EMAIL
    And initial SMS dispatched with idempotency_key: "C42891+SMS+DELAY_SINGLE_LEG_SMS_v2"
    And stored in deduplication table
    When email dispatch is attempted for same Case
    Then email has different idempotency_key: "C42891+EMAIL+DELAY_SINGLE_LEG_EMAIL_v2"
    And key does NOT match SMS key (different channel)
    And EMAIL dispatch is allowed (not suppressed)
    And email notification is delivered to james@email.com
    And both SMS and EMAIL are sent (different channels, different idempotency keys)

  @happy-path
  Scenario: Allow different templates for same Case and channel
    Given Case C42891 with SMS channel
    And initial SMS sent with template version 1:
      | field              | value                        |
      | template_name      | DELAY_SINGLE_LEG_SMS_v1      |
      | idempotency_key    | C42891+SMS+DELAY_SINGLE_LEG_SMS_v1 |
    And template is upgraded to version 2
    When a new dispatch attempt is made with updated template:
      | field              | value                        |
      | template_name      | DELAY_SINGLE_LEG_SMS_v2      |
      | idempotency_key    | C42891+SMS+DELAY_SINGLE_LEG_SMS_v2 |
    Then idempotency_key differs (different template_version)
    And key does NOT match v1 key
    And SMS dispatch is allowed (not suppressed)
    And new SMS is sent with updated template content

  @edge-case
  Scenario: Idempotency key exactly composed of Case + channel + template_version
    Given Case C42891
    When idempotency key is composed
    Then it is computed as: "C42891+SMS+DELAY_SINGLE_LEG_SMS_v2"
    And the composition is deterministic (same inputs always produce same key)
    And key includes:
      | component          | value                        |
      | case_id            | C42891                       |
      | channel            | SMS                          |
      | template_id        | DELAY_SINGLE_LEG_SMS        |
      | template_version   | v2                           |
    And no other fields are included in key composition

  @critical
  Scenario: Deduplication check happens before any outbound call
    Given Case C42891 ready for dispatch
    And idempotency_key "C42891+SMS+DELAY_SINGLE_LEG_SMS_v2" already exists in dispatch_history
    When dispatch is attempted
    Then BEFORE calling SMS provider:
      | step               | action                       |
      | 1. Compute key     | Generate idempotency_key     |
      | 2. Check store     | Query dispatch_history       |
      | 3. Key found       | Return "duplicate_suppressed" |
      | 4. Exit            | Do NOT call provider         |
    And provider call is never made
    And audit_log records suppression (no provider attempt)

  @error-case
  Scenario: Deduplication check fails when store is unavailable
    Given Case C42891 ready for dispatch
    And idempotency_key is computed: "C42891+SMS+DELAY_SINGLE_LEG_SMS_v2"
    When the deduplication store becomes unavailable
    And dispatch is attempted
    Then deduplication check fails with error "Store unavailable"
    And dispatch is blocked (fail-safe: assume possible duplicate)
    And error_log records: "Deduplication check failed - store unavailable"
    And dispatch is queued for retry with backoff

  @regression
  Scenario Outline: Idempotency keys prevent re-dispatch in various scenarios
    Given Case "<case_id>" with initial dispatch
    And idempotency_key "<key>"
    When duplicate event or retry is processed
    Then deduplication check:
      | check              | result                       |
      | Compute key        | "<key>" (deterministic)      |
      | Query store        | Found in dispatch_history    |
      | Match result       | Duplicate suppressed         |

    Examples:
      | case_id | key                              |
      | C42891  | C42891+SMS+DELAY_SINGLE_LEG_SMS_v2|
      | C42893  | C42893+EMAIL+CANCELLATION_EMAIL_v2|
      | C42895  | C42895+PUSH+DELAY_PUSH_v1        |

  @critical @audit
  Scenario: Case timeline records duplicate suppression attempt
    Given Case C42891 with initial dispatch suppressed by idempotency
    When the duplicate suppression occurs
    Then Case.timeline appends entry:
      | field              | value                        |
      | timestamp          | 2026-03-19T14:52:37Z         |
      | event_type         | NOTIFICATION_SUPPRESSED_DUPLICATE |
      | event_details      | idempotency_key=C42891+SMS+..., channel=SMS |
      | reason             | duplicate_idempotency_match  |
    And timeline entry is immutable
    And idempotency state is auditable via timeline

  @audit
  Scenario: Exactly-once delivery verification
    Given Case C42891 with:
      | field              | value                        |
      | dispatch_count     | 1 (recorded)                 |
      | idempotency_key    | C42891+SMS+DELAY_SINGLE_LEG_SMS_v2 |
      | first_dispatch_at  | 2026-03-19T14:48:15Z         |
      | first_delivery_at  | 2026-03-19T14:49:30Z         |
    When audit trail is inspected
    Then:
      | claim              | verification                 |
      | Exactly once       | dispatch_count=1 (in DB)     |
      | Idempotency works  | Key prevents re-dispatch     |
      | No duplicates sent | Passenger confirms 1 SMS     |
      | Audit trail proves | Timeline shows suppression of 2nd attempt |
    And audit provides proof of exactly-once delivery semantics
