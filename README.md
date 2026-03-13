<p align="center">
  <img src="https://openrequirements.ai/img/or-logo.png" alt="OpenRequirements.ai" height="80">
</p>

<h1 align="center">DeFOSPAM — AI Requirements Validation Skill</h1>

<p align="center">
  <strong>7 specialized AI analyst agents that validate your requirements using the DeFOSPAM methodology</strong>
</p>

<p align="center">
  <a href="https://openrequirements.ai"><img src="https://img.shields.io/badge/OpenRequirements.ai-blue?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0wIDE4Yy00LjQyIDAtOC0zLjU4LTgtOHMzLjU4LTggOC04IDggMy41OCA4IDgtMy41OCA4LTggOHoiLz48L3N2Zz4=" alt="OpenRequirements.ai"></a>
  <img src="https://img.shields.io/badge/agents-7-purple?style=flat-square" alt="7 Agents">
  <img src="https://img.shields.io/badge/methodology-DeFOSPAM-green?style=flat-square" alt="DeFOSPAM">
  <img src="https://img.shields.io/badge/platform-Claude%20Cowork-orange?style=flat-square" alt="Claude Cowork">
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

### Claude Cowork

Place the `defospam/` folder (containing `SKILL.md`) in your skills directory:

```
~/.skills/skills/defospam/SKILL.md
```

Or add it to your project's `.skills/skills/` folder.

### Claude Code

Copy the `defospam/` folder into your project's skill directory and it will be available as a skill.

---

## Usage

Once installed, the skill triggers automatically when you mention requirements validation. Some example prompts:

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

---

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                 Your Requirements                    │
│        (.docx, .pdf, .md, .txt, or text)            │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│              DeFOSPAM Analysis Pipeline              │
│                                                      │
│  1. Dorothy (Definitions) → Glossary                 │
│  2. Flo (Features)        → Business Stories         │
│  3. Olivia (Outcomes)     → Outcome Map              │
│  4. Sophia (Scenarios)    → Given/When/Then          │
│  5. Paul (Prediction)     → Gap Detection            │
│  6. Alexa (Ambiguity)     → Language Analysis        │
│  7. Milarna (Missing)     → Completeness Sweep       │
│                                                      │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                    Outputs                            │
│                                                      │
│  📋 Chat Summary                                     │
│  📝 defospam-report.md                               │
│  🌐 defospam-report.html                             │
│                                                      │
│  Including: Glossary, Business Stories, Scenarios,   │
│  Findings with severity & recommendations            │
└─────────────────────────────────────────────────────┘
```

The agents run sequentially in DeFOSPAM order because later agents build on earlier findings — Dorothy's glossary informs Flo's feature identification, which feeds Sophia's scenario creation, and so on. Milarna runs last to catch anything the others missed.

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
- **Platform** — Built for [Claude](https://claude.ai) by Anthropic

---

<p align="center">
  <a href="https://openrequirements.ai">openrequirements.ai</a> · <a href="https://opentest.ai">opentest.ai</a>
</p>
