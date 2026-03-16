<p align="center">
  <img src="https://openrequirements.ai/img/or-logo.png" alt="OpenRequirements.ai" height="80">
</p>

<h1 align="center">DeFOSPAM — AI Requirements Validation Skill</h1>

<p align="center">
  <strong>7 specialized AI analyst agents that validate your requirements using the DeFOSPAM methodology</strong>
</p>

<p align="center">
  <a href="https://openrequirements.ai"><img src="https://openrequirements.ai/assets/logo-nlGhAN5y.png" alt="OpenRequirements.ai"></a>
  <img src="https://img.shields.io/badge/agents-7-purple?style=flat-square" alt="7 Agents">
  <img src="https://img.shields.io/badge/methodology-DeFOSPAM-green?style=flat-square" alt="DeFOSPAM">
  <img src="https://img.shields.io/badge/platform-Claude%20Code%20%7C%20Cowork%20%7C%20Claude.ai-orange?style=flat-square" alt="Claude Code | Cowork | Claude.ai">
  <img src="https://img.shields.io/badge/license-open--source-brightgreen?style=flat-square" alt="Open Source">
</p>

---

## What is DeFOSPAM?

**DeFOSPAM** is a 7-step mnemonic framework from the **Business Story Method** by Paul Gerrard (Gerrard Consulting) and Jonathon Wright (OpenTest.AI). Each letter represents a principle for validating software requirements:

| Letter | Principle | Core Question |
|:---:|---|---|
| **D** | Definitions | Are all terms clearly defined and agreed? |
| **e** | *(connector)* | — |
| **F** | Features | What features does the system need? |
| **O** | Outcomes | What are all possible outcomes per feature? |
| **S** | Scenarios | What scenarios trigger each outcome? |
| **P** | Prediction | Can we predict the outcome for every scenario? |
| **A** | Ambiguity | Is the language clear and consistent? |
| **M** | Missing | What's been left out? |

The goal is simple: **a perfect requirement enables the reader to predict the behaviour of every feature in all circumstances.** DeFOSPAM systematically finds where that breaks down.

---

## The 7 Analyst Agents

This skill deploys seven specialized AI analyst agents — one per DeFOSPAM principle — that each examine your requirements from a different angle:

| Agent | Principle | What They Do |
|---|---|---|
| **Dorothy** | Definitions | Builds a glossary, finds undefined terms, catches synonym collisions and ambiguous terminology |
| **Flo** | Features | Identifies features, creates business stories (As a… I want… So that…), checks for decomposition needs |
| **Olivia** | Outcomes | Maps every outcome (outputs, state changes, communications, null outcomes) and finds "hanging" outcomes |
| **Sophia** | Scenarios | Creates Given/When/Then scenarios, data-driven scenario tables, and identifies edge cases |
| **Paul** | Prediction | Checks that every scenario has a predictable outcome; uses the provocation technique for gaps |
| **Alexa** | Ambiguity | Detects vague language, weasel words, contradictions, and inconsistencies |
| **Milarna** | Missing | Performs the final completeness sweep — CRUD coverage, missing NFRs, cross-cutting concerns |

Each agent reports findings with confidence scores (7–10 scale), severity ratings, and actionable recommendations.

---

## What You Get

When you run DeFOSPAM against your requirements, you receive **three outputs**:

1. **Chat summary** — findings displayed inline in the conversation
2. **Markdown report** (`defospam-report.md`) — structured report with glossary, business stories, and findings
3. **HTML report** (`defospam-report.html`) — dark-mode styled report with summary cards, filtering by principle, analyst avatars, and severity badges

Each report includes:

- A **proposed glossary** with verified/unverified definitions
- **Business stories** in Given/When/Then format for every identified feature
- **Findings** grouped by DeFOSPAM principle with severity, confidence, and recommendations
- An **executive summary** with counts by principle and severity

---

## Installation

### Claude Code (Recommended)

**Quick install — project level:**
```bash
# Clone and install in one step
git clone https://github.com/AgenticTesting/OpenRequirementsAI.git
mkdir -p .claude/skills
cp -r OpenRequirementsAI/defospam .claude/skills/openrequirements
```

**Or as a git submodule (keeps it updatable):**
```bash
git submodule add https://github.com/AgenticTesting/OpenRequirementsAI.git .claude/skills/openrequirements
```

**Global install (available in all your projects):**
```bash
mkdir -p ~/.claude/skills/openrequirements
cp path/to/SKILL.md ~/.claude/skills/openrequirements/SKILL.md
```

Once installed, the `/openrequirements` slash command becomes available in Claude Code:

```
> /openrequirements docs/PRD.md
```

You can also just mention requirements validation naturally and Claude Code will detect and invoke the skill automatically.

**Optional: Register in settings.json**

For explicit control over triggering, add to `.claude/settings.json`:

```json
{
  "skills": {
    "openrequirements": {
      "path": ".claude/skills/openrequirements/SKILL.md",
      "description": "DeFOSPAM requirements validation with 7 AI analyst agents",
      "triggers": [
        "validate requirements", "DeFOSPAM", "business stories",
        "requirements validation", "find ambiguity", "specification by example"
      ]
    }
  }
}
```

### Claude Cowork

Place the `openrequirements/` folder (containing `SKILL.md`) in your skills directory:

```
~/.skills/skills/openrequirements/SKILL.md
```

Or add it to your project's `.skills/skills/` folder.

### Claude.ai (Web)

Upload the `SKILL.md` file to your conversation or paste its contents when you need a DeFOSPAM analysis. The skill runs sequentially in this environment (no parallel agents).

---

## Usage

### Interactive (Claude Code / Cowork / Claude.ai)

Once installed, the skill triggers automatically when you mention requirements validation:

```
Validate these requirements using DeFOSPAM
```

```
Check this specification for ambiguity and missing elements
```

```
Create business stories from these requirements
```

```
Find gaps in this requirements document
```

You can also upload a `.docx`, `.pdf`, `.md`, or `.txt` requirements file and ask for a DeFOSPAM analysis.

### Slash Command (Claude Code)

Once installed, invoke directly in any Claude Code session:

```
> /openrequirements docs/PRD.md
> /openrequirements                   # then paste or describe requirements
```

### CLI Agent Mode (Claude Code)

Run DeFOSPAM as a headless agent from your terminal:

```bash
# Full analysis of a requirements file
claude -p "Use /openrequirements to analyze docs/PRD.md"

# Targeted analysis — specific agents only
claude -p "Use /openrequirements to run only the Ambiguity and Missing analysts on spec.md"

# Diff mode — compare against previous analysis
claude -p "Use /openrequirements to re-analyze docs/PRD.md and diff against previous run"

# Pipeline mode — JSON output for CI/CD integration
claude -p "Use /openrequirements in pipeline mode on requirements.md, output only JSON"

# Batch analysis — multiple files
claude -p "Use /openrequirements on each .md file in ./requirements/, save reports to ./reports/"
```

### Pre-Commit Hook

Automatically validate requirements before every commit:

```bash
#!/bin/bash
# .git/hooks/pre-commit
CHANGED_REQS=$(git diff --cached --name-only -- '*.md' 'docs/' 'requirements/')
if [ -n "$CHANGED_REQS" ]; then
  echo "Running DeFOSPAM validation..."
  claude -p "Use /openrequirements in pipeline mode on: $CHANGED_REQS. Exit code 1 if critical findings."
fi
```

### Targeted Analysis

You don't always need all 7 agents. Request specific analysts:

| Command | Agents |
|---|---|
| "check definitions" / "glossary check" | Dorothy only |
| "find features" / "create business stories" | Flo only |
| "check ambiguity" / "find vague language" | Alexa only |
| "what's missing" / "completeness check" | Milarna only |
| "check scenarios and predictions" | Sophia + Paul |
| "full analysis" (default) | All 7 agents |

---

## Architecture

### Parallel Agent Execution (Claude Code / Cowork)

When subagents are available, DeFOSPAM uses a 3-phase parallel execution strategy that significantly reduces total analysis time:

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Requirements                         │
│             (.docx, .pdf, .md, .txt, or text)               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─ Phase 1 ─────────────────────────────────────────────────┐
│  ┌─────────────────┐    ┌─────────────────┐               │
│  │    Dorothy       │    │      Flo        │   (parallel)  │
│  │  Definitions     │    │    Features     │               │
│  │  → Glossary      │    │  → Stories      │               │
│  └────────┬────────┘    └────────┬────────┘               │
└───────────┼──────────────────────┼────────────────────────┘
            │                      │
            ▼                      ▼
┌─ Phase 2 ─────────────────────────────────────────────────┐
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│  │  Olivia  │  │  Sophia  │  │  Alexa   │   (parallel)   │
│  │ Outcomes │  │ Scenarios│  │ Ambiguity│                 │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                │
└───────┼──────────────┼─────────────┼──────────────────────┘
        │              │             │
        ▼              ▼             ▼
┌─ Phase 3 ─────────────────────────────────────────────────┐
│  ┌─────────────────┐    ┌─────────────────┐               │
│  │      Paul       │    │    Milarna      │   (parallel)  │
│  │   Prediction    │    │    Missing      │               │
│  │  → Gap Check    │    │  → Sweep        │               │
│  └────────┬────────┘    └────────┬────────┘               │
└───────────┼──────────────────────┼────────────────────────┘
            │                      │
            ▼                      ▼
┌─ Phase 4: Aggregate ──────────────────────────────────────┐
│                                                            │
│  Deduplicate → Compile Stories → Generate Reports          │
│                                                            │
│  📋 Chat Summary          📊 defospam-results.json        │
│  📝 openrequirements-report.md                            │
│  🌐 openrequirements-report.html                         │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Sequential Execution (Claude.ai)

When subagents aren't available, agents run in DeFOSPAM order: Dorothy's glossary informs Flo's feature identification, which feeds Sophia's scenario creation, and so on. Milarna runs last to catch anything the others missed.

### Pipeline JSON Output

For CI/CD integration, DeFOSPAM can output structured JSON (`defospam-results.json`):

```json
{
  "metadata": {
    "tool": "OpenRequirements.ai DeFOSPAM",
    "version": "1.0",
    "timestamp": "2026-03-16T10:30:00Z",
    "source_file": "docs/PRD.md"
  },
  "summary": {
    "total_findings": 23,
    "critical": 4,
    "major": 12,
    "minor": 7,
    "features_identified": 8,
    "scenarios_created": 31,
    "glossary_terms": 45
  },
  "glossary": [...],
  "features": [...],
  "scenarios": [...],
  "business_stories": [...],
  "findings": [...],
  "findings_by_principle": { "D": [], "F": [], "O": [], "S": [], "P": [], "A": [], "M": [] }
}
```

### Diff Mode

Re-run DeFOSPAM after improving requirements and compare results:

```bash
claude -p "Re-run DeFOSPAM on docs/PRD.md and diff against the last run"
```

Each finding is tagged: **New** | **Resolved** | **Recurring** | **Changed** — so you can track improvement over iterations.

---

## Confidence & Severity

### Confidence Scale

Only findings with confidence **≥ 7** are reported:

| Score | Meaning |
|:---:|---|
| **10** | Definitive — explicitly visible in the text |
| **9** | Very strong — multiple signals confirm it |
| **8** | Strong — clear pattern or gap |
| **7** | Likely — reasonable interpretation suggests a problem |
| ≤ 6 | Not reported — too speculative |

### Severity Levels

| Severity | Description | Priority |
|---|---|:---:|
| **Critical** | Cannot implement correctly without resolution | 8–10 |
| **Major** | Significant risk of misunderstanding | 4–7 |
| **Minor** | Improvement opportunity, low risk | 1–3 |

---

## Example Workflow

1. **Upload** your requirements document or paste requirements text
2. **Run** the DeFOSPAM skill — all 7 agents analyze your requirements
3. **Review** the findings — glossary gaps, missing features, ambiguous language, unpredictable outcomes
4. **Fix** the requirements based on recommendations
5. **Re-run** DeFOSPAM on the improved requirements to verify coverage

This iterative loop continues until your requirements are clear, complete, and predictable.

---

## Methodology

DeFOSPAM is part of the **Business Story Method**, a practical approach to requirements validation that bridges the gap between stakeholders and development teams. The methodology emphasizes:

- **Specification by Example** — using concrete scenarios to validate understanding
- **Business Stories** — structured feature descriptions with testable scenarios
- **Provocation** — deliberately proposing absurd alternatives to force clarification
- **Completeness Checking** — systematic CRUD and cross-cutting concern analysis

For more on the Business Story Method, see the work of **Paul Gerrard** at [Gerrard Consulting](https://gerrardconsulting.com) and **Jonathon Wright** at [OpenTest.AI](https://opentest.ai).

---

## Companion Skills

DeFOSPAM integrates well with other skills in the ecosystem:

| Skill | Integration |
|---|---|
| **OpenTestAI** | Validate requirements first with DeFOSPAM, then test the implementation against generated scenarios |
| **docx** | Export the DeFOSPAM report as a professional Word document |
| **pptx** | Generate a stakeholder presentation summarizing findings |
| **xlsx** | Export glossary, features, and findings as a tracking spreadsheet |

---

## Contributing

Contributions are welcome! Here are some ways to help:

- **Report issues** — if an agent produces false positives or misses obvious gaps, open an issue
- **Suggest new checks** — ideas for additional validation rules within existing agents
- **Improve prompts** — refinements to agent prompts that produce better results
- **Add examples** — sample requirements documents with expected DeFOSPAM output

---

## Credits

- **DeFOSPAM Methodology** — Paul Gerrard (Gerrard Consulting) & Jonathon Wright (OpenTest.AI)
- **Skill Implementation** — [OpenRequirements.ai](https://openrequirements.ai)
- **Platforms** — Claude Code, Claude Cowork, Claude.ai by [Anthropic](https://anthropic.com)

---

<p align="center">
  <a href="https://openrequirements.ai">openrequirements.ai</a> · <a href="https://opentest.ai">opentest.ai</a>
</p>
