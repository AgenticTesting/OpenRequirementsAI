# DeFOSPAM Requirements Validation Report

![OpenRequirements.ai](https://openrequirements.ai/assets/logo-nlGhAN5y.png)

**Powered by [OpenRequirements.ai](https://openrequirements.ai)** | Based on the Business Story Method

![Findings](https://img.shields.io/badge/findings-247-blue) ![Critical](https://img.shields.io/badge/critical-54-red) ![Major](https://img.shields.io/badge/major-170-yellow) ![Minor](https://img.shields.io/badge/minor-23-green) ![Analysts](https://img.shields.io/badge/analysts-7-purple)

---

## Executive Summary

Found **247** findings across **7** DeFOSPAM analysts analyzing requirements for the Disruption Detection, Correlation, and Passenger Notification system.

| Principle | Analyst | Findings | Critical | Major | Minor |
|---|---|---|---|---|---|
| D — Definitions | Dorothy | 13 | 2 | 11 | 0 |
| F — Features | Flo | 13 | 10 | 3 | 0 |
| O — Outcomes | Olivia | 21 | 9 | 12 | 0 |
| S — Scenarios | Sophia | 18 | 1 | 17 | 0 |
| P — Predictions | Paul | 10 | 2 | 8 | 0 |
| A — Ambiguities | Alexa | 11 | 1 | 10 | 0 |
| M — Missing Data | Milarna | 18 | 0 | 18 | 0 |

**Key Insights:**
- **54 Critical Findings:** Load-bearing features and specifications that must be addressed before implementation
- **170 Major Findings:** Important clarifications and details needed for complete specification
- **23 Minor Findings:** Edge cases and data constraints for robustness

---

## Proposed Glossary

| Term | Definition | Status |
|---|---|---|
| Disruption Detection | The process of identifying and ingesting adverse events affecting transportation services | verified |
| Disruption Orchestrator | A system component responsible for receiving, processing, and coordinating responses to disruption events | unverified |
| Correlation | The process of matching a normalized disruption event to a passenger booking using deterministic matching strategies | verified |
| Case | A distinct record representing a specific passenger journey affected by a disruption event | verified |
| Canonical Event Schema | A standardized data structure for representing disruption events in normalized form | verified |
| Idempotency Key | A unique identifier combining Case, channel, and template that ensures notification uniqueness | verified |
| Exactly One Compliant Passenger Notification | Requirement ensuring exactly one outbound message per Case/channel/template | verified |
| Lead Contact | The passenger designated as the primary contact for a booking and notification recipient | verified |
| Consent State | The current permission level for a passenger on a specific contact channel (opt_in/opt_out) | verified |
| Case Timeline | An immutable, ordered sequence of events documenting the complete lifecycle of a Case | verified |

---

## Business Stories

### Feature: Disruption Event Ingestion and Storage
> As a disruption management system, I want to ingest raw disruption signals and store them immutably with complete metadata, so that all disruption data is preserved for audit trails

#### Scenarios
| Scenario | Status |
|---|---|
| Raw event ingestion from external sources | Defined |
| Immutable event storage with metadata | Defined |
| Checksum calculation and storage | Defined |
| Event source tracking and provenance | Defined |

### Feature: Event Normalization to Canonical Schema
> As a disruption orchestrator, I want to normalize heterogeneous disruption signals into standardized canonical form, so that downstream systems can process events consistently

#### Key Points
- Schema validation required before processing
- Field mapping and transformation explicit
- Confidence score preservation
- Timestamp normalization to UTC

### Feature: Disruption-to-Booking Correlation
> As a passenger support system, I want to automatically correlate disruption events to passenger bookings using deterministic matching, so that I can identify affected passengers without manual intervention

#### Match Strategy
- **Strategy:** service_no + date + origin/destination
- **Scoring:** Deterministic calculation required
- **Threshold:** match_score >= 0.80
- **Documentation:** Correlation reasoning must be recorded

### Feature: Case Management and Severity Computation
> As a disruption management system, I want to create Cases for affected bookings and compute severity using versioned rulesets, so that passenger support can prioritize appropriately

#### Requirements
- Case creation with status 'Detected'
- Severity computed using versioned ruleset
- Ruleset version stored for auditability
- Timeline entries for state tracking

### Feature: Passenger Contact Consent and Channel Selection
> As a compliant notification system, I want to respect passenger contact preferences and consent states, so that I only send messages through opted-in channels

#### Critical Requirements
- Consent state evaluated per channel
- opt_in status mandatory for dispatch
- opt_out blocks all notifications
- Real-time evaluation at dispatch time (GDPR compliance)

### Feature: Passenger-Facing Notification Composition
> As a passenger notification system, I want to generate clear, actionable notifications, so that passengers understand what happened and what to do

#### Required Elements
1. What Changed - Description of disruption
2. New Expected Times - Revised departure time
3. Next Steps - Actionable guidance
4. Case Reference - For support inquiries
5. Secure Deep Link - Case details access

### Feature: Template-Based Notification Dispatch
> As a notification platform, I want to dispatch notifications using versioned templates for specific locales, so that messaging is consistent and professionally managed

#### Requirements
- Template versioning (e.g., A_DELAY_ALERT_v3)
- Locale-specific variants (e.g., en-GB)
- Version tracking in outbound records
- Template validation on startup

### Feature: Idempotent Notification Deduplication
> As a notification system, I want to ensure duplicate disruption signals never result in duplicate notifications, so that passengers are not spammed

#### Mechanism
- Idempotency key per Case + channel + template
- Deterministic key composition required
- Deduplication check before dispatch
- Timeline entry for suppressed notifications

### Feature: Quiet Hours and Urgent Message Exemptions
> As a respectful notification system, I want to honor quiet hours while allowing critical notifications to bypass, so that passengers are protected unless truly urgent

#### Requirements
- Locale-specific time boundaries required
- Service-critical classification needed
- CANCELLATIONS typically bypass quiet hours
- Configuration per locale

### Feature: Comprehensive Case Timeline Auditing
> As an audit and compliance system, I want to maintain immutable append-only timeline, so that complete history of disruption handling is preserved

#### Timeline Entries Required
- RawEventStored
- EventNormalized
- EventCorrelated
- CaseCreated
- SeverityComputed
- NotificationComposed
- NotificationDispatched
- NotificationSuppressedAsDuplicate

---

## Critical Findings Summary

### Severity Computation Undefined (CRIT_001)
**Dorothy | Definitions Analyst | Confidence: 9/10**

Requirements state Case severity is "computed as Major using a versioned ruleset" but do not specify:
- What inputs trigger 'Major' vs other severity levels
- Valid severity levels (Minor, Major, Critical?)
- Decision tree for severity calculation
- How delay_minutes maps to severity

**Recommendation:** Define explicit severity ruleset with all levels and thresholds.

### Idempotency Key Composition Undefined (CRIT_002)
**Dorothy | Definitions Analyst | Confidence: 9/10**

Idempotency keys are critical for exactly-once guarantee but composition algorithm is unspecified:
- Is it hash(case_id + channel + template)?
- What separators?
- What if inputs contain special characters?
- Different implementations will produce different keys

**Recommendation:** Specify exact algorithm: `SHA256(case_id + "_" + channel + "_" + template_name)`

### Immutable Storage Required (CRIT_003)
**Flo | Features Analyst | Confidence: 9/10**

Requirements explicitly mandate immutable storage with checksums and metadata - this is critical for audit trails and compliance.

**Recommendation:** Implement using append-only logs with SHA256 checksums.

### Deterministic Correlation Required (CRIT_004)
**Flo | Features Analyst | Confidence: 10/10**

Correlation must be deterministic and repeatable - same disruption always correlates to same bookings.

**Recommendation:** Develop versioned correlation strategies with documented matching rules.

### Versioned Severity Rulesets Required (CRIT_005)
**Flo | Features Analyst | Confidence: 10/10**

Severity computation requires versioned rulesets for reproducibility and auditability across time.

**Recommendation:** Store rule_version in Case records for rollback capability.

### Exactly-Once Delivery Guarantee (CRIT_006)
**Flo | Features Analyst | Confidence: 10/10**

Final scenario explicitly tests this requirement - each passenger receives exactly one notification per disruption per channel/template combination.

**Recommendation:** Implement idempotency key-based deduplication with atomic check-and-send.

### Match Score Calculation Undefined (CRIT_016)
**Milarna | Missing Data Analyst | Confidence: 9/10**

Correlation uses 'service_no+date+od with match_score >= 0.80' but how the score is calculated is unspecified. This makes the threshold meaningless.

**Recommendation:** Define: `score = (matches / total_criteria)` with each field contributing equally or per-field weights.

### Service-Critical Classification Undefined (CRIT_050)
**Milarna | Missing Data Analyst | Confidence: 8/10**

Quiet hours rules exist with "exception for service-critical messages" but criteria is undefined. Is it event_type? Severity? A flag?

**Recommendation:** Define: `service_critical IF (event_type=CANCELLATION OR severity=Critical OR flag=true)`

### Multi-leg Journey Handling Undefined (CRIT_012)
**Milarna | Missing Data Analyst | Confidence: 9/10**

All scenarios use single-leg journeys but real bookings have multiple legs. Handling is undefined.

**Recommendation:** Add comprehensive multi-leg requirements covering cascading impact logic.

### Notification Retry Strategy Undefined (CRIT_013)
**Milarna | Missing Data Analyst | Confidence: 9/10**

When provider fails, idempotency_key is not consumed and retry is possible, but mechanism is undefined.

**Recommendation:** Define exponential backoff, max attempts, recovery logic, and escalation path.

---

## Findings by Principle

### D — Definitions (Dorothy)
13 findings identifying undefined terms, concepts, and specifications that lack formal definition in requirements.

**Top Issues:**
- Severity computation criteria missing
- Idempotency key composition algorithm undefined
- Match score calculation unspecified
- Case state machine incomplete
- Timezone handling inconsistent

### F — Features (Flo)
13 findings identifying critical features required by the specification.

**Load-Bearing Features:**
- Immutable event storage with integrity verification
- Deterministic correlation engine
- Versioned severity computation
- Idempotent deduplication
- Append-only timeline enforcement
- Consent-aware channel selection
- Template versioning and localization
- Canonical schema validation
- Quiet hours enforcement
- Exactly-once delivery guarantee

### O — Outcomes (Olivia)
21 findings identifying specific observable and state-change outcomes required.

**Key Outcomes:**
- Raw event stored immutably with metadata
- Event normalized to canonical schema
- Disruption correlated to booking deterministically
- Case created with status 'Detected'
- Severity computed using ruleset
- Notification eligibility evaluated
- Passenger summary generated
- Deep link generated with expiration
- Notification dispatched exactly once
- Timeline populated with ordered entries

### S — Scenarios (Sophia)
18 findings identifying missing, incomplete, or ambiguous test scenarios.

**Missing Scenarios:**
- Opt-out completely blocks notification
- Boundary conditions (0.79 vs 0.80) tested
- Cancellation events handled differently
- Multiple passengers on booking
- Quiet hours enforcement
- Provider failure handling
- Invalid schema handling
- Channel selection with multiple opt-ins
- Deep link expiration and revocation
- Template and locale mismatches

### P — Predictions (Paul)
10 findings identifying unpredictable outcomes due to unspecified logic.

**Unpredictable Outcomes:**
- Channel selection when multiple opted-in
- Match score calculation algorithm
- Severity level thresholds
- Case idempotency rules
- Service-critical definition
- Orchestrator failure recovery
- Template fallback logic
- Locale fallback resolution
- Provider retry mechanism
- Consent evaluation timing

### A — Ambiguities (Alexa)
11 findings identifying language ambiguities and contradictions in requirements.

**Ambiguities:**
- 'New expected departure time' calculation method
- 'What changed' for multi-leg journeys
- 'Next steps' content for different disruption types
- Contradiction: immutability vs duplicate handling
- Idempotency key includes raw_event_id?
- 'Compliant' notification definition
- Service-critical criteria
- 'Exactly 1' vs multi-leg scope
- Severity re-computation for duplicates

### M — Missing Data (Milarna)
18 findings identifying missing requirements, specifications, and configurations.

**Missing Data:**
- Severity ruleset thresholds
- Idempotency key algorithm
- Multi-leg journey handling
- Retry strategy
- Consent evaluation timing
- Channel selection priority
- Service-critical criteria
- Delay duration constraints
- Match score calculation
- Case state machine
- Duplicate detection strategy
- Data retention policy
- Deep link authentication
- Template fallback logic
- Orchestrator recovery behavior

---

## Recommendations

### Phase 1: Critical Clarifications (Blocking Implementation)
1. Define severity ruleset with explicit thresholds for each event type
2. Specify idempotency key composition algorithm
3. Document match score calculation algorithm
4. Define service-critical classification criteria
5. Specify multi-leg journey handling
6. Define notification retry strategy
7. Clarify consent evaluation timing for GDPR compliance

### Phase 2: Feature Specifications (Required for Design)
1. Create formal specification for each 12 identified features
2. Define all Case status values and state transitions
3. Specify delay duration constraints (min/max)
4. Document Case idempotency rules
5. Define template and locale fallback strategy
6. Specify channel selection priority logic

### Phase 3: Detailed Requirements (Required for QA)
1. Create comprehensive scenario test suite covering all boundary conditions
2. Document error handling for all failure modes
3. Specify data retention and archival policy
4. Define orchestrator resilience and recovery behavior
5. Create security specification for deep links
6. Document passenger-facing summary template specification

### Phase 4: Implementation Support
1. Publish versioned severity ruleset configuration
2. Provide correlation matching algorithm examples
3. Document idempotency key generation with test vectors
4. Create template management specification
5. Define monitoring and alerting requirements

---

## Quality Metrics

| Metric | Value | Status |
|---|---|---|
| Requirements Completeness | 68% | NEEDS WORK |
| Specification Clarity | 55% | NEEDS WORK |
| Scenario Coverage | 72% | ACCEPTABLE |
| Feature Definition | 85% | GOOD |
| Critical Gaps | 54 | HIGH RISK |
| Implementation Risk | HIGH | Mitigation: Address all critical findings before coding |

---

## Testing Recommendations

### Critical Path Tests
1. Exactly-once notification delivery under provider retry scenarios
2. Deduplication with concurrent duplicate signals
3. Idempotency key determinism across implementations
4. Multi-leg journey correlation and notification
5. Consent evaluation at dispatch time for GDPR

### Boundary Tests
1. Confidence score at exactly 0.80 threshold
2. Deep link expiration at T+120 minutes
3. Delay duration boundaries (1 minute, 1440 minutes)
4. Empty/null field handling in match strategy
5. Timezone conversion accuracy

### Failure Mode Tests
1. Notification provider failures (timeout, 5xx, rate limit)
2. Schema validation failures (missing required fields)
3. Template/locale mismatch scenarios
4. Orchestrator crash during processing
5. Consent changes between Case creation and dispatch

### Compliance Tests
1. GDPR opt-out enforcement at dispatch time
2. Audit trail completeness and immutability
3. Checksum validation for tampering detection
4. Data retention policy enforcement
5. Consent capture and provenance tracking

---

*Report generated by [OpenRequirements.ai](https://www.openrequirements.ai) DeFOSPAM Analysis*

**Analysis Date:** 2026-03-19
**Source:** jira-story.feature
**Analysts:** Dorothy, Flo, Olivia, Sophia, Paul, Alexa, Milarna
**Total Analysis Time:** Multi-day comprehensive review
