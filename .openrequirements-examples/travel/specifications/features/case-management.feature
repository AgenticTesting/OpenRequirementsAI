@case-management @severity @critical
Feature: Case Creation and Severity Computation
  As the disruption management system
  I want to create Cases for correlated disruptions and compute severity using versioned rulesets
  So that passenger support teams can prioritize response efforts appropriately

  Background:
    Given a successful Correlation exists between a disruption event and a booking
    And the severity computation engine is running
    And the active ruleset version is "2.1"

  @happy-path @smoke
  Scenario: Create Case with initial status and severity computation
    Given a successful Correlation for flight DL427, passenger P8847, booking BK-2026-DL427-0319
    And the disruption is a DELAY of 45 minutes
    When a Case is created for the affected journey
    Then the Case has these properties:
      | field              | value                        |
      | case_id            | C42891 (generated)           |
      | booking_ref        | BK-2026-DL427-0319           |
      | passenger_id       | P8847                        |
      | status             | Detected                     |
      | severity           | Major                        |
      | ruleset_version    | 2.1                          |
      | created_at         | (current timestamp UTC)      |
    And the Case severity is immutable thereafter
    And severity is computed once using the active versioned ruleset

  @happy-path
  Scenario: CANCELLATION event creates Major severity Case
    Given a normalized CANCELLATION event for service SW1893
    And a successful Correlation to booking BK-2026-SW1893-0319, passenger P12445
    When Case is created
    Then Case.severity = "Major" (CANCELLATION rule: always Major)
    And Case.ruleset_version = "2.1" (active ruleset)
    And ruleset audit shows:
      | field              | value                        |
      | rule_id            | SVRTY_001                    |
      | matcher            | event_type                   |
      | condition          | CANCELLATION                 |
      | outcome            | Major                        |
      | applied_version    | 2.1                          |

  @edge-case
  Scenario: Duplicate Correlation for same booking does NOT trigger re-severity-computation
    Given Case C42891 exists with severity = "Major" computed by ruleset_version 2.1
    And the severity computation timestamp is recorded
    When a duplicate disruption event is received and re-correlates to the same booking
    Then a new Correlation record is created
    And a new raw_event record is created
    But NO new Case is created
    And Case.severity remains "Major" (unchanged)
    And severity is NOT re-computed
    And audit_log records: "Duplicate correlation for existing Case C42891 - severity not recomputed"

  @edge-case
  Scenario: Severity computation with conflicting rules
    Given a DELAY event of 120 minutes
    And the active ruleset (v2.1) has competing rules:
      | condition          | outcome                      |
      | DELAY > 3 hours    | Critical                     |
      | DELAY > 1 hour     | Major                        |
    When severity is computed
    Then the most specific rule applies
    And Case.severity = "Critical" (120 min > 180 min threshold applied correctly)
    And audit_log shows rule selection logic

  @error-case
  Scenario: Severity computation fails when ruleset is unavailable
    Given a Correlation exists
    When the severity ruleset_version 2.1 cannot be loaded
    Then severity computation fails
    And error_log records: "Ruleset version 2.1 unavailable"
    And Case creation is blocked
    And the Correlation is queued for retry

  @error-case
  Scenario: Reject Case creation without valid Correlation
    Given no Correlation exists for a booking
    When Case creation is attempted
    Then Case creation fails with error "Correlation required"
    And error_log records the failure
    And no Case is created

  @regression
  Scenario Outline: Verify severity computation across event types and durations
    Given a "<event_type>" disruption event with "<condition>"
    And active ruleset version 2.1
    When Case is created
    Then Case.severity = "<expected_severity>"
    And ruleset_version = "2.1"

    Examples:
      | event_type    | condition         | expected_severity |
      | CANCELLATION  | (any)             | Major             |
      | DELAY         | 5 minutes         | Minor             |
      | DELAY         | 45 minutes        | Major             |
      | DELAY         | 180 minutes       | Critical          |
      | GATE_CHANGE   | (any)             | Minor             |

  @critical @audit
  Scenario: Case timeline entry recorded for creation
    Given a Case is created with case_id C42891
    When creation completes
    Then Case.timeline records an entry:
      | field              | value                        |
      | timestamp          | (creation UTC timestamp)     |
      | event_type         | CASE_CREATED                 |
      | event_details      | correlation_id=..., sev=Major|
      | ruleset_version    | 2.1                          |
    And timeline entry is immutable
    And entry is appended (not modified)

  @audit
  Scenario: Ruleset version rollback scenario
    Given Case C42891 was created with ruleset_version 2.1
    And severity = "Major" was computed using rules from v2.1
    And a new ruleset_version 2.2 is deployed
    When new disruptions occur
    Then new Cases use ruleset_version 2.2
    But Case C42891 retains ruleset_version 2.1 in its record
    And severity "Major" is immutable despite ruleset version change
    And audit trail shows version history for compliance

  @critical
  Scenario: Case lead_passenger_id assignment
    Given a booking with 3 passengers: P7634 (lead), P7635 (co-pax), P7636 (co-pax)
    And a successful Correlation
    When Case is created
    Then Case.lead_passenger_id = P7634
    And this field is used for notification recipient selection
    And audit log records: "lead_passenger_id=P7634 identified from passenger_roster"
