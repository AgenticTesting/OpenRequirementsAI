@notification-composition @content @major
Feature: Notification Composition - Passenger-Facing Content
  As the notification engine
  I want to generate passenger-facing content including what changed, new expected times, and Case references
  So that passengers understand the disruption and can find additional details

  Background:
    Given a Case exists with assigned severity and disruption event details
    And the notification composition engine is running
    And template registry is available

  @happy-path @smoke
  Scenario: Compose SMS notification for delay with complete required elements
    Given Case C42891:
      | field              | value                        |
      | passenger_name     | Robert Chen                  |
      | flight_number      | DL427                        |
      | destination        | LAX                          |
      | original_departure | 2026-03-19T14:30:00Z         |
      | delay_minutes      | 45                           |
      | new_expected_time  | 2026-03-19T15:15:00Z         |
      | severity           | Major                        |
      | case_id            | C42891                       |
    When a notification is being composed for SMS channel
    Then the notification includes all required elements:
      | element            | example                      |
      | what_changed       | "Your DL427 to LAX is now delayed 45 minutes" |
      | new_expected_time  | "New ETA: 3:15 PM"          |
      | case_reference     | "Case: C42891"              |
    And deep_link is generated pointing to case-ref.xyz/C42891
    And deep_link expires in 120 minutes (2026-03-19T16:48:00Z)
    And composed message is ready for template rendering

  @happy-path
  Scenario: Compose email notification for cancellation
    Given Case C42893:
      | field              | value                        |
      | flight_number      | SW1893                       |
      | origin             | SFO                          |
      | destination        | SAN                          |
      | event_type         | CANCELLATION                 |
      | severity           | Major                        |
      | case_id            | C42893                       |
    When a notification is being composed for EMAIL channel
    Then the notification includes:
      | element            | content                      |
      | what_changed       | "Flight SW1893 from SFO to SAN has been cancelled" |
      | case_reference     | "Reference: C42893"          |
      | action_link        | case-ref.xyz/C42893          |
    And the email has subject: "Flight Disruption Alert - SW1893"
    And deep_link is generated with 120-minute expiration

  @edge-case
  Scenario: Compose notification for multiple passengers on booking - lead contact only
    Given Case C42894 for booking BK-2026-UA1847-0319:
      | field              | value                        |
      | lead_passenger     | David Thompson (P7634)       |
      | co_passengers      | Emma (P7635), Sophie (P7636) |
      | flight_number      | UA1847                       |
      | delay_minutes      | 90                           |
      | case_id            | C42894                       |
    When notification is being composed
    Then composition addresses ONLY the lead contact:
      | field              | value                        |
      | recipient_name     | David Thompson               |
      | message_greeting   | "Dear David"                 |
    And message says: "Your booking UA1847 to New York has been delayed 90 minutes"
    And co-passengers (Emma, Sophie) are NOT mentioned in content
    And co-passengers receive NO notification
    And audit_log records: "Composed for lead_passenger_id=P7634 only; passenger_count=3 on booking"

  @edge-case
  Scenario: Compose notification for minor delay (< 30 minutes)
    Given Case with:
      | field              | value                        |
      | event_type         | DELAY                        |
      | delay_minutes      | 15                           |
      | severity           | Minor                        |
    When notification is being composed
    Then the notification acknowledges minor impact:
      | element            | content                      |
      | what_changed       | "Your flight is now running 15 minutes late" |
    And deep_link is still provided for Case reference
    And composition completes successfully despite Minor severity

  @critical
  Scenario: Deep link generation with 120-minute expiration
    Given Case C42891 created at 2026-03-19T14:48:00Z
    When notification composition generates a deep_link
    Then the deep_link:
      | field              | value                        |
      | target             | case-ref.xyz/C42891          |
      | created_at         | 2026-03-19T14:48:00Z         |
      | expires_at         | 2026-03-19T16:48:00Z         |
      | ttl_seconds        | 7200 (exactly 120 minutes)   |
      | is_revocable       | true                         |
    And expiration is strictly enforced
    And expired links reject access attempts

  @critical
  Scenario: Deep link revocation mechanism
    Given a deep_link for Case C42891 that is currently valid
    And the link URL is case-ref.xyz/C42891?token=xyz123
    When a revocation request is submitted (e.g., by support team)
    Then the link is marked as revoked
    And subsequent access to the link returns error "Link revoked"
    And audit_log records: "Deep link revoked for Case C42891 at [timestamp]"
    And revocation reason is captured

  @error-case
  Scenario: Composition fails when new_expected_time cannot be calculated
    Given Case with:
      | field              | value                        |
      | scheduled_time     | (invalid or missing)         |
      | delay_minutes      | 45                           |
    When notification composition is attempted
    Then composition fails with error "Cannot calculate new_expected_time"
    And error_log records the failure
    And no notification is queued for dispatch
    And Case remains in "Detected" status pending manual review

  @error-case
  Scenario: Composition fails when template for event type not found
    Given Case with:
      | field              | value                        |
      | event_type         | UNKNOWN_EVENT_TYPE           |
      | severity           | Major                        |
    When composition attempts to select template for event_type
    Then no matching template is found
    And error_log records: "No template found for event_type=UNKNOWN_EVENT_TYPE"
    And composition fails

  @regression
  Scenario Outline: Compose notifications for various disruption types
    Given Case with:
      | field              | value                        |
      | event_type         | <event_type>                 |
      | disruption_detail  | <detail>                     |
      | case_id            | C<seq>                       |
    When notification is composed for SMS
    Then message includes what_changed describing <event_type>

    Examples:
      | event_type    | detail                    | seq   |
      | DELAY         | 45 minutes                | 42891 |
      | CANCELLATION  | Complete cancellation     | 42893 |
      | GATE_CHANGE   | Gate moved from B1 to B5  | 42895 |
      | MECHANICAL    | Aircraft maintenance      | 42896 |

  @audit
  Scenario: Composition audit trail captures content elements
    Given Case C42891
    When notification is composed
    Then audit_log records:
      | field              | captured                     |
      | case_id            | C42891                       |
      | composition_at     | (UTC timestamp)              |
      | elements_included  | what_changed, new_time, case_ref|
      | deep_link_id       | (generated)                  |
      | deep_link_expires  | 2026-03-19T16:48:00Z         |
      | template_type      | (e.g., DELAY_SINGLE_LEG_SMS_v2)|
    And audit entry is immutable
