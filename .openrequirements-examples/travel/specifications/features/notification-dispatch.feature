@notification-dispatch @delivery @critical
Feature: Notification Dispatch - Template-Based Delivery
  As the notification dispatch engine
  I want to send notifications via selected channels using versioned templates
  So that disruption information reaches passengers exactly once per channel

  Background:
    Given a Case exists with selected channel and Lead Contact information
    And the dispatch engine is running
    And versioned templates are loaded
    And notification providers are configured

  @happy-path @smoke
  Scenario: Dispatch SMS notification to single contact via Twilio
    Given Case C42891:
      | field              | value                        |
      | lead_contact_name  | Robert Chen                  |
      | phone_number       | +1-404-555-0127              |
      | selected_channel   | SMS                          |
      | case_id            | C42891                       |
    And composed notification ready for dispatch:
      | field              | value                        |
      | message_text       | "Your DL427 to LAX is delayed 45 min, ETA 3:15 PM (Case: C42891)" |
      | template_name      | DELAY_SINGLE_LEG_SMS_v2      |
      | template_version   | 2                            |
    When the system dispatches the notification via SMS
    Then exactly one SMS message is delivered to +1-404-555-0127
    And dispatch_record is created:
      | field              | value                        |
      | case_id            | C42891                       |
      | channel            | SMS                          |
      | recipient          | +1-404-555-0127              |
      | template_used      | DELAY_SINGLE_LEG_SMS_v2      |
      | template_version   | 2                            |
      | dispatch_timestamp | 2026-03-19T14:48:15Z         |
      | provider           | Twilio                       |
      | message_id         | (provider message ID)        |
      | status             | delivered                    |

  @happy-path
  Scenario: Dispatch email notification with template rendering
    Given Case C42893:
      | field              | value                        |
      | lead_contact_name  | James Rodriguez              |
      | email              | james.rodriguez@email.com    |
      | selected_channel   | EMAIL                        |
    And composed notification:
      | field              | value                        |
      | template_name      | CANCELLATION_EMAIL_v2        |
      | template_version   | 2                            |
      | case_id            | C42893                       |
    When the system dispatches via EMAIL
    Then exactly one email is delivered to james.rodriguez@email.com
    And email_dispatch_record is created with:
      | field              | value                        |
      | case_id            | C42893                       |
      | channel            | EMAIL                        |
      | template_version   | 2                            |
      | delivery_status    | delivered                    |

  @edge-case
  Scenario: Verify exactly-once delivery guarantee
    Given Case C42891 and composed SMS notification
    And dispatch is attempted to +1-404-555-0127
    When the dispatch operation completes
    Then exactly one message is delivered (not zero, not multiple)
    And dispatch_record shows dispatch_count = 1
    And idempotency_key prevents re-dispatch if operation is retried
    And audit_log records: "Exactly-once delivery confirmed for Case C42891 via SMS"

  @critical
  Scenario: Template version tracking in dispatch record
    Given Case C42894
    And versioned template DELAY_SINGLE_LEG_SMS_v2 available
    When dispatch occurs
    Then dispatch_record includes:
      | field              | value                        |
      | template_name      | DELAY_SINGLE_LEG_SMS_v2      |
      | template_version   | 2                            |
    And template version enables future re-renders or audits
    And version is immutable in dispatch history

  @error-case
  Scenario: Dispatch failure is recorded with error details
    Given Case C42891 ready for SMS dispatch
    And SMS provider (Twilio) is temporarily unreachable
    When dispatch is attempted
    Then dispatch fails with error "Provider timeout: Twilio unavailable"
    And dispatch_record is created with:
      | field              | value                        |
      | case_id            | C42891                       |
      | channel            | SMS                          |
      | dispatch_timestamp | 2026-03-19T14:48:15Z         |
      | status             | failed                       |
      | error_details      | "Provider timeout"           |
      | retry_count        | 0 (initial attempt)          |
    And error is logged for monitoring and recovery
    And Case timeline records: "Dispatch failed: [error_details]"

  @error-case
  Scenario: Dispatch fails when contact address is invalid
    Given Case with invalid phone_number "+1-404-555-" (incomplete)
    When dispatch is attempted
    Then dispatch fails with validation error
    And error_log records: "Invalid phone number format: +1-404-555-"
    And dispatch is NOT sent (does not attempt provider call)
    And dispatch_record records the validation failure
    And Case remains open for manual escalation

  @error-case
  Scenario: Dispatch blocked when Lead Contact information is missing
    Given Case C42895 without lead_contact_id assigned
    When dispatch is attempted
    Then dispatch fails with error "Lead Contact not identified"
    And error_log records the failure
    And Case timeline shows: "Dispatch blocked: Lead Contact unknown"

  @regression
  Scenario Outline: Dispatch notifications across different channels
    Given Case with:
      | field              | value                        |
      | case_id            | C<seq>                       |
      | selected_channel   | <channel>                    |
      | recipient_contact  | <contact>                    |
    When dispatch is attempted via <channel>
    Then message is delivered to <contact>
    And dispatch_record records <channel> delivery

    Examples:
      | seq   | channel | contact                  |
      | 42891 | SMS     | +1-404-555-0127          |
      | 42893 | EMAIL   | james.rodriguez@email.com|
      | 42895 | PUSH    | (device token)           |

  @critical @audit
  Scenario: Dispatch audit trail captures all delivery details
    Given Case C42891 dispatched via SMS
    When dispatch completes successfully
    Then audit_log records:
      | field              | value                        |
      | case_id            | C42891                       |
      | channel            | SMS                          |
      | recipient          | +1-404-555-0127              |
      | template_used      | DELAY_SINGLE_LEG_SMS_v2      |
      | template_version   | 2                            |
      | dispatch_timestamp | 2026-03-19T14:48:15Z         |
      | provider           | Twilio                       |
      | provider_message_id| (Twilio message ID)          |
      | delivery_status    | delivered                    |
      | delivery_timestamp | 2026-03-19T14:49:30Z         |
    And audit entry is immutable
    And enables full traceability for customer support

  @audit
  Scenario: Failed dispatch enables recovery workflow
    Given Case C42891 with failed SMS dispatch
    And dispatch_record shows status="failed" with error details
    When recovery process is initiated
    Then dispatch can be retried
    And idempotency_key ensures retry does not duplicate send
    And audit_log documents retry attempt
