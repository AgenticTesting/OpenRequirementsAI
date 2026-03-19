# Specification by Example Transformation Report

**OpenRequirements.ai SBE Methodology**

![OpenRequirements.ai](https://openrequirements.ai/logo.svg)

## Executive Summary

This report documents the complete Specification by Example (SBE) transformation of the **Disruption Notification System** for an airline passenger communication platform. Seven specialized analysts collaborated to transform raw requirements into executable specifications, concrete examples, refined requirements, automated test scenarios, and living documentation.

| Metric | Value |
|--------|-------|
| **Total Findings** | 156 |
| **Critical Findings** | 40 |
| **Major Findings** | 105 |
| **Minor Findings** | 11 |
| **Feature Files** | 10 |
| **Gherkin Scenarios** | 97 |
| **Business Goals** | 10 |
| **Examples Created** | 6 |
| **Specifications Refined** | 9 |
| **Validation Suites** | 3 (Smoke, Regression, Full) |

---

## Ubiquitous Language (Agreed Terminology)

| Term | Definition | Status |
|------|-----------|--------|
| **Disruption Detection** | Process of identifying adverse events (delays, cancellations) from operational data sources | Agreed |
| **Correlation** | Matching normalized disruption events to passenger bookings using deterministic service_no + date + origin/destination strategy | Agreed |
| **Case** | A distinct record representing a passenger journey affected by a disruption, created upon successful correlation with initial status 'Detected' | Agreed |
| **Canonical Event Schema** | Standardized data structure for normalized disruption events (event_type, service_no, service_date, origin, destination, effective_time_utc, confidence) | Agreed |
| **Idempotency Key** | Unique identifier combining Case + channel + template ensuring same notification never sent twice for same combination | Agreed |
| **Lead Contact** | Passenger designated as primary contact for booking reference and recipient of disruption notifications | Agreed |
| **Consent State** | Current permission level for passenger on specific contact channel (opt_in or opt_out) | Agreed |
| **Exactly One Compliant Passenger Notification** | Requirement ensuring exactly one outbound message delivered per Case + channel + template combination | Agreed |

---

## Business Goals

### 1. Data Integrity & Auditability
**Disruption Event Ingestion and Storage**

Preserve all disruption data for complete auditability and prevent data loss or unauthorized modification.

- **Value Statement**: System maintains immutable audit trail; regulators verify complete history
- **Success Metrics**: 
  - All raw events stored immutably with metadata
  - Audit trail is non-repudiable
  - Zero data loss events

### 2. Data Standardization
**Event Normalization to Canonical Schema**

Enable consistent downstream processing by standardizing heterogeneous disruption signals from multiple sources.

- **Value Statement**: Dev teams avoid format variations; faster feature development; fewer integration bugs
- **Success Metrics**:
  - 100% normalized events conform to canonical schema
  - Normalization errors logged without halting processing
  - Downstream systems process uniformly

### 3. Passenger Identification
**Disruption-to-Booking Correlation**

Automatically identify affected passengers without requiring manual intervention.

- **Value Statement**: Reduces support costs; faster passenger notifications; improves service reputation
- **Success Metrics**:
  - Correlation success rate >= 95%
  - Mean time to correlation < 1 second
  - Match score algorithm produces consistent results

### 4. Case Management & Prioritization
**Case Management and Severity Computation**

Enable prioritized passenger support responses by automatically assigning severity.

- **Value Statement**: Pre-prioritized workload; faster response to critical disruptions; optimized resource allocation
- **Success Metrics**:
  - Severity computation is deterministic and auditable
  - Severity-based prioritization improves resolution time
  - Ruleset versioning enables rollback

### 5. Regulatory Compliance
**Passenger Contact Consent and Channel Selection**

Ensure GDPR compliance and respect passenger preferences by only sending through channels with explicit opt-in consent.

- **Value Statement**: Avoids regulatory penalties; respects passenger preferences; builds trust
- **Success Metrics**:
  - Zero notifications sent to opt_out contacts
  - Consent verified before every dispatch
  - GDPR compliance verified through audit

### 6. Passenger Communication
**Passenger-Facing Notification Composition**

Help passengers understand disruptions and take appropriate action through clear, actionable messaging.

- **Value Statement**: Reduced support volume for clarification; improved customer satisfaction
- **Success Metrics**:
  - All required elements included (what changed, new time, Case ref)
  - Readability score meets minimum threshold
  - Support ticket reduction >= 20%

### 7. Message Delivery
**Template-Based Notification Dispatch**

Ensure consistent, professionally maintained messaging through centrally managed versioned templates.

- **Value Statement**: Centralized control; message consistency; rapid updates without code deployment
- **Success Metrics**:
  - 100% dispatched notifications use versioned templates
  - Zero hardcoded messages
  - Template updates deployable without code release

### 8. Duplicate Prevention
**Idempotent Notification Deduplication**

Prevent passenger spam by ensuring duplicate disruption signals result in zero duplicate notifications.

- **Value Statement**: Passengers receive each notification exactly once; avoids complaint spam; prevents message fatigue
- **Success Metrics**:
  - Duplicate signals produce zero duplicates
  - Idempotency key collision rate = 0
  - Exactly-once delivery verified in audit logs

### 9. Passenger Experience Protection
**Quiet Hours and Urgent Message Exemptions**

Balance passenger experience by respecting quiet hours while allowing critical service information through.

- **Value Statement**: Passengers not disturbed during sleep; urgent messages still reach them
- **Success Metrics**:
  - Quiet hours enforced for non-critical messages
  - Service-critical messages bypass 100% of time
  - Complaint volume for unwanted notifications decreases >= 30%

### 10. Audit & Traceability
**Comprehensive Case Timeline Auditing**

Enable regulatory compliance and forensic investigation through immutable, complete record of case state changes.

- **Value Statement**: Regulatory confidence; forensic capability; due diligence demonstration
- **Success Metrics**:
  - Timeline is append-only with strict ordering
  - Zero gaps or missing events
  - Every Case state change recorded with reason

---

## Executable Specifications (Feature Files)

### Architecture Layers

**Ingestion Layer** (1 feature)
- Disruption Event Ingestion: Raw event immutability, checksums, audit trails

**Processing Layer** (3 features)
- Event Normalization: Schema validation, field standardization
- Disruption Correlation: Deterministic matching, confidence scoring
- Case Management: Severity computation, ruleset versioning

**Notification Layer** (5 features)
- Notification Eligibility: Consent-based channel filtering, GDPR compliance
- Notification Composition: Message content with required elements
- Notification Dispatch: Template-based delivery, exactly-once guarantee
- Notification Deduplication: Idempotency-key based duplicate suppression
- Quiet Hours: Locale-specific quiet hours with service-critical exemptions

**Compliance Layer** (1 feature)
- Case Timeline: Immutable append-only event log for auditability

### Feature Summary

| Feature | Scenarios | Status | Key Requirement |
|---------|-----------|--------|-----------------|
| disruption-event-ingestion.feature | 8 | Production | Raw event immutability with checksums |
| event-normalization.feature | 9 | Production | Canonical schema conformance |
| disruption-correlation.feature | 11 | Production | Deterministic match scoring >= 0.80 |
| case-management.feature | 10 | Production | Versioned ruleset with immutable severity |
| notification-eligibility.feature | 9 | Production | Consent-based per-channel filtering |
| notification-composition.feature | 10 | Production | Required elements: what changed, new time, case ref |
| notification-dispatch.feature | 10 | Production | Exactly-once delivery guarantee |
| notification-deduplication.feature | 9 | Production | Idempotency key suppression |
| quiet-hours.feature | 9 | Production | Service-critical bypass (CANCELLATION, Critical severity) |
| case-timeline.feature | 12 | Production | Append-only immutable timeline |
| **TOTAL** | **97** | **All Production** | **10 distinct business capabilities** |

---

## Validation Strategy

### Smoke Suite (< 5 minutes)
- **8 scenarios**: Critical path on every commit
- **Covers**: Event ingestion, normalization, correlation, case creation, eligibility, dispatch, deduplication, timeline
- **Purpose**: Catch regressions immediately before pushing
- **Examples**:
  - Delay detection → correlation → SMS notification (happy path)
  - CANCELLATION creates Major severity Case
  - Opt-out consent blocks notification
  - CANCELLATION bypasses quiet hours

### Regression Suite (< 30 minutes)
- **25 scenarios**: All smoke + edge cases and boundaries
- **Covers**: Smoke suite + boundary values (match_score 0.80, delay 1 min, deep link TTL 120 min)
- **Purpose**: Validation before merge to main
- **Includes**: Error paths, normalization failure, provider failure

### Full Validation (< 2 hours)
- **40 scenarios**: All regression + multi-leg journeys, extreme boundaries, error recovery
- **Purpose**: Nightly run and pre-release validation (informational, doesn't block)
- **Includes**: Multi-leg correlation, timezone-aware quiet hours, template versioning

---

## Findings by Pattern (SBE Process)

### G - Goals Analyst (Grace)
**10 findings** on business goal clarity and success metric definition
- Severity criteria unmeasurable
- Idempotency key algorithm undefined
- Canonical schema definition missing
- Notification retry strategy absent

### S - Collaboration Analyst (Chris)
**35 findings** on terminology conflicts and three-amigos facilitation
- Ubiquitous language ambiguities
- Workshop questions for unresolved terms
- Cross-perspective clarifications needed

### I - Examples Analyst (Isabel)
**12 findings** on concrete examples and boundary cases
- Abstract severity rules need concrete thresholds
- Boundary examples for match_score (0.79 vs 0.80)
- Deep link TTL boundary (119/120/121 minutes)
- Multi-leg journey examples missing

### R - Refinement Analyst (Rex)
**10 findings** on precise specification and algorithm definition
- Severity ruleset specification needed
- Idempotency key hash algorithm (SHA256)
- Match score calculation formula
- Service-critical classification criteria

### A - Automation Analyst (Angie)
**20 findings** on test framework, shared steps, and automation patterns
- Shared step opportunities (event creation, immutability, audit log)
- Test database isolation strategy
- Mock provider failure injection
- Multi-leg journey test coverage gap

### V - Validation Analyst (Victoria)
**15 findings** on test suite assignment and reliability concerns
- Smoke/regression/full suite structure
- External dependency flakiness (Twilio timeouts)
- Timing-sensitive test requirements (clock mocking)
- Database constraint enforcement verification

### L - Living Documentation Analyst (Laveena)
**54 findings** on documentation structure and accessibility
- Folder structure organization
- Cross-feature dependencies
- Severity ruleset document missing
- Idempotency implementation details
- Notification UX design guide
- Tag taxonomy enforcement

---

## Key Concrete Examples

### Example 1: Delay Detection Happy Path
**Flight DL427 delayed 45 minutes → Passenger Robert Chen notified via SMS**

- Event: DELAY on DL427 (ATL→LAX), +45 min, confidence 0.92
- Correlation: Matches booking BK-2026-DL427-0319 with score 0.95
- Case Created: C42891, Severity=Major (from ruleset v2.1)
- Eligibility: SMS opt_in consent from capture date 2025-12-01
- Composition: "Your DL427 to LAX is now delayed 45 min, new ETA 3:15 PM (Case: C42891)"
- Deep Link: case-ref.xyz/C42891 (expires in 120 min)
- Timeline: Case created → SMS composed → dispatch attempted → provider accepted

### Example 2: Duplicate Suppression
**Same disruption event ingested twice → Only one SMS sent**

- First ingestion: Creates Case C42891, SMS queued
- Idempotency key: C42891 + SMS + DELAY_SINGLE_LEG_SMS_v2
- Second ingestion: Same event correlates to same Case
- Deduplication check: Idempotency key found in dispatch_history
- Result: SMS suppressed, timeline records "duplicate_suppressed" event

### Example 3: Consent Blocking
**Passenger Maria Santos opts out of SMS → No SMS sent**

- Case created for affected booking
- Eligibility check: SMS channel, consent_state=opt_out
- Result: Channel blocked, no SMS queued
- Timeline: Case status transitions to "Notification_Blocked_By_Consent"

### Example 4: Service-Critical Exemption
**CANCELLATION at 23:30 UTC during quiet hours (22:00-06:00 UTC) → Dispatches immediately**

- Quiet hours configured: 22:00 UTC - 06:00 UTC
- Disruption type: CANCELLATION (service-critical)
- Current time: 2026-03-19T23:30:00Z (within quiet hours)
- Quiet hours check: event_type=CANCELLATION → bypass quiet hours
- Result: SMS dispatches immediately, not deferred

---

## Recommendations by Priority

### CRITICAL (Implement Before Launch)
1. **Severity Ruleset Specification**: Define all severity levels with decision tree and thresholds
2. **Idempotency Key Algorithm**: Specify SHA256(case_id + ':' + channel + ':' + template_version)
3. **Canonical Schema**: Publish complete field list with types, constraints, validation rules
4. **Multi-Leg Journey Handling**: Decide MVP scope (single-leg only vs. multi-leg support)
5. **Database Immutability Constraints**: Enforce append-only and immutable tables at database layer
6. **CI/CD Pipeline**: Implement three-stage validation (smoke, regression, full)

### MAJOR (Implement in MVP)
1. **Notification Retry Strategy**: Exponential backoff with max attempts and fallback channels
2. **Clock Mocking in Tests**: Use TestClock for quiet hours and TTL tests
3. **Mock Provider Implementations**: Twilio SMS and email service mocks with failure injection
4. **Service-Critical Classification**: Define explicit criteria (event_type, severity level)
5. **Test Data Fixtures**: Create timezone-aware test data for multi-locale validation

### MINOR (Implement Post-MVP)
1. **Notification Content Design Guide**: Format specs for SMS, email, push channels
2. **Documentation Structure**: Organize features into ingestion/processing/notification/compliance folders
3. **Tag Taxonomy Enforcement**: Standardize @smoke/@regression/@full tagging
4. **Business Rationale Documentation**: Explain why specific thresholds exist
5. **Recovery Process Documentation**: Manual escalation and retry procedures

---

## Traceability

**DeFOSPAM Findings Coverage**: 79.6% of 54 critical/major findings addressed by feature scenarios

**Business Goal Alignment**: 100% (all 10 goals mapped to features with measurable success metrics)

**Example Coverage**: 6 concrete examples cover happy path, duplicates, consent, cancellation, multi-passenger, quiet hours

**Scenario-to-Finding Mapping**:
- 45 scenarios address critical findings
- 35 scenarios address major findings
- 17 scenarios address minor findings

---

## Footer

**Report Generated**: 2026-03-19T14:59:00Z

**Methodology**: Specification by Example by Gojko Adzic

**Analysts**: Grace (Goals), Chris (Collaboration), Isabel (Examples), Rex (Refinement), Angie (Automation), Victoria (Validation), Laveena (Documentation)

**Tool**: OpenRequirements.ai SBE Aggregator v1.0

---

*For detailed findings, scenario breakdowns, and implementation guidance, see sbe-results.json and sbe-report.html*
