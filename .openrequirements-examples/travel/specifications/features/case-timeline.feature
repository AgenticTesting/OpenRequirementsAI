@case-timeline @audit @critical
Feature: Comprehensive Case Timeline Auditing
  As an audit and compliance system
  I want to maintain an immutable, append-only timeline of all Case events
  So that I can trace the complete history of disruption detection, processing, and communication

  Background:
    Given a Case exists and progresses through its lifecycle
    And the append-only timeline engine is running
    And audit logging is enabled

  @happy-path @smoke
  Scenario: Complete timeline for successful disruption flow
    Given a Case C42891 starting at 2026-03-19T14:48:00Z
    When the Case progresses through major events:
      | timestamp            | event_type         | details                  |
      | 14:48:07Z           | CASE_CREATED       | after correlation match_score=0.95 |
      | 14:48:15Z           | NOTIFICATION_COMPOSED | what_changed, new_time, case_ref |
      | 14:48:20Z           | CONSENT_CHECKED    | SMS opt_in verified     |
      | 14:48:22Z           | IDEMPOTENCY_KEY_GENERATED | C42891+SMS+DELAY_SINGLE_LEG_SMS_v2 |
      | 14:48:23Z           | NOTIFICATION_DISPATCHED | SMS provider=Twilio, delivered |
    Then Case.timeline contains immutable entries:
      | timestamp            | event_type         | immutable? |
      | 14:48:07Z           | CASE_CREATED       | yes        |
      | 14:48:15Z           | NOTIFICATION_COMPOSED | yes        |
      | 14:48:20Z           | CONSENT_CHECKED    | yes        |
      | 14:48:22Z           | IDEMPOTENCY_KEY_GENERATED | yes        |
      | 14:48:23Z           | NOTIFICATION_DISPATCHED | yes        |
    And entries are ordered chronologically
    And entries can never be modified or deleted

  @happy-path
  Scenario: Timeline for duplicate suppression event
    Given Case C42891 with initial timeline entry at 14:48:07Z: CASE_CREATED
    And subsequent entry at 14:48:23Z: NOTIFICATION_DISPATCHED
    When a duplicate disruption is received at 14:52:30Z
    And deduplication suppresses the second notification at 14:52:37Z
    Then Case.timeline appends new entry:
      | field              | value                        |
      | timestamp          | 14:52:37Z                   |
      | event_type         | NOTIFICATION_SUPPRESSED_DUPLICATE |
      | event_details      | idempotency_key=C42891+SMS+DELAY_SINGLE_LEG_SMS_v2 |
      | reason             | duplicate_idempotency_match  |
    And timeline now contains 6 entries (not 5)
    And original entries 1-5 remain unchanged (immutable)
    And new entry is appended, not inserted or modified

  @happy-path
  Scenario: Timeline for notification blocked by consent
    Given Case C42892 for Maria Santos with opt_out SMS consent
    When Case is created and progresses:
      | timestamp | event_type         |
      | 15:30:07Z | CASE_CREATED       |
      | 15:30:15Z | NOTIFICATION_COMPOSED |
      | 15:30:20Z | CONSENT_CHECKED    |
    Then consent check finds consent_state='opt_out'
    And Case.timeline appends entry:
      | timestamp            | event_type              |
      | 15:30:22Z           | NOTIFICATION_BLOCKED    |
      | reason               | consent_state=opt_out   |
    And Case status transitions to "Notification_Blocked_By_Consent"
    And Case remains open for manual review

  @critical
  Scenario: Append-only enforcement - entries cannot be modified
    Given Case C42891 with timeline entry at 14:48:07Z:
      | event_type         | CASE_CREATED       |
      | reason             | correlation match_score=0.95 |
    When an attempt is made to modify this entry to:
      | event_type         | CASE_CREATED_REVISED |
      | reason             | different reason   |
    Then the modification is rejected with error "Timeline entry is immutable"
    And original entry remains unchanged:
      | event_type         | CASE_CREATED       |
      | reason             | correlation match_score=0.95 |
    And audit_log records attempted modification

  @critical
  Scenario: Append-only enforcement - entries cannot be deleted
    Given Case C42891 with 5 timeline entries
    When an attempt is made to delete entry 3 (CONSENT_CHECKED)
    Then deletion is rejected with error "Timeline entry cannot be deleted"
    And all 5 entries remain intact
    And Timeline.entry_count = 5 (unchanged)
    And audit_log records attempted deletion

  @critical
  Scenario: Chronological ordering enforcement
    Given Case C42891 with timeline entries
    And entries are naturally ordered by timestamp
    When entries are retrieved
    Then they are returned in strict chronological order:
      | order | timestamp   | event_type           |
      | 1     | 14:48:07Z   | CASE_CREATED         |
      | 2     | 14:48:15Z   | NOTIFICATION_COMPOSED |
      | 3     | 14:48:20Z   | CONSENT_CHECKED      |
      | 4     | 14:48:22Z   | IDEMPOTENCY_KEY_GEN  |
      | 5     | 14:48:23Z   | NOTIFICATION_DISPATCH|
    And ordering is strict (cannot be reordered)
    And new entries are always appended to the end

  @regression
  Scenario Outline: Timeline entry types for major Case milestones
    Given a Case progressing through disruption handling
    When the following events occur:
      | event_type         | when_occurs              |
      | <timeline_event>   | <occurrence_point>       |
    Then Case.timeline records an entry of type "<timeline_event>"

    Examples:
      | timeline_event                | occurrence_point           |
      | CASE_CREATED                  | Upon Case creation         |
      | SEVERITY_COMPUTED             | Upon ruleset application   |
      | NOTIFICATION_COMPOSED         | Upon message composition   |
      | CONSENT_CHECKED               | Upon consent verification  |
      | IDEMPOTENCY_KEY_GENERATED     | Upon key composition       |
      | NOTIFICATION_DISPATCHED       | Upon dispatch to provider  |
      | NOTIFICATION_SUPPRESSED_DUPLICATE | Upon duplicate suppression |
      | NOTIFICATION_BLOCKED          | Upon consent/eligibility block |
      | DISPATCH_FAILED               | Upon provider failure      |
      | DISPATCH_RETRY                | Upon retry attempt         |

  @critical @compliance
  Scenario: Timeline completeness verification for regulatory audit
    Given Case C42891 with complete disruption handling
    When compliance auditor retrieves the timeline
    Then they can verify:
      | verification       | method                       |
      | No gaps            | All major events recorded    |
      | Chronological      | Entries ordered by timestamp |
      | Immutable          | Entries cannot be modified   |
      | Complete flow      | From creation to dispatch    |
      | Audit trail proves | GDPR compliance             |
    And auditor can demonstrate non-repudiation (timeline cannot be falsified)
    And timeline serves as evidence for regulatory compliance

  @audit
  Scenario: Timestamp recording with UTC and offset
    Given a Case timeline entry created at local time 3:48 PM EDT on 2026-03-19
    When the entry is recorded
    Then the timestamp is stored as:
      | format             | value                        |
      | ISO 8601 UTC       | 2026-03-19T19:48:07Z         |
      | with offset        | 2026-03-19T19:48:07Z (UTC)   |
      | local for ref      | 2026-03-19T15:48:07-04:00    |
    And internal storage uses UTC (consistent)
    And all timestamps are comparable across timezones

  @audit
  Scenario: Context and reason recording for each timeline entry
    Given Case C42891 timeline entry: NOTIFICATION_DISPATCHED at 14:48:23Z
    When entry is recorded
    Then it includes:
      | field              | value                        |
      | timestamp          | 2026-03-19T14:48:23Z         |
      | event_type         | NOTIFICATION_DISPATCHED      |
      | event_context      | Detailed context string      |
      | reason             | Why this event occurred      |
      | actor              | System/component that caused it |
      | correlation_id     | Tracing ID for requests      |
    And context enables understanding the "why" behind events
    And reason field supports forensic investigation

  @critical
  Scenario: Full timeline retrieval for customer support investigation
    Given Case C42891
    When a support agent requests Case timeline
    Then they receive all entries in chronological order:
      | #  | timestamp    | event_type                | reason                  |
      | 1  | 14:48:07Z    | CASE_CREATED              | correlation_score=0.95  |
      | 2  | 14:48:15Z    | NOTIFICATION_COMPOSED     | all elements ready      |
      | 3  | 14:48:20Z    | CONSENT_CHECKED           | SMS opt_in verified     |
      | 4  | 14:48:22Z    | IDEMPOTENCY_KEY_GENERATED | standard composition    |
      | 5  | 14:48:23Z    | NOTIFICATION_DISPATCHED   | Twilio provider message_id=xyz|
    And support agent can trace complete case handling
    And timeline proves passenger was notified exactly once
    And timeline is audit-quality evidence

  @audit
  Scenario: Timeline as non-repudiation mechanism
    Given a Case with complete timeline
    When someone questions: "Was this passenger notified?"
    Then the audit trail provides proof:
      | evidence           | from timeline                |
      | Notification sent  | NOTIFICATION_DISPATCHED entry|
      | When               | timestamp 14:48:23Z          |
      | Via which channel  | SMS                          |
      | To which contact   | +1-404-555-0127              |
      | Provider confirmed | provider_message_id=twilio_xyz|
    And timeline cannot be falsified (immutable, append-only)
    And non-repudiation is mathematically enforced
