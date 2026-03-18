# DeFOSPAM Analysis Report
**Subject:** OpenRequirements.AI — DeFOSPAM SKILL.md Specification
**Analysed:** 2026-03-16
**Tool:** OpenRequirements.ai DeFOSPAM v1.0
**Analysts:** Dorothy · Flo · Olivia · Sophia · Paul · Alexa · Milarna

---

## Executive Summary

| Metric | Count |
|---|---|
| **Total findings (pre-deduplication)** | 80 |
| **Unique findings (post-deduplication)** | 47 |
| **Critical** | 18 |
| **Major** | 21 |
| **Minor** | 8 |
| **Features identified** | 24 |
| **Scenarios created** | 35 |
| **Glossary terms proposed** | 25 |

> **Key message:** The DeFOSPAM SKILL.md specification contains several critical self-referential contradictions (notably: "all 7 analysts always run" contradicting Targeted Analysis Mode, and "THREE required outputs" contradicting Pipeline mode), an entirely undefined execution step (Step 4), and a systematic misalignment between the severity classification scale and the confidence filter threshold that makes Minor severity and most Major severity findings unreachable. Twenty-four features were identified but several critical ones (Previous Run Storage, Pre-commit Hook contract, Step 4) have no implementation specification.

---

## Proposed Glossary

| Term | Definition | Status |
|---|---|---|
| **DeFOSPAM** | 7-step mnemonic: Definitions, Features, Outcomes, Scenarios, Predictions, Ambiguity, Missing. Framework from the Business Story Method. | Verified — but acronym never explicitly decoded in document |
| **Business Story Method** | Requirements engineering methodology by Paul Gerrard and Susan Windsor; DeFOSPAM is a component framework. | Verified |
| **Feature** | A distinct, user-observable capability that delivers business value and can be described by one or more business stories. | **Unverified — never formally defined** |
| **Finding** | A reported issue, gap, or observation produced by an analyst agent, characterised by confidence, severity, type, and recommendation. | **Unverified — never formally defined** |
| **Analyst** | The logical role/persona examining requirements from one DeFOSPAM perspective. | **Unverified — conflated with "Agent"** |
| **Agent** | The execution unit — a subagent process in Claude Code, or an inline pass in Claude.ai. | **Unverified — conflated with "Analyst"** |
| **Business Story** | Output artefact: "As a [role] I want [action] So that [benefit]" enriched with Given/When/Then scenarios. | Verified — format only; distinction from User Story undefined |
| **User Story** | Input artefact in "As a... I want... So that..." format. Shares identical syntax with Business Story. | Verified — input vs output distinction absent |
| **Outcome** | System result classified as Output, State Change, Communication, or Null Outcome. | **Four types listed but none defined** |
| **Confidence Level** | Numeric score 1–10 for analyst certainty. Only scores >= 7 are reported. | Verified — values 1–6 undefined |
| **Severity** | Critical (8–10), Major (4–7), Minor (1–3). **Note: tied to confidence scale — two orthogonal concepts conflated.** | Verified — but definition is incorrect |
| **Provocation Technique** | Method where Paul proposes one realistic and one absurd alternative outcome to force stakeholder clarification. | Verified |
| **CRUD** | Create, Read, Update, Delete — fundamental data lifecycle operations. | **Unverified — acronym never expanded** |
| **NFR** | Non-Functional Requirement — quality attributes such as performance, security, scalability. | **Unverified — abbreviation never expanded** |
| **Execution Mode** | Claude Code (parallel subagents) vs Claude.ai (sequential inline). | Verified — detection mechanism undefined |
| **Deduplication** | Keep highest-confidence finding when multiple analysts flag the same issue. | Verified — "same issue" never defined |
| **Phase** | Discrete execution grouping in Claude Code mode. Phase 1: Dorothy+Flo; Phase 2: Olivia+Sophia+Alexa; Phase 3: Paul+Milarna; Phase 4: Aggregate. | Verified — dependency rationale undocumented |

---

## Business Stories

### Feature: Requirements Ingestion
*As a requirements analyst I want to provide requirements in any supported format
So that I can validate requirements regardless of how they were originally authored*

```
Scenario: Successful ingestion of a PDF document
  Given a user has a requirements document in PDF format
  When the user submits the document to DeFOSPAM
  Then the system confirms receipt and scope before running any analysts

Scenario: Unsupported format rejected
  Given a user submits a .xlsx or .pptx file
  When DeFOSPAM attempts to parse the file
  Then the system rejects the input with a clear error message listing supported formats

Scenario: Empty document
  Given a user submits an empty document or blank text
  When DeFOSPAM attempts to parse the input
  Then the system notifies the user that no content was detected and halts execution
```

---

### Feature: Full DeFOSPAM Analysis (Default Mode)
*As a requirements analyst I want all 7 DeFOSPAM analysts to run against my requirements
So that I receive comprehensive coverage across all quality dimensions*

```
Scenario: All 7 analysts complete successfully
  Given a valid requirements document has been ingested
  When DeFOSPAM executes the full analyst pipeline
  Then all 7 analysts produce findings and the report is generated

Scenario: One analyst produces no findings
  Given a well-formed requirements document
  When a specific analyst completes her analysis
  Then she returns an empty findings array and the system records she ran with zero findings

Scenario: An analyst fails during execution
  Given DeFOSPAM is running in parallel mode
  When an analyst in Phase 1 fails before producing output
  Then the system records the failure, continues with remaining analysts,
  And surfaces an error in the final report (MISSING — behaviour unspecified)
```

---

### Feature: Targeted Analysis Mode
*As a requirements analyst I want to request only a subset of the 7 analysts
So that I can focus on a specific concern without running the full analysis*

```
Scenario: User selects specific analysts
  Given a user specifies targeted mode and selects only Alexa and Milarna
  When DeFOSPAM executes
  Then only Alexa and Milarna run

Scenario: User selects analysts with unmet dependencies
  Given a user selects only Paul (who depends on Sophia and Olivia)
  When DeFOSPAM attempts targeted execution
  Then the outcome is UNDEFINED — dependency handling not specified
```

---

### Feature: Diff / Comparison Mode
*As a requirements analyst I want to compare the current analysis against a previous run
So that I can track which findings are new, resolved, recurring, or changed*

```
Scenario: Previous run exists
  Given a previous run's findings exist in storage
  When the user runs DeFOSPAM in diff mode
  Then each finding is tagged as New, Resolved, Recurring, or Changed

Scenario: No previous run stored
  Given no previous run data exists in storage
  When the user invokes DeFOSPAM in diff mode
  Then the system notifies the user that no baseline exists
  And treats all findings as New (MISSING — behaviour unspecified)

Scenario: Finding changes confidence level between runs
  Given a finding was recorded at confidence 8 in the previous run
  When the current run produces the same finding at confidence 9
  Then the finding is tagged Changed (MISSING — Changed vs Recurring criteria undefined)
```

---

### Feature: Pipeline / CI-CD Mode
*As a DevOps engineer I want DeFOSPAM to output structured JSON with appropriate exit codes
So that the analysis can be integrated into automated CI/CD pipelines*

```
Scenario: Pipeline mode — clean requirements
  Given DeFOSPAM is invoked in pipeline mode and no qualifying findings are produced
  When the analysis completes
  Then the process exits with code 0 and outputs an empty findings JSON array

Scenario: Pipeline mode — critical findings
  Given DeFOSPAM is running in pipeline mode
  When Critical findings are produced
  Then the process exits with a non-zero exit code (MISSING — exit code value unspecified)

Scenario: Pipeline mode — major findings only
  Given DeFOSPAM is running in pipeline mode
  When only Major findings are produced (no Critical)
  Then the exit code is UNDEFINED — not specified in requirements
```

---

### Feature: Pre-commit Hook Mode
*As a developer I want DeFOSPAM to run as a pre-commit hook
So that requirements quality is enforced automatically before code is committed*

```
Scenario: Changed requirements files with critical issues
  Given a developer has staged changes to a requirements file
  When the pre-commit hook fires
  Then DeFOSPAM runs and exits with a non-zero code blocking the commit
  (MISSING — which severity levels trigger non-zero exit is unspecified)

Scenario: No requirements files staged
  Given a developer stages only source code files
  When the pre-commit hook fires
  Then DeFOSPAM skips execution and exits with code 0
```

---

## Findings by DeFOSPAM Principle

---

### D — Definitions (Dorothy)

#### [CRITICAL] 'User Story' and 'Business Story' Share Identical Format — Distinction Undefined
**Confidence:** 10 | **Analyst:** Dorothy

The skill accepts 'user story' as an *input* type and produces 'business story' as an *output* artefact — both using the identical `As a... I want... So that...` syntax. No distinction is made between them.

**Impact:** The tool could be fed its own outputs as inputs, creating circular analysis. Implementers cannot determine when an `As a...` statement is raw input or a validated deliverable.

**Recommendation:** Formally define 'user story' (input) and 'business story' (output). Specify what transformations elevate a user story to a business story.

---

#### [CRITICAL] Four Outcome Types Listed but Not Defined
**Confidence:** 10 | **Analyst:** Dorothy (confirmed by Alexa)

Olivia is instructed to classify outcomes as Output | State Change | Communication | Null Outcome, but none of these four types is defined anywhere in the requirements.

**Impact:** Two independent implementations of Olivia could produce different categorisations for the same requirement, making outcomes analysis non-deterministic.

**Recommendation:** Provide a one-sentence definition and at least one example for each of the four outcome types. Clarify the Output vs. Communication boundary.

---

#### [CRITICAL] Severity Mechanically Derived from Confidence — Two Orthogonal Concepts Conflated
**Confidence:** 9 | **Analyst:** Dorothy (amplified by Paul, confidence 10)

Severity is defined as: Critical = confidence 8–10, Major = confidence 4–7, Minor = confidence 1–3. Since confidence filter discards findings below 7, **Minor severity findings can never appear, and most Major findings (confidence 4-6) are silently discarded.**

**Impact:** The severity classification system is functionally broken. Minor and most Major severity designations are unreachable dead code.

**Recommendation:** Decouple severity from confidence. Define severity independently based on business impact. Retain confidence as a separate signal about analyst certainty.

---

#### [CRITICAL] 'Feature' Is Central to the Methodology but Never Defined
**Confidence:** 9 | **Analyst:** Dorothy (confirmed by Alexa)

'Feature' is the primary output unit of Flo's analysis and the basis for all business stories, yet it is never formally defined. No size, scope, or granularity heuristic is provided.

**Impact:** Analysts may identify wildly different numbers of features from the same requirements, making the output non-repeatable.

**Recommendation:** Define 'feature' formally, including its relationship to scenarios (a feature has one or more scenarios) and business stories (each feature has exactly one business story).

---

#### [MAJOR] DeFOSPAM Acronym Never Explicitly Expanded
**Confidence:** 9 | **Analyst:** Dorothy

The document introduces DeFOSPAM as a "7-step mnemonic framework" but never decodes the mnemonic letter by letter.

**Recommendation:** Add an explicit table mapping each letter of DeFOSPAM to its corresponding principle and analyst agent.

---

#### [MAJOR] 'Agent' and 'Analyst' Used Interchangeably Without Definition
**Confidence:** 9 | **Analyst:** Dorothy (confirmed by Alexa)

The document uses 'analyst agents', 'agents', 'analysts', and 'specialist' interchangeably, but in Claude Code mode 'agent' means a spawned subprocess while 'analyst' means a logical role. These are different things in different execution modes.

**Recommendation:** Define 'analyst' (logical role) and 'agent' (execution unit) as distinct terms. Use them consistently.

---

#### [MAJOR] CRUD and NFR Abbreviations Never Expanded
**Confidence:** 8 | **Analyst:** Dorothy

Both 'CRUD' and 'NFR' are used without expansion. Business stakeholders unfamiliar with these terms will not understand what Milarna is checking for.

**Recommendation:** Expand on first use: "CRUD (Create, Read, Update, Delete)" and "NFRs (Non-Functional Requirements)".

---

---

### F — Features (Flo)

#### [CRITICAL] Previous Run Storage Is an Implied but Entirely Undescribed Feature
**Confidence:** 9 | **Analyst:** Flo

Diff / Comparison Mode requires 'compare to last run', but no storage mechanism is described anywhere. There is no specification of where runs are stored, in what format, how they are identified, or how long they are retained.

**Recommendation:** Add an explicit feature specification for run persistence: storage location, format (likely the pipeline JSON output), run identifier scheme, retention policy, and retrieval syntax.

---

#### [CRITICAL] Step 4 (Compile Business Stories) Has No Requirements
**Confidence:** 9 | **Analyst:** Milarna (also noted by Flo)

Step 4 appears in the framework heading but contains zero specification — no inputs, transformation logic, output schema, or relationship to analyst findings. It is a black box.

**Impact:** Implementers have no basis for building Step 4. Since Step 5 (Report) depends on Step 4 output, Step 5 is also partially unimplementable.

**Recommendation:** Fully specify Step 4: inputs (which analyst outputs), transformation (aggregation rules, formatting), output schema (Business Story artefact definition), and feed into Step 5 reports.

---

#### [MAJOR] Seven Analyst Agents Described at Inconsistent Levels of Granularity
**Confidence:** 8 | **Analyst:** Flo

Some analysts have precisely enumerated detection rules (Alexa: specific weasel words listed; Olivia: four named outcome classifications), while others are described only at a high level (Paul: "checks that every scenario has a predictable outcome" — no algorithm given; Milarna: "systematic completeness check" — no checklist defined).

**Recommendation:** Standardise the specification depth for all seven analysts. Each should have: defined input, enumerated detection rules, defined output schema, and at least one example finding.

---

#### [MAJOR] No User Role Taxonomy Defined
**Confidence:** 8 | **Analyst:** Flo

The requirements describe at least three distinct user archetypes (interactive analyst, pipeline engineer, developer using pre-commit hook) but no role taxonomy exists. Different roles have different output needs and invocation patterns.

**Recommendation:** Define the user role taxonomy. For each role, specify the default execution mode, preferred output format, and any role-specific filtering of findings.

---

#### [MAJOR] Targeted Analysis Mode Dependency Chain Unspecified
**Confidence:** 8 | **Analyst:** Flo

Paul depends on Sophia and Olivia. Sophia depends on Flo. If a user requests only Paul, the system has no described behaviour for handling unmet dependencies (auto-include, warn-and-proceed, or block).

**Recommendation:** Define a dependency graph for the 7 analysts and specify the resolution strategy when a targeted run omits required upstream analysts.

---

---

### O — Outcomes (Olivia)

#### [CRITICAL] Pipeline Mode Directly Contradicts 'THREE Required Outputs' Rule
**Confidence:** 10 | **Analyst:** Paul (confirmed by Olivia, confidence 10)

Step 5 declares "THREE required outputs" (chat, .md, .html) with no conditionality. Pipeline/CI-CD Mode states "JSON only, no chat/md/html" — a direct contradiction with no reconciliation statement.

**Recommendation:** Define Pipeline mode as an explicit override of the Step 5 output contract. State that "THREE required outputs applies to Default Mode only." Define the JSON schema, write target (stdout vs file), and whether any files are created on disk in pipeline mode.

---

#### [CRITICAL] Finding Deduplication Is a Silent State Change
**Confidence:** 9 | **Analyst:** Olivia

Deduplication silently removes findings from the collection with no requirement to log or surface which findings were removed. Data loss of potentially valid multi-perspective findings occurs invisibly.

**Recommendation:** Define whether deduplicated findings are discarded silently or surfaced in a deduplication log. Specify that findings from different analysts on the same topic (but different finding_types) are NOT duplicates.

---

#### [MAJOR] Confidence Filtering Silently Discards Sub-Threshold Findings
**Confidence:** 9 | **Analyst:** Olivia

Findings below confidence 7 vanish without trace. There is no requirement to inform the user how many findings were filtered or what they were.

**Recommendation:** Add a requirement: the system should report a count of filtered findings per analyst, or provide an optional verbose mode surfacing sub-threshold findings with a clear label.

---

#### [MAJOR] Scope Confirmation Output Underspecified
**Confidence:** 9 | **Analyst:** Olivia (confirmed by Alexa, Paul)

Step 1 states "briefly confirm the scope" but does not define what scope confirmation contains, whether it requires user acknowledgement before proceeding, or what happens if the user rejects the scope.

**Recommendation:** Define scope confirmation content (e.g., document source, input type, mode detected). Specify whether it is blocking (user must confirm) or informational. Define the rejection path.

---

#### [MAJOR] Subagent Spawning Has No Error Handling
**Confidence:** 9 | **Analyst:** Olivia (amplified by Paul, confidence 9; Sophia, confidence 9)

In Claude Code parallel execution, no fallback is defined for when a subagent fails to return results. The phased dependency model means a Phase 1 failure could cascade silently into Phase 2.

**Recommendation:** Define error outcomes for subagent failure: retry once, skip the failing analyst and note it, surface a warning in the final report, or abort the run. Define what constitutes a retryable vs terminal failure.

---

#### [MINOR] Analyst Persona Presentation Is a Hanging Output Outcome
**Confidence:** 7 | **Analyst:** Olivia

Analyst personas (names, avatars, bylines) are implied as output by the finding JSON schema, but no explicit requirement states when, where, or how they are displayed in the three output formats.

**Recommendation:** Add an explicit requirement: "Each finding in all output formats shall display the analyst name, byline, and avatar image." Specify fallback if an avatar URL is unreachable.

---

---

### S — Scenarios (Sophia)

*Note: Sophia's scenario findings were largely absorbed by Paul (Prediction) analysis. See Paul's findings for the critical scenario gaps. Sophia identified 35 scenarios across 14 features — see sophia-scenarios.json.*

#### [CRITICAL] No Scenario for Cascading Phase Failure
**Confidence:** 9 | **Analyst:** Sophia (amplified by Paul)

No scenario is defined for what happens when a Phase 1 analyst fails and Phase 2 analysts have missing upstream data. See Paul's "Subagent Failure Has No Defined Fallback" finding.

#### [CRITICAL] What Constitutes a 'Same Finding' for Deduplication Is Undefined
**Confidence:** 9 | **Analyst:** Sophia (amplified by Alexa confidence 10, Paul confidence 9)

See Alexa's finding: "Undefined Term: 'Same Issue' in Deduplication Rule."

---

---

### P — Prediction (Paul)

#### [CRITICAL] Severity-Confidence Filter Creates Unreachable Classifications
**Confidence:** 10 | **Analyst:** Paul

The confidence filter (report only >= 7) and severity scale (Minor=1-3, Major=4-7, Critical=8-10) use overlapping numeric ranges on what should be independent axes. Result: Minor severity is completely unreachable; most Major findings (confidence 4-6) are silently discarded.

**Provocation:**
- *Realistic:* Developer treats them as the same scale and drops everything below Critical, breaking the entire severity taxonomy.
- *Absurd:* System outputs every finding as Critical to satisfy both constraints simultaneously.

**Recommendation:** Explicitly state that severity and confidence are independent properties. Define severity based on business impact criteria, not confidence score ranges.

---

#### [CRITICAL] Pre-commit Hook Exit Code Contract Entirely Undefined
**Confidence:** 10 | **Analyst:** Paul (confirmed by Olivia, Sophia)

The entire pre-commit hook behaviour is described in four words: "Pre-commit hook: exit code based." No specification exists for which severity levels trigger non-zero exit, what output is written, how the hook relates to Pipeline mode, or whether any configuration is supported.

**Provocation:**
- *Realistic:* Exit 1 on Critical findings, exit 0 otherwise — matching standard pre-commit conventions.
- *Absurd:* Exit code equals the total number of findings found, causing commits to always fail once any requirements exist.

**Recommendation:** Define the full exit code contract: pass condition, block condition with severity threshold explicitly stated, output format during hook execution, and relationship to Pipeline mode.

---

#### [CRITICAL] Deduplication Identity Criteria Produce Unpredictable Merging
**Confidence:** 9 | **Analyst:** Paul (confirmed by Alexa confidence 10, Sophia confidence 9)

"Keep highest confidence" as a deduplication rule requires a definition of 'same issue'. Dorothy flags a term as "undefined_term" (confidence 8). Alexa flags the same term as "ambiguous_term" (confidence 9). Are these the same issue? No rule exists to decide.

**Provocation:**
- *Realistic:* Aggregator uses semantic similarity, keeps Alexa's finding, and discards Dorothy's specific "undefined_term" classification.
- *Absurd:* All findings mentioning the same word token are merged into a single mega-finding attributed to the analyst with the alphabetically first name.

**Recommendation:** Define deduplication identity: two findings are the same issue if they reference the same text excerpt AND share the same finding_type. Findings about the same term but different finding types are distinct.

---

#### [CRITICAL] Subagent Failure Has No Defined Fallback
**Confidence:** 9 | **Analyst:** Paul

In Claude Code parallel execution, Phase 2 starts "after Phase 1." If Dorothy's subagent fails mid-execution, Phase 2 analysts receive incomplete Phase 1 data. No recovery behaviour is specified.

**Provocation:**
- *Realistic:* Phase 2 starts with whatever Phase 1 produced, Dorothy's findings are absent, report notes the analyst did not complete.
- *Absurd:* The pipeline retries Dorothy indefinitely, blocking all subsequent phases forever.

**Recommendation:** Define phase failure contract: failure aborts pipeline or continues with partial results? Failed analysts are noted in the report? Maximum retry count?

---

#### [MAJOR] Diff Mode 'Changed' vs 'Recurring' Classification Criteria Undefined
**Confidence:** 9 | **Analyst:** Paul (confirmed by Sophia)

Four diff tags are defined (New, Resolved, Recurring, Changed) but no criteria specify which finding attributes must change to trigger 'Changed' vs 'Recurring'. A finding with the same text but higher confidence could be either.

**Provocation:**
- *Realistic:* Any field change triggers 'Changed'; identical fields on all compared attributes triggers 'Recurring'.
- *Absurd:* All findings from previous runs are tagged 'Recurring' because the requirements document was analysed again.

**Recommendation:** Define the comparison key for diff identity and enumerate which field changes trigger 'Changed' vs 'Recurring'.

---

#### [MAJOR] HTML Report 'Filter by Principle' References Undefined Term
**Confidence:** 8 | **Analyst:** Paul (confirmed by Sophia)

The HTML report specifies "filter by principle" as a feature, but 'principle' is never defined anywhere in the data model, finding schema, or analyst descriptions. It does not map to any identified field.

**Provocation:**
- *Realistic:* Developer assumes 'principle' means analyst domain (D/F/O/S/P/A/M) and implements accordingly.
- *Absurd:* Developer implements it as a free-text search field on the grounds that any text could be a principle.

**Recommendation:** Define 'principle' as a finding property. If it means analyst domain, add a `principle` field to the finding schema with valid values D, F, O, S, P, A, M.

---

#### [MAJOR] Scope Confirmation Rejection Path Is Undefined
**Confidence:** 8 | **Analyst:** Paul (confirmed by Sophia, Olivia)

The scope confirmation step defines only the positive path (confirm and proceed). No specification exists for rejection, scope correction, or maximum confirmation iterations.

**Recommendation:** Define the scope confirmation contract per execution mode: blocking for interactive modes, auto-proceed for pipeline/CI-CD mode.

---

---

### A — Ambiguity (Alexa)

#### [CRITICAL] Direct Contradiction: 'All 7 Analysts Always Run' vs. Targeted Analysis Mode
**Confidence:** 10 | **Analyst:** Alexa

Step 3 states: *"All 7 analysts always run — there is no selection logic since requirements validation needs all perspectives."* The same section then states: *"The user can request specific analysts instead of running all 7."* These are irreconcilable.

**Recommendation:** Rewrite the absolute statement to read: "By default, all 7 analysts run. The user may optionally specify a subset using Targeted Analysis Mode."

---

#### [CRITICAL] 'Same Issue' in Deduplication Rule Is Undefined
**Confidence:** 10 | **Analyst:** Alexa (confirmed by Paul confidence 9)

"If multiple analysts flag the same issue, keep the highest confidence finding." 'Same issue' is never defined, making deduplication non-deterministic. *See Paul's finding for detail.*

---

#### [MAJOR] 'Briefly Confirm the Scope' Uses Vague Adverb
**Confidence:** 9 | **Analyst:** Alexa

'Briefly' does not define scope confirmation content, whether the user must respond before execution continues, or what happens if scope cannot be confirmed. Two implementations satisfying "briefly" could produce anything from a single word to a multi-paragraph summary.

**Recommendation:** Replace "briefly confirm the scope" with a specific scope confirmation specification: content required, interaction type (blocking vs informational), and failure path.

---

#### [MAJOR] Undefined Reference: 'The User' in Targeted Analysis Mode
**Confidence:** 9 | **Analyst:** Alexa

"The user can request specific analysts" — but in Claude Code programmatic mode, the mechanism for requesting differs fundamentally from Claude.ai conversational mode. No syntax, parameter, or protocol is specified for either context.

**Recommendation:** Define the request mechanism for each execution environment.

---

#### [MAJOR] 'Accept Requirements in Any Form' Is Unbounded
**Confidence:** 8 | **Analyst:** Alexa

"Accept requirements in any form the user provides." An implementer cannot determine whether they must handle binary file formats, URLs, database exports, or other non-text inputs. The parenthetical list is illustrative, not exhaustive.

**Recommendation:** Enumerate the supported input forms explicitly and state whether the list is exhaustive.

---

#### [MAJOR] Execution Mode Detection Trigger Is Undefined
**Confidence:** 8 | **Analyst:** Alexa (confirmed by Olivia)

"Claude Code: Agent tool available → Spawn parallel subagents." The mechanism for detecting 'Agent tool available' is not defined. If detection fails or produces a false positive, the wrong execution path is taken silently with no fallback.

**Recommendation:** Define the detection mechanism precisely (e.g., capability probe). Specify a default fallback (sequential) and notify the user when fallback is used.

---

---

### M — Missing (Milarna)

#### [CRITICAL] No Authentication or Authorisation Requirements
**Confidence:** 9 | **Analyst:** Milarna

Zero mention of credentials, permissions, roles, or access control. Any process could submit arbitrary documents for analysis, potentially exfiltrating sensitive requirements content to a third-party AI provider without organisational approval.

**Recommendation:** Add a Security section: permitted invokers, API credential storage and rotation policy, output artefact access control, and data-handling obligations for confidential requirements.

---

#### [CRITICAL] No Error Handling Strategy for AI Model Failures
**Confidence:** 9 | **Analyst:** Milarna (confirmed by Paul, Sophia)

No specification for: AI API unavailability, model refusal, token limit exceeded, malformed model response, or partial analyst failure. In a pre-commit hook, silent failure could either block commits indefinitely or silently pass with incomplete validation.

**Recommendation:** Define: retry policy, behaviour on malformed response, whether partial runs produce output or abort, user notification of analyst failures.

---

#### [MAJOR] No Performance Requirements
**Confidence:** 9 | **Analyst:** Milarna

No acceptable execution time, maximum document size, concurrent run limits, or API timeout handling. DeFOSPAM is intended for pre-commit hook use — a synchronous gate with unbounded latency directly hurts developer productivity.

**Recommendation:** Define maximum wall-clock time per full run, per-analyst timeout, retry behaviour on transient API failures, maximum input document size, and behaviour when time budget is exceeded.

---

#### [MAJOR] No Data Retention or Archiving Policy
**Confidence:** 9 | **Analyst:** Milarna

Report artefacts (.md, .html) and previous run data (required by Diff mode) have no retention policy, storage location, version history depth, or deletion trigger.

**Recommendation:** Define: storage location, retention period, version history depth for Diff mode, deletion trigger, and encryption requirements for sensitive content.

---

#### [MAJOR] No Audit Logging Requirements
**Confidence:** 9 | **Analyst:** Milarna

No requirement to record who ran an analysis, on which document, at what time, or what findings were produced. Diff mode implies a history concept exists but logging is never mandated.

**Recommendation:** Define an audit log: timestamp, invoker identity, document reference, analyst subset, findings count by severity, run identifier.

---

#### [MAJOR] No Data Validation Rules for Accepted Input Formats
**Confidence:** 9 | **Analyst:** Milarna

No maximum file size, encoding validation, malformed-document handling, or prompt-injection sanitisation. A crafted document could probe AI prompt injection vulnerabilities.

**Recommendation:** Add input validation rules: maximum file size per format, UTF-8 encoding requirement, behaviour on corrupt files, and prompt-injection sanitisation before sending to AI model.

---

#### [MAJOR] Missing CRUD — No Update or Delete Operations for Findings
**Confidence:** 8 | **Analyst:** Milarna

Findings are created (by analysts) and read (via reports). No requirement exists for updating a finding (acknowledging, suppressing, false-positive marking) or deleting it. Diff mode's 'Resolved' tag implies state transitions that have no implementation mechanism.

**Recommendation:** Define CRUD for the Finding entity and specify who can perform each operation.

---

#### [MAJOR] No Configuration Management Requirements
**Confidence:** 8 | **Analyst:** Milarna

No mechanism to configure confidence threshold, severity mapping, output paths, API endpoints, or analyst defaults. Every deployment must hardcode values that should be configurable.

**Recommendation:** Define a configuration contract: supported parameters, defaults, mechanism (config file, env vars, CLI flags), and runtime vs install-time configurability.

---

#### [MINOR] No Accessibility Requirements for HTML Report
**Confidence:** 8 | **Analyst:** Milarna

No WCAG conformance level, keyboard navigation, screen-reader compatibility, or colour contrast requirements for the HTML report.

**Recommendation:** Add: WCAG 2.1 AA conformance for the HTML report, keyboard-navigable filters, ARIA roles for dynamic content.

---

#### [MINOR] No Internationalisation or Localisation Requirements
**Confidence:** 8 | **Analyst:** Milarna

No supported languages, character set handling for non-Latin scripts, or RTL layout support.

**Recommendation:** State supported input languages, UTF-8 encoding mandate for all artefacts, and whether analyst findings are always produced in English.

---

#### [MINOR] No Reproducibility Requirements
**Confidence:** 7 | **Analyst:** Milarna

No requirement for deterministic output. AI model non-determinism means two runs on the same document may produce different findings, making Diff mode 'Recurring' tag ambiguous and potentially meaningless.

**Recommendation:** State whether deterministic output is required (e.g., temperature=0), how Diff mode tolerates non-determinism, and whether the HTML report must be self-contained.

---

## Summary by Severity

### Critical (18 findings)
1. [Paul] Severity-Confidence Filter Creates Unreachable Classifications
2. [Paul] Pipeline Mode Output Contract Contradicts THREE Outputs Rule
3. [Paul] Pre-commit Hook Exit Code Contract Entirely Undefined
4. [Alexa] Direct Contradiction — All 7 Always Run vs. Targeted Mode
5. [Dorothy] 'User Story' and 'Business Story' Share Identical Format
6. [Dorothy] Four Outcome Types Listed but Not Defined
7. [Alexa] Undefined Term: 'Same Issue' in Deduplication Rule
8. [Paul] Deduplication Identity Criteria Produce Unpredictable Merging
9. [Paul] Subagent Failure Has No Defined Fallback
10. [Dorothy] 'Feature' Is Central but Never Defined
11. [Dorothy] Severity Mechanically Derived from Confidence
12. [Flo] Previous Run Storage Is Implied but Entirely Undescribed
13. [Milarna] Step 4 Has No Requirements
14. [Milarna] No Authentication or Authorisation Requirements
15. [Milarna] No Error Handling Strategy for AI Model Failures
16. [Olivia] Pipeline Mode Contradicts THREE Required Outputs (duplicate of #2)
17. [Sophia] Cascading Phase Failure Undefined (sub-case of #9)
18. [Sophia] Deduplication Identity Undefined (duplicate of #7/#8)

### Major (21 findings)
See findings under each principle above.

### Minor (8 findings)
See findings under each principle above.

---

*Generated by OpenRequirements.ai DeFOSPAM v1.0 — 2026-03-16*
