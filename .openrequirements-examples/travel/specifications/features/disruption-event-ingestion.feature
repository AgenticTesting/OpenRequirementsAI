@disruption-ingestion @audit @critical
Feature: Disruption Event Ingestion and Storage
  As a disruption management system
  I want to ingest and immutably store raw disruption signals with complete metadata
  So that all disruption data is preserved for audit trails and forensic analysis

  Background:
    Given the Disruption Orchestrator is running
    And the event ingestion pipeline is active
    And audit logging is enabled

  @happy-path @smoke
  Scenario: Store a delay disruption signal with full metadata
    Given a disruption signal from source "carrier_ops_feed" with event_id "OPS-0009"
    When the system ingests a raw delay event:
      | field              | value                        |
      | event_type         | DELAY                        |
      | service_no         | DL427                        |
      | service_date       | 2026-03-19                   |
      | origin             | ATL                          |
      | destination        | LAX                          |
      | delay_minutes      | 45                           |
      | confidence         | 0.92                         |
      | source_timestamp   | 2026-03-19T14:30:00Z         |
      | received_timestamp | 2026-03-19T14:48:00Z         |
    Then the raw event is stored immutably with:
      | field              | value                        |
      | original_payload   | (complete JSON structure)    |
      | reception_timestamp| 2026-03-19T14:48:00Z         |
      | source_identifier  | carrier_ops_feed             |
      | event_id           | OPS-0009                     |
    And the stored event has a valid checksum
    And the event record cannot be modified or deleted (audit trail integrity enforced)
    And audit_log records: "Raw event stored: OPS-0009 from carrier_ops_feed at 2026-03-19T14:48:00Z"

  @happy-path
  Scenario: Store a cancellation event with source metadata
    Given a disruption signal from source "crew_planning_system"
    When the system ingests a cancellation event:
      | field              | value                        |
      | event_type         | CANCELLATION                 |
      | service_no         | SW1893                       |
      | service_date       | 2026-03-19                   |
      | origin             | SFO                          |
      | destination        | SAN                          |
      | confidence         | 0.98                         |
      | cancellation_reason| AIRCRAFT_MAINTENANCE         |
      | source_timestamp   | 2026-03-19T15:20:00Z         |
      | received_timestamp | 2026-03-19T15:30:00Z         |
    Then the raw event is stored immutably with complete original payload
    And the event record includes source="crew_planning_system"
    And the stored record is immutable thereafter (no update, no delete)
    And audit_log records successful storage with checksum

  @edge-case
  Scenario: Ingest event with minimal required fields
    Given a disruption signal with only required fields
    When the system ingests an event with:
      | field              | value                        |
      | event_type         | DELAY                        |
      | service_no         | AA215                        |
      | service_date       | 2026-03-20                   |
      | origin             | BOS                          |
      | destination        | MIA                          |
      | received_timestamp | 2026-03-20T08:15:00Z         |
    Then the raw event is stored successfully
    And all provided fields are preserved exactly as received

  @error-case
  Scenario: Reject malformed event payload
    Given a disruption signal with corrupted JSON structure
    When the system attempts to ingest the malformed event
    Then the event is rejected before storage
    And error_log records: "Malformed event rejected: invalid JSON structure"
    And the corrupted payload is NOT stored in the main event table
    And the rejection is auditable

  @error-case
  Scenario: Ingest event missing critical fields
    Given a disruption signal missing required field "service_no"
    When the system attempts to ingest the incomplete event
    Then the event is rejected before storage
    And error_log records: "Missing critical field: service_no"
    And no Case creation is attempted
    And the raw event is NOT stored

  @regression @audit
  Scenario Outline: Verify immutability enforcement for all event types
    Given a raw event of type "<event_type>" has been stored with id "<event_id>"
    When the system receives a request to modify the stored event
    Then the modification is rejected with error "Event is immutable"
    And the original event remains unchanged
    And audit_log records attempted modification with timestamp

    Examples:
      | event_type    | event_id  |
      | DELAY         | OPS-0009  |
      | CANCELLATION  | OPS-0010  |
      | GATE_CHANGE   | OPS-0011  |
      | MECHANICAL    | OPS-0012  |

  @regression @audit
  Scenario: Verify checksum consistency for immutable event record
    Given a stored event with id "OPS-0009"
    And the event has checksum "abc123def456"
    When the system calculates the checksum of the stored event
    Then the calculated checksum equals "abc123def456"
    And this matches the original stored checksum exactly
    And if retrieved again, the checksum remains consistent

  @audit @critical
  Scenario: Audit trail captures all event storage operations
    Given the audit logging system is enabled
    When a disruption event is ingested and stored
    Then audit_log contains entries for:
      | action               | recorded                     |
      | event_received       | reception_timestamp          |
      | payload_validated    | validation_result            |
      | storage_committed    | checksum, storage_location   |
      | immutability_set     | enforcement_enabled          |
    And all audit entries include source_identifier and event_id
    And audit entries are themselves immutable
