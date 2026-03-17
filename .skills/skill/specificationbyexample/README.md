# Specification by Example — Living Documentation Skill

<p align="center">
  <img src="https://openrequirements.ai/assets/logo-nlGhAN5y.png" alt="OpenRequirements.ai" height="80">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/skill-specificationbyexample-blue?style=flat-square" alt="Skill: specificationbyexample">
  <img src="https://img.shields.io/badge/agents-7-purple?style=flat-square" alt="7 SBE Agents">
  <img src="https://img.shields.io/badge/methodology-Specification%20by%20Example-green?style=flat-square" alt="Specification by Example">
  <img src="https://img.shields.io/badge/platform-Claude%20Code%20%7C%20VS%20Code%20%7C%20Cowork%20%7C%20Claude.ai-orange?style=flat-square" alt="Claude Code | VS Code | Cowork | Claude.ai">
  <img src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/companion-DeFOSPAM-red?style=flat-square" alt="DeFOSPAM Companion">
</p>

---

## What is Specification by Example?

**Specification by Example (SBE)** is a set of process patterns that help teams build the right software product. Based on Gojko Adzic's research into 50+ successful projects, SBE transforms requirements into **executable specifications** that serve simultaneously as:

- **Requirements** — what the system should do
- **Acceptance tests** — how to verify it works
- **Living documentation** — a reliable source of truth

This skill implements the **7 key process patterns** as AI analyst agents that transform DeFOSPAM requirements validation output into production-ready executable specifications.

---

## The 7 Process Pattern Agents

| # | Pattern | Agent | What They Do |
|---|---|---|---|
| 1 | Deriving scope from **G**oals | **Grace** | Extracts business goals from features, aligns scope to value |
| 2 | **S**pecifying collaboratively | **Chris** | Builds ubiquitous language, identifies collaboration gaps, recommends workshops |
| 3 | **I**llustrating using examples | **Isabel** | Creates concrete key examples with realistic data for each scenario |
| 4 | **R**efining the specification | **Rex** | Strips surplus detail, enforces "what not how", ensures domain language |
| 5 | **A**utomating validation | **Amber** | Generates Gherkin feature files, designs automation layer, maps traceability |
| 6 | **V**alidating frequently | **Victoria** | Designs smoke/regression/full validation suites, CI/CD integration |
| 7 | evo**L**ving documentation | **Laveena** | Structures living documentation, checks consistency, ensures accessibility |

---

## The Pipeline: DeFOSPAM → SBE

This skill is designed as a **downstream companion** to the [DeFOSPAM skill](../openrequirements/). The full OpenRequirements.ai pipeline:

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
│    SBE Skill            │
│    7 transformation     │
│    agents               │
│    Grace → Chris →      │
│    Isabel → Rex →         │
│    Amber → Victoria → Laveena   │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ sbe-results.json        │
│ *.feature (Gherkin)     │
│ sbe-report.md           │
│ sbe-report.html         │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│    OpenTestAI Skill     │
│    33+ testing agents   │
│    Validate the         │
│    implementation       │
└─────────────────────────┘
```

---

## Installation

### Claude Code (Recommended)

Claude Code **auto-discovers** skills from `.claude/skills/<name>/SKILL.md`.

**Quick install — project level (team access):**
```bash
# Clone the repo
git clone https://github.com/AgenticTesting/OpenRequirementsAI.git

# Copy into your project's skill directory
mkdir -p .claude/skills/specificationbyexample
cp OpenRequirementsAI/specificationbyexample/SKILL.md .claude/skills/specificationbyexample/SKILL.md

# Commit so your whole team gets the command
git add .claude/skills/specificationbyexample/SKILL.md
git commit -m "Add /specificationbyexample SBE skill"
```

**Global install (available in ALL your projects):**
```bash
mkdir -p ~/.claude/skills/specificationbyexample
cp path/to/SKILL.md ~/.claude/skills/specificationbyexample/SKILL.md
```

**Verify it works** — type `/` in Claude Code and you should see:
```
/specificationbyexample    OpenRequirements.AI SBE executable specifications...
                           [defospam-results-json-or-requirements]
```

### Visual Studio Code (Claude Code Extension)

1. Install the Claude Code VS Code extension: `code --install-extension anthropic.claude-code`
2. Install the skill (same as above — project or global)
3. Open the Claude Code panel → type `/specificationbyexample`
4. Gherkin feature files get syntax highlighting with a Cucumber/Gherkin extension

### Claude Cowork

Place the `specificationbyexample/` folder in your skills directory:
```
~/.skills/skills/specificationbyexample/SKILL.md
```

### Claude.ai (Web)

Upload the `SKILL.md` file to your conversation or paste its contents. The skill runs sequentially (no parallel agents).

---

## Usage

### Full Pipeline (DeFOSPAM → SBE)

```
# Step 1: Run DeFOSPAM on your requirements
/openrequirements docs/PRD.md

# Step 2: Transform into executable specifications
/specificationbyexample defospam-output/openrequirements-results.json
```

### Interactive Examples

```
# Transform DeFOSPAM results into executable specs
/specificationbyexample defospam-output/openrequirements-results.json

# Generate Gherkin feature files only
Generate Gherkin from the DeFOSPAM results in defospam-output/

# Create executable specifications from raw requirements (no DeFOSPAM needed)
/specificationbyexample docs/requirements.md

# Refine existing feature files
/specificationbyexample features/login.feature
```

### CLI / Pipeline Mode

```bash
# Full transformation
claude -p "Use /specificationbyexample to transform ./defospam-output/openrequirements-results.json. Save to ./sbe-output/"

# Gherkin only
claude -p "Use /specificationbyexample to generate Gherkin from ./defospam-output/openrequirements-results.json. Save features to ./features/"

# Pipeline mode (JSON stdout only)
claude -p "Use /specificationbyexample on ./defospam-output/openrequirements-results.json in pipeline mode: JSON only to stdout"
```

---

## Architecture: 3-Phase Parallel Execution

When subagents are available (Claude Code / Cowork), the SBE agents run in a 3-phase parallel strategy:

```
Phase 1 (Foundation):     Grace ─────┐
                          Chris ─────┤
                                     ▼
Phase 2 (Transform):     Isabel ──────┐
                          Rex ───────┤
                                     ▼
Phase 3 (Deliver):       Amber ───────┐
                          Victoria ────┤
                          Laveena ───────┘
                                     ▼
Phase 4 (Aggregate):     Main agent compiles all outputs
```

**Why this order?**
- Grace and Chris read directly from DeFOSPAM output → can run first in parallel
- Isabel and Rex need Grace's goals and Chris's language → run after Phase 1
- Amber, Victoria, and Laveena need refined specs and examples → run after Phase 2
- The main agent aggregates everything → runs last

---

## Output Schema (`sbe-results.json`)

```json
{
  "metadata": {
    "tool": "OpenRequirements.ai SBE",
    "version": "1.0",
    "timestamp": "ISO-8601",
    "source": "path/to/input",
    "agents_run": ["grace", "chris", "isabel", "rex", "amber", "victoria", "laveena"]
  },
  "summary": {
    "total_findings": 0,
    "goals_derived": 0,
    "specifications_refined": 0,
    "examples_created": 0,
    "gherkin_scenarios": 0,
    "feature_files": 0,
    "validation_suites": { "smoke": 0, "regression": 0, "full": 0 }
  },
  "ubiquitous_language": [],
  "business_goals": [],
  "key_examples": [],
  "refined_specifications": [],
  "gherkin_features": [],
  "validation_strategy": {},
  "documentation_structure": {},
  "findings": [],
  "traceability": {
    "defospam_findings_covered": [],
    "defospam_findings_uncovered": [],
    "coverage_percentage": 0
  }
}
```

---

## Confidence & Severity

### Confidence Scale (7-10, same as DeFOSPAM)

| Score | Meaning |
|---|---|
| **10** | Definitive — explicitly visible in the input |
| **9** | Very strong evidence — multiple signals confirm |
| **8** | Strong evidence — clear pattern or gap |
| **7** | Likely issue — reasonable interpretation |
| **< 7** | Not reported |

### Severity Levels

| Level | Description |
|---|---|
| **Critical** | Specification cannot be automated or validated without resolution |
| **Major** | Significant risk of incorrect executable specification |
| **Minor** | Improvement opportunity |

---

## SBE Methodology Background

The 7 key process patterns come from Gojko Adzic's *Specification by Example: How Successful Teams Deliver the Right Software* (Manning, 2011), based on research into 50+ real-world projects:

1. **Deriving scope from goals** — Don't just build what's asked for; understand *why* it's needed and derive the right scope
2. **Specifying collaboratively** — Bring business, dev, and test together; no single person gets specs right alone
3. **Illustrating using examples** — Make abstract requirements concrete with specific, realistic examples
4. **Refining the specification** — Strip away surplus detail; specs should say *what*, not *how*
5. **Automating validation without changing specifications** — Keep specs human-readable after automation
6. **Validating frequently** — Run specs against the system continuously for fast feedback
7. **Evolving a documentation system** — Maintain specs as living documentation that stays reliable over time

The end result: **living documentation** — a reliable, authoritative source of truth about what the system does, as trustworthy as code but far easier to read.

---

## Companion Skills

| Skill | Integration |
|---|---|
| **[DeFOSPAM](../defospam/)** | Run first to validate requirements → feed output into SBE |
| **[OpenTestAI](https://github.com/AgenticTesting/OpenTestAI)** | Use SBE's Gherkin features for automated test generation |
| **docx** | Export SBE report as a professional Word document |
| **pptx** | Generate a presentation of the transformation results |
| **xlsx** | Export traceability matrix and validation strategy as a spreadsheet |

---

## Credits

- **Specification by Example methodology**: [Gojko Adzic](https://gojko.net/) — *Specification by Example: How Successful Teams Deliver the Right Software* (Manning, 2011)
- **DeFOSPAM methodology**: [Paul Gerrard](https://gerrardconsulting.com/), Gerrard Consulting & [Jonathon Wright](https://opentest.ai/), OpenTest.AI
- **Skill implementation**: [OpenRequirements.ai](https://www.openrequirements.ai)

---

<p align="center">
  <sub>Built with the <a href="https://openrequirements.ai">OpenRequirements.ai</a> skill framework</sub>
</p>
