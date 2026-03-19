# Vibe Requirements — Planguage Quantification Skill

<p align="center">
  <img src="https://openrequirements.ai/assets/logo-nlGhAN5y.png" alt="OpenRequirements.ai" height="80">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/skill-viberequirements-blue?style=flat-square" alt="Skill: viberequirements">
  <img src="https://img.shields.io/badge/agents-8-purple?style=flat-square" alt="8 VR Agents">
  <img src="https://img.shields.io/badge/methodology-Planguage%20%2F%20Tom%20Gilb-green?style=flat-square" alt="Planguage / Tom Gilb">
  <img src="https://img.shields.io/badge/platform-Claude%20Code%20%7C%20VS%20Code%20%7C%20Cowork%20%7C%20Claude.ai-orange?style=flat-square" alt="Claude Code | VS Code | Cowork | Claude.ai">
  <img src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square" alt="MIT License">
</p>

---

## What are Vibe Requirements?

**Vibe Requirements** are the most important requirements for any project — they are the stakeholder's values. Tom Gilb's **Planguage** methodology replaces vague words like "fast", "secure", and "user-friendly" with precise, numeric specifications using Scales, Meters, Benchmarks, Constraints, and Targets.

This skill implements **8 Planguage specification components** as AI analyst agents that transform ambiguous requirements into quantified, measurable vibe specifications.

**Key insight**: "The Scale specification moves you away from informal and fuzzy requirement specifications, and over to clear, logical, quantified methods of thinking." — Tom Gilb

---

## The 8 Vibe Requirements Agents

| # | Component | Agent | What They Do |
|---|---|---|---|
| 1 | **S**c**A**le | **Alexa** | Defines quantified scales of measure, eliminates ambiguity |
| 2 | **M**ete**R** | **Ray** | Designs measurement processes, defines acceptance tests |
| 3 | **B**enchmarks | **Brook** | Establishes Past, Status, Record, Ideal, Trend levels |
| 4 | **C**onstra**I**nts | **Isaac** | Sets Tolerable minimum levels, fail/pass boundaries |
| 5 | **T**argets | **Tom** | Defines Wish, Goal, Stretch levels with deadlines |
| 6 | **B**ackg**R**ound | **Raj** | Adds risk, priority, responsibility, motivation context |
| 7 | **S**t**a**akeholders | **Alan** | Maps stakeholders to values, analyzes priority and power |
| 8 | **Q**ua**L**ity Control | **Lovelace** | Runs Spec QC, detects defects, assesses exit readiness |

---

## Example: From Vague to Quantified

**Before** (vague ambition):
> "We need better security"

**After** (Planguage vibe specification):
```
Tag: Security
Type: Value Requirement.
Ambition: "We need better security" <- CTO, March 2026
Scale: % probability of detecting a hacker within [Detection Window]
       on [System Component].
Meter: Quarterly penetration test by certified ethical hackers.

Past: 10% (2025). Source: annual pen test report.
Status: 45% (Q1 2026). Source: latest pen test.

Tolerable: 80% by End 2026. Detection Window = 5 seconds.
Wish: 95% by End 2027.
Goal: 98% by End 2027.

Owner: CISO.
Stakeholders: End users (high), Regulators (high), Board (medium).
```

---

## The Pipeline

```
┌─────────────────────────┐
│ Vague Requirements      │
│ "fast", "secure",       │
│ "user-friendly"         │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ Vibe Requirements Skill │
│ 8 Planguage agents       │
│ Alexa → Ray →       │
│ Brook → Alan →          │
│ Isaac → Tom →        │
│ Raj → Lovelace           │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ Quantified Planguage    │
│ Specifications          │
│ Scale + Meter +         │
│ Benchmarks + Constraints│
│ + Targets + Background  │
│ + Stakeholders + QC     │
└─────────────────────────┘
```

---

## Installation

### Claude Code (Recommended)

```bash
git clone https://github.com/AgenticTesting/OpenRequirementsAI.git

mkdir -p .claude/skills/viberequirements
cp OpenRequirementsAI/viberequirements/SKILL.md .claude/skills/viberequirements/SKILL.md

git add .claude/skills/viberequirements/SKILL.md
git commit -m "Add /viberequirements Planguage skill"
```

**Global install:**
```bash
mkdir -p ~/.claude/skills/viberequirements
cp path/to/SKILL.md ~/.claude/skills/viberequirements/SKILL.md
```

### Visual Studio Code / Cowork / Claude.ai

Same installation patterns as the other OpenRequirements.ai skills.

---

## Usage

### Quantify Vague Requirements

```
/viberequirements "The system must be fast, secure, and user-friendly"
```

### From DeFOSPAM Output

```
# Step 1: Validate requirements
/openrequirements-input/openrequirements-output.md

# Step 2: Quantify values
/openrequirements-input/openrequirements-output.json
```

### From User Stories

```
/vibeequirements "As an expert user I want shortcuts to save me time"
```

### CLI / Pipeline Mode

```bash
claude -p "Use /viberequirements to quantify values from ./openrequirements-output.json. Save to ./openrequirements-output/"
```

---

## Architecture: 4-Phase Execution

```
Phase 1 (Foundation):     Alexa ──────┐
                                      ▼
Phase 2 (Measurement):   Ray ───┐
                          Brook ──────┤
                          Alan ──────┘
                                      ▼
Phase 3 (Levels):        Isaac ────┐
                          Tom ──────┤
                          Raj ─────┘
                                      ▼
Phase 4 (QC):            Lovelace ───────┘
                                      ▼
Phase 5 (Aggregate):     Main agent compiles Planguage specs
```

---

## Output Schema (`openrequirements-vibe-results.json`)

```json
{
  "metadata": {
    "tool": "OpenRequirements.ai Vibe",
    "version": "1.0",
    "methodology": "Vibe Requirements / Planguage (Tom Gilb)",
    "agents_run": ["alexa", "ray", "brook", "isaac", "tom", "raj", "alan", "lovelace"]
  },
  "summary": {
    "total_values": 0,
    "total_defects": 0,
    "completeness_percent": 0,
    "exit_recommendation": "ready | needs_work | major_rework"
  },
  "value_specifications": [],
  "scales": [],
  "meters": [],
  "benchmarks": [],
  "constraints": [],
  "targets": [],
  "stakeholder_mappings": [],
  "qc_findings": [],
  "quality_assessment": {}
}
```

---

## Companion Skills

| Skill | Integration |
|---|---|
| **[DeFOSPAM](../defospam/)** | Identifies ambiguous values → feed into this skill for quantification |
| **[Requirements Specification](../requirementspecification/)** | SRS system attributes can be quantified with Planguage Scales |
| **[SBE](../specificationbyexample/)** | Value Meters define acceptance criteria for Gherkin scenarios |
| **[Performance Engineering](../performanceengineering/)** | PE budgets align with Planguage performance Scales and Targets |
| **[OpenTestAI](https://github.com/AgenticTesting/OpenTestAI)** | Meters define test processes; Tolerables define pass/fail |

---

## Credits

- **Vibe Requirements / Planguage**: [Tom Gilb](https://www.gilb.com/) — *Vibe Requirements* and *Competitive Engineering*
- **DeFOSPAM methodology**: [Paul Gerrard](https://gerrardconsulting.com/), Gerrard Consulting & [Jonathon Wright](https://opentest.ai/), OpenTest.AI
- **Skill implementation**: [OpenRequirements.ai](https://www.openrequirements.ai)

---

<p align="center">
  <sub>Built with the <a href="https://openrequirements.ai">OpenRequirements.ai</a> skill framework</sub>
</p>
