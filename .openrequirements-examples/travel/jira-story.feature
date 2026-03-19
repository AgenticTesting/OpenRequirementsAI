Feature: Disruption Detection, Correlation, and Passenger Notification

  Background:
    Given the Disruption Orchestrator is running
    And the canonical event schema is enabled
    And message template "A_DELAY_ALERT_v3" exists for locale "en-GB"
    And notification providers for "email" and "sms" are configured
    And deduplication is enabled using idempotency keys per Case + channel + template
    And quiet hours rules exist for locale "en-GB" with an exception for "service-critical" messages

  @requirement-A @correlation @notification @audit @idempotency
  Scenario: Correlate a delay disruption event to a Case and send exactly one compliant passenger notification with an auditable timeline
    Given passenger "P1" exists with contact details:
      | channel | value                 | consent_state | captured_at           | provenance        |
      | email   | p1@example.test        | opt_in        | 2026-01-05T10:15:00Z  | self_service_ui   |
      | sms     | +447700900001          | opt_in        | 2026-01-05T10:15:00Z  | self_service_ui   |
    And passenger "P1" is the lead contact for booking reference "PNR123"
    And booking reference "PNR123" contains journey "J1" with legs:
      | leg_id | service_type | service_no | service_date | origin | destination | scheduled_departure_utc   | scheduled_arrival_utc     |
      | L1     | air          | EP042      | 2026-02-03   | MAN    | AMS         | 2026-02-03T09:00:00Z      | 2026-02-03T10:20:00Z      |
    And a Case does not yet exist for booking reference "PNR123" on service "EP042" dated "2026-02-03"

    When the system ingests a disruption signal from source "carrier_ops_feed" with raw payload:
      """
      {
        "event_id": "OPS-0009",
        "event_type": "DELAY",
        "service_no": "EP042",
        "service_date": "2026-02-03",
        "origin": "MAN",
        "destination": "AMS",
        "delay_minutes": 95,
        "effective_time_utc": "2026-02-03T07:15:00Z",
        "confidence": 0.92
      }
      """
    Then the system stores the raw event immutably with metadata including:
      | field         | expected_value       |
      | source_id      | carrier_ops_feed     |
      | raw_event_id   | OPS-0009             |
      | received_at    | (present)            |
      | checksum       | (present)            |
    And the system normalizes the event into canonical form with:
      | field               | expected_value                 |
      | event_type          | delay                          |
      | service_no          | EP042                          |
      | service_date        | 2026-02-03                     |
      | origin              | MAN                            |
      | destination         | AMS                            |
      | effective_time_utc  | 2026-02-03T07:15:00Z           |
      | confidence          | 0.92                           |

    And the system correlates the normalized event to booking reference "PNR123" deterministically
    And the correlation record includes:
      | field            | expected_value        |
      | case_id          | (present)             |
      | match_strategy   | service_no+date+od     |
      | match_score      | (>= 0.80)             |
      | reasons          | (present)             |
    And the Case is created for journey "J1" with initial status "Detected"
    And the Case severity is computed as "Major" using a versioned ruleset
    And the Case stores the severity rule version used

    When the system evaluates notification eligibility for the Case
    Then the system selects channel "sms" for passenger "P1" because consent_state is "opt_in"
    And the system generates a passenger-facing summary that includes:
      | element                         |
      | what changed                    |
      | new expected departure time     |
      | next steps / call to action     |
      | Case reference                  |
    And the system generates a secure deep link for the Case that:
      | constraint         | expected_value |
      | expires_in_minutes | 120            |
      | is_revocable       | true           |

    When the system dispatches the notification using template "A_DELAY_ALERT_v3" for locale "en-GB"
    Then exactly 1 outbound message is sent for Case "<case_id>" on channel "sms" using template "A_DELAY_ALERT_v3"
    And the outbound message record stores:
      | field             | expected_value           |
      | template_version  | A_DELAY_ALERT_v3         |
      | locale            | en-GB                    |
      | idempotency_key   | (present)                |
      | correlation_id    | (present)                |
      | created_at        | (present)                |
    And the Case timeline contains append-only entries in order:
      | entry_type              |
      | RawEventStored          |
      | EventNormalized         |
      | EventCorrelated         |
      | CaseCreated             |
      | SeverityComputed        |
      | NotificationComposed    |
      | NotificationDispatched  |

    When the same disruption signal "OPS-0009" is ingested again from source "carrier_ops_feed"
    Then the system stores the raw event immutably as a distinct ingestion record
    But the system does not send a second outbound message for the same Case, channel, and template
    And the Case timeline includes an entry "NotificationSuppressedAsDuplicate" with the idempotency key reference