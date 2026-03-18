# Requirements Specification — IEEE 830 SRS Generation Skill

<p align="center">
  <img src="https://openrequirements.ai/assets/logo-nlGhAN5y.png" alt="OpenRequirements.ai" height="80">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/skill-requirementspecification-blue?style=flat-square" alt="Skill: requirementspecification">
  <img src="https://img.shields.io/badge/agents-8-purple?style=flat-square" alt="8 SRS Agents">
  <img src="https://img.shields.io/badge/standard-IEEE%20830--1998-green?style=flat-square" alt="IEEE 830-1998">
  <img src="https://img.shields.io/badge/platform-Claude%20Code%20%7C%20VS%20Code%20%7C%20Cowork%20%7C%20Claude.ai-orange?style=flat-square" alt="Claude Code | VS Code | Cowork | Claude.ai">
  <img src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/companion-DeFOSPAM-red?style=flat-square" alt="DeFOSPAM Companion">
</p>

---

## What is IEEE 830?

**IEEE Std 830-1998** is the IEEE Recommended Practice for Software Requirements Specifications. It defines the content, qualities, and structure of a good SRS document and specifies **8 characteristics** that every SRS must exhibit.

This skill implements those 8 characteristics as AI analyst agents that transform DeFOSPAM requirements validation output into a formal, IEEE 830-compliant SRS document with a quality scorecard, traceability matrix, and acceptance criteria.

---

## The 8 Quality Characteristic Agents

| # | Characteristic | Agent | What They Do |
|---|---|---|---|
| 1 | **C**orrect | **Chelcie** | Validates requirements against source, checks factual accuracy |
| 2 | **U**nambigu**O**us | **Odin** | Detects natural language pitfalls, proposes unambiguous rewrites |
| 3 | **C**omp**L**ete | **Lucy** | Identifies gaps, resolves TBDs, checks IEEE 830 section coverage |
| 4 | **Co**nsistent | **Ophellia** | Detects internal conflicts, synonym collisions, logical contradictions |
| 5 | **R**a**N**ked | **Natasha** | Classifies necessity (essential/conditional/optional) and stability |
| 6 | **V**er**I**fiable | **Iris** | Ensures every requirement has measurable acceptance criteria |
| 7 | **M**odifi**A**ble | **Amelia** | Designs SRS structure, eliminates redundancy, assigns requirement IDs |
| 8 | **T**raceab**L**e | **Lewis** | Builds forward/backward traceability matrix, identifies orphans |

---

## The Pipeline: DeFOSPAM → SRS

This skill is designed as a **downstream companion** to the [DeFOSPAM skill](../defospam/). The full OpenRequirements.ai pipeline:

```
┌─────────────────────────┐
│   Requirements Document  │
│   (.md, .docx, .pdf)    │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│    DeFOSPAM Skill       │
│    7 validation agents  │
│    Dorothy → Flo →      │
│    Olivia → Sophia →    │
│    Paul → Alexa →       │
│    Milarna               │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ openrequirements-       │
│ results.json             │◄── INPUT TO THIS SKILL
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│  Req Specification Skill │
│  8 quality agents        │
│  Chelcie → Odin → Lucy →   │
│  Ophellia → Natasha → Iris → │
│  Amelia → Lewis           │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ srs-results.json        │
│ srs-report.md           │
│ srs-report.html         │
│ Quality Scorecard       │
│ Traceability Matrix     │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│    SBE Skill            │
│    7 transformation     │
│    agents               │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│    OpenTestAI Skill     │
│    33+ testing agents   │
└─────────────────────────┘
```

---

## Installation

### Claude Code (Recommended)

```bash
# Clone the repo
git clone https://github.com/AgenticTesting/OpenRequirementsAI.git

# Copy into your project's skill directory
mkdir -p .claude/skills/requirementspecification
cp OpenRequirementsAI/requirementspecification/SKILL.md .claude/skills/requirementspecification/SKILL.md

# Commit so your whole team gets the command
git add .claude/skills/requirementspecification/SKILL.md
git commit -m "Add /requirementspecification IEEE 830 SRS skill"
```

**Global install:**
```bash
mkdir -p ~/.claude/skills/requirementspecification
cp path/to/SKILL.md ~/.claude/skills/requirementspecification/SKILL.md
```

**Verify** — type `/` in Claude Code:
```
/requirementspecification    OpenRequirements.AI IEEE 830 SRS generation...
                             [defospam-results-json-or-requirements]
```

### Visual Studio Code

Install the Claude Code extension, then use `/requirementspecification` in the Claude Code panel.

### Claude Cowork

Place in `~/.skills/skills/requirementspecification/SKILL.md`.

### Claude.ai (Web)

Upload the `SKILL.md` file or paste its contents. Runs sequentially (no parallel agents).

---

## Usage

### Full Pipeline (DeFOSPAM → SRS)

```
# Step 1: Run DeFOSPAM on your requirements
/.openrequirements-input/PRD.md

# Step 2: Generate IEEE 830 SRS
/.openrequirements-output/openrequirements-results.json
```

### Interactive Examples

```
# Generate SRS from DeFOSPAM results
/openrequirements-output/openrequirements-srs-results.json

# Assess existing SRS quality against IEEE 830
/openrequirements-input/existing-SRS.md

# Generate traceability matrix only
Build a traceability matrix from the DeFOSPAM results
```

### CLI / Pipeline Mode

```bash
# Full SRS generation
claude -p "Use /requirementspecification to generate an IEEE 830 SRS from ./openrequirements-output/openrequirements-results.json. Save to ./openrequirements-output/"

# Quality assessment only
claude -p "Use /requirementspecification to assess IEEE 830 quality of ./openrequirements-input/SRS.md"

# Pipeline mode (JSON stdout)
claude -p "Use /requirementspecification on ./openrequirements-output/openrequirements-srs-results.json in pipeline mode: JSON only to stdout"
```

---

## Architecture: 3-Phase Parallel Execution

```
Phase 1 (Foundation):     Chelcie ──────┐
                          Odin ────────┤
                          Ophellia ─────┘
                                      ▼
Phase 2 (Assessment):    Lucy ───────┐
                          Natasha ───────┤
                          Iris ───────┘
                                      ▼
Phase 3 (Structure):     Amelia ─────┐
                          Lewis ───────┘
                                      ▼
Phase 4 (Aggregate):     Main agent compiles SRS document
```

**Why this order?**
- Chelcie, Odin, and Ophellia read directly from DeFOSPAM → can run first in parallel
- Lucy, Natasha, and Iris benefit from Odin's rewrites → run after Phase 1
- Amelia and Lewis need all previous outputs to structure and trace → run after Phase 2

---

## IEEE 830 Quality Scorecard

The skill produces a quality scorecard rating the SRS against each of the 8 characteristics:

| Characteristic | Score Range | Status |
|---|---|---|
| 90-100% | Pass | Meets IEEE 830 standard |
| 70-89% | Warn | Partially meets, improvements recommended |
| < 70% | Fail | Does not meet IEEE 830 standard |

---

## Output Schema (`openrequirements-srs-results.json`)

```json
{
  "metadata": {
    "tool": "OpenRequirements.ai SRS",
    "version": "1.0",
    "standard": "IEEE Std 830-1998",
    "timestamp": "ISO-8601",
    "source": "path/to/input",
    "agents_run": ["chelcie", "odin", "lucy", "ophellia", "natasha", "iris", "amelia", "lewis"]
  },
  "summary": {
    "total_findings": 0,
    "total_requirements": 0,
    "essential": 0,
    "conditional": 0,
    "optional": 0,
    "srs_sections_populated": 0,
    "tbds_remaining": 0
  },
  "quality_scorecard": {
    "correct": { "score": 0, "status": "pass|warn|fail" },
    "unambiguous": { "score": 0, "status": "pass|warn|fail" },
    "complete": { "score": 0, "status": "pass|warn|fail" },
    "consistent": { "score": 0, "status": "pass|warn|fail" },
    "ranked": { "score": 0, "status": "pass|warn|fail" },
    "verifiable": { "score": 0, "status": "pass|warn|fail" },
    "modifiable": { "score": 0, "status": "pass|warn|fail" },
    "traceable": { "score": 0, "status": "pass|warn|fail" },
    "overall": 0
  },
  "requirements": [],
  "traceability_matrix": [],
  "findings": []
}
```

---

## Companion Skills

| Skill | Integration |
|---|---|
| **[DeFOSPAM](../defospam/)** | Run first to validate requirements → feed output into this skill |
| **[SBE](../specificationbyexample/)** | Run after to create executable specifications from the SRS |
| **[OpenTestAI](https://github.com/AgenticTesting/OpenTestAI)** | Use acceptance criteria from Iris for test generation |
| **docx** | Export SRS as a professional Word document |
| **xlsx** | Export traceability matrix and priority rankings |

---

## Credits

- **IEEE 830-1998**: IEEE Recommended Practice for Software Requirements Specifications, IEEE Computer Society
- **DeFOSPAM methodology**: [Paul Gerrard](https://gerrardconsulting.com/), Gerrard Consulting & [Jonathon Wright](https://opentest.ai/), OpenTest.AI
- **Skill implementation**: [OpenRequirements.ai](https://www.openrequirements.ai)

---

<p align="center">
  <sub>Built with the <a href="https://openrequirements.ai">OpenRequirements.ai</a> skill framework</sub>
</p>
