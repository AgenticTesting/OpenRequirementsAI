@normalization @schema @critical
Feature: Event Normalization to Canonical Schema
  As the event processing pipeline
  I want to transform raw disruption signals into a standardized canonical form
  So that downstream systems can process events consistently regardless of source

  Background:
    Given the canonical event schema is enabled and versioned
    And the normalization engine is running
    And error logging is enabled

  @happy-path @smoke
  Scenario: Normalize a delay event to canonical schema
    Given a raw disruption event has been ingested with:
      | field              | value                        |
      | event_type         | DELAY                        |
      | service_no         | DL427                        |
      | service_date       | 2026-03-19                   |
      | origin             | ATL                          |
      | destination        | LAX                          |
      | delay_minutes      | 45                           |
      | confidence         | 0.92                         |
    When the system normalizes the event to Canonical Event Schema
    Then the normalized event contains all standardized fields:
      | field              | description                  |
      | event_type         | DELAY (normalized)           |
      | service_no         | DL427 (preserved)            |
      | service_date       | 2026-03-19 (ISO format)      |
      | origin             | ATL (standardized code)      |
      | destination        | LAX (standardized code)      |
      | effective_time_utc | 2026-03-19T14:30:00Z         |
      | confidence         | 0.92 (normalized)            |
    And the normalized event passes schema validation
    And the event is tagged with schema_version for traceability

  @happy-path
  Scenario: Normalize a cancellation event from crew planning system
    Given a raw CANCELLATION event from "crew_planning_system" with:
      | field              | value                        |
      | service_no         | SW1893                       |
      | service_date       | 2026-03-19                   |
      | origin             | SFO                          |
      | destination        | SAN                          |
      | confidence         | 0.98                         |
    When the system normalizes the event
    Then normalized event contains:
      | field              | value                        |
      | event_type         | CANCELLATION                 |
      | service_no         | SW1893                       |
      | service_date       | 2026-03-19                   |
      | origin             | SFO                          |
      | destination        | SAN                          |
      | confidence         | 0.98                         |
    And all source-specific metadata is preserved in metadata.source field

  @edge-case
  Scenario: Handle delay event with missing optional fields
    Given a raw delay event with minimal fields:
      | field              | value                        |
      | event_type         | DELAY                        |
      | service_no         | AA215                        |
      | service_date       | 2026-03-20                   |
      | origin             | BOS                          |
      | destination        | MIA                          |
    When the system normalizes the event
    Then the normalized event contains all required fields with defaults for missing optional fields
    And mandatory fields are populated
    And optional fields have null or default values
    And schema validation succeeds

  @error-case
  Scenario: Normalization fails for event with invalid service_date format
    Given a raw event with malformed service_date: "2026/03/19" (wrong format)
    When the system attempts normalization
    Then normalization fails
    And error_log records: "Normalization failed: invalid service_date format"
    And the raw event persists in the raw_events table
    And no normalized event is created
    And no Correlation is attempted
    And no Case is created

  @error-case
  Scenario: Normalization fails for missing mandatory field origin
    Given a raw event missing the mandatory "origin" field
    When the system attempts normalization
    Then normalization fails with error "Missing mandatory field: origin"
    And error_log records the failure with raw_event_id
    And the raw event is preserved unchanged
    And processing stops without creating Case or notification

  @error-case
  Scenario: Reject event with invalid confidence score
    Given a raw event with confidence value "1.5" (exceeds valid range 0.0-1.0)
    When the system attempts normalization
    Then normalization fails
    And error_log records: "Invalid confidence score: 1.5 (must be 0.0-1.0)"
    And the event is not normalized

  @regression
  Scenario Outline: Normalize events from heterogeneous sources to uniform schema
    Given a raw event from source "<source>" with type "<event_type>"
    When the system normalizes the event
    Then the normalized event conforms to the canonical schema
    And all required fields are present in standardized form
    And source-specific variations are normalized away

    Examples:
      | source                 | event_type    |
      | carrier_ops_feed       | DELAY         |
      | crew_planning_system   | CANCELLATION  |
      | ground_ops_api         | GATE_CHANGE   |
      | weather_integration    | DELAY         |

  @critical @audit
  Scenario: Preserve source event metadata in normalization
    Given a raw event with source_id "OPS-0009" from "carrier_ops_feed"
    When the system normalizes the event
    Then the normalized event includes metadata:
      | field              | value                        |
      | source_id          | OPS-0009                     |
      | source_system      | carrier_ops_feed             |
      | original_received  | (preserved timestamp)        |
      | schema_version     | (current version)            |
    And raw_event_id is linked to normalized_event_id
    And traceability is maintained for audit

  @audit
  Scenario: Schema version tracking for normalized events
    Given the canonical schema is version "2.1"
    When events are normalized
    Then each normalized event is tagged with schema_version="2.1"
    And schema version allows future migration/re-normalization
    And audit trail shows which schema version was applied
