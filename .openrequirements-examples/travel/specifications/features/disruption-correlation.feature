@correlation @matching @critical
Feature: Disruption-to-Booking Correlation
  As the disruption processing system
  I want to match normalized disruption events to passenger bookings using deterministic strategies
  So that affected passengers are automatically identified without manual intervention

  Background:
    Given a normalized disruption event exists
    And the passenger booking database is available
    And the correlation matching engine is running
    And match_score threshold is set to >= 0.80

  @happy-path @smoke
  Scenario: Successfully correlate delay to single-leg booking
    Given a normalized disruption event:
      | field              | value                        |
      | event_type         | DELAY                        |
      | service_no         | DL427                        |
      | service_date       | 2026-03-19                   |
      | origin             | ATL                          |
      | destination        | LAX                          |
    And a passenger booking exists:
      | field              | value                        |
      | booking_ref        | BK-2026-DL427-0319           |
      | service_no         | DL427                        |
      | service_date       | 2026-03-19                   |
      | origin             | ATL                          |
      | destination        | LAX                          |
      | passenger_id       | P8847                        |
    When the system attempts Correlation using deterministic matching
    Then a match is found with match_score: 0.95
    And a Correlation record is created linking:
      | field              | value                        |
      | event_id           | (normalized event)           |
      | booking_ref        | BK-2026-DL427-0319           |
      | match_score        | 0.95                         |
      | match_strategy     | service_no+date+origin/dest  |
    And Correlation.match_score >= 0.80 (threshold met)
    And the Correlation ID is generated for tracing

  @happy-path
  Scenario: Correlate cancellation event with high confidence
    Given a normalized CANCELLATION event:
      | field              | value                        |
      | event_type         | CANCELLATION                 |
      | service_no         | SW1893                       |
      | service_date       | 2026-03-19                   |
      | origin             | SFO                          |
      | destination        | SAN                          |
    And a matching booking exists for passenger P12445
    When correlation is attempted
    Then match_score >= 0.80
    And Correlation record is created
    And Correlation.reasons includes "Exact service_no match, date match, route match"

  @edge-case
  Scenario: No match when service_no differs
    Given a normalized disruption event for service_no "DL427" on 2026-03-19
    And a booking exists for service_no "DL428" (different flight) on same date
    When correlation is attempted using service_no+date+origin/destination
    Then match_score < 0.80 (service_no mismatch penalizes score)
    And no Correlation record is created
    And no Case is created
    And the unmatched disruption is logged for manual review

  @edge-case
  Scenario: No match when service_date differs
    Given a normalized disruption event for service_date "2026-03-19"
    And a booking exists for the same service_no and route but on "2026-03-20"
    When correlation is attempted
    Then match_score < 0.80 (date mismatch)
    And no Correlation is created

  @edge-case
  Scenario: Boundary case - match_score exactly 0.80 meets threshold
    Given a normalized disruption event
    And a booking with sufficient matching fields to achieve match_score exactly 0.80
    When correlation is attempted
    Then match_score = 0.80 (exactly at threshold)
    And the condition match_score >= 0.80 is satisfied (inclusive)
    And Correlation record IS created (threshold inclusive)

  @edge-case
  Scenario: Boundary case - match_score 0.79 fails threshold
    Given a normalized disruption event
    And a booking with fields resulting in match_score 0.79
    When correlation is attempted
    Then match_score = 0.79 (just below threshold)
    And the condition match_score >= 0.80 fails
    And no Correlation record is created
    And no Case is created

  @error-case
  Scenario: Correlation fails when booking database is unavailable
    Given a normalized disruption event
    When the booking database connection fails
    And correlation is attempted
    Then correlation fails with error "Booking database unavailable"
    And error_log records the failure
    And no Correlation is created
    And the event is queued for retry with backoff

  @error-case
  Scenario: Handle duplicate bookings for same service
    Given a normalized disruption event for service DL427
    And multiple booking records exist for the same passenger on service DL427
    When correlation is attempted
    Then match_score is computed for each booking
    And all matching bookings (score >= 0.80) have Correlation records created
    And each Correlation links to one booking
    And this may result in multiple Cases for the same passenger

  @regression
  Scenario Outline: Verify deterministic match strategy for various routes
    Given a normalized disruption event:
      | field              | value                        |
      | service_no         | <service_no>                 |
      | service_date       | <service_date>               |
      | origin             | <origin>                     |
      | destination        | <destination>                |
    And a matching booking with identical fields
    When correlation is attempted
    Then match_score >= 0.95 (near-perfect match)
    And Correlation is created

    Examples:
      | service_no | service_date | origin | destination |
      | DL427      | 2026-03-19   | ATL    | LAX         |
      | AA215      | 2026-03-20   | BOS    | MIA         |
      | UA1847     | 2026-03-21   | SFO    | JFK         |
      | SW1893     | 2026-03-19   | SFO    | SAN         |

  @audit @critical
  Scenario: Correlation audit trail captures matching details
    Given a normalized disruption event
    When correlation is attempted
    Then audit_log records:
      | field                  | captured                     |
      | event_id               | (normalized event)           |
      | correlation_id         | (generated ID)               |
      | matching_strategy      | service_no+date+origin/dest  |
      | match_score            | (computed score)             |
      | match_reasons          | (detailed reason)            |
      | booking_refs_matched   | (list of matching bookings)  |
      | timestamp              | (correlation_timestamp)      |
    And audit entries are immutable

  @audit
  Scenario: Traceability from raw event through correlation
    Given a raw event with event_id "OPS-0009"
    And a normalized event created from it
    And a Correlation created from the normalized event
    When traceability is checked
    Then the Correlation includes:
      | field              | value                        |
      | raw_event_id       | OPS-0009                     |
      | normalized_event_id| (generated)                  |
      | correlation_id     | (generated)                  |
    And all three records can be linked via audit trail
