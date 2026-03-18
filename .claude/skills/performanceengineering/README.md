# Performance Engineering — NFR Analysis Skill

<p align="center">
  <img src="https://openrequirements.ai/assets/logo-nlGhAN5y.png" alt="OpenRequirements.ai" height="80">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/skill-performanceengineering-blue?style=flat-square" alt="Skill: performanceengineering">
  <img src="https://img.shields.io/badge/agents-8-purple?style=flat-square" alt="8 PE Agents">
  <img src="https://img.shields.io/badge/methodology-Effective%20Performance%20Engineering-green?style=flat-square" alt="Effective Performance Engineering">
  <img src="https://img.shields.io/badge/platform-Claude%20Code%20%7C%20VS%20Code%20%7C%20Cowork%20%7C%20Claude.ai-orange?style=flat-square" alt="Claude Code | VS Code | Cowork | Claude.ai">
  <img src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/companion-DeFOSPAM-red?style=flat-square" alt="OpenRequirements.AI Companion">
</p>

---

## What is Performance Engineering?

**Effective Performance Engineering** is a cultural shift in how organizations build quality and performance throughout the lifecycle — from first design through production operations. Based on the methodology by Todd DeCapua and Shane Evans (O'Reilly, 2016), it goes far beyond traditional load testing to encompass capacity planning, SLA definition, resilience, monitoring, security performance, and user experience.

This skill implements **8 NFR analysis disciplines** as AI analyst agents that transform OpenRequirements.AI output (particularly Milarna's missing NFR findings) into actionable performance budgets, capacity models, SLA definitions, and test strategies.

---

## The 8 CLASS UME Agents

| # | Discipline | Agent | What They Do |
|---|---|---|---|
| 1 | **Ca**pacity | **Ada** | Models capacity, server sizing, growth forecasting, cost estimation |
| 2 | **L**ate**N**cy | **Noyce** | Defines response time budgets, component-level timing, SLAs |
| 3 | **A**vailability | **Alan** | Sets uptime targets, RTO/RPO, failover strategies |
| 4 | **S**ca**L**ability | **Liskov** | Assesses horizontal/vertical scaling, identifies bottlenecks |
| 5 | **S**ecurit**Y** | **Yao** | Evaluates security control overhead, DoS resilience |
| 6 | **U**sabili**T**y | **Turing** | Defines UX performance metrics, mobile targets, satisfaction thresholds |
| 7 | **M**on**I**toring | **Iverson** | Designs observability, alerting thresholds, dashboard strategy |
| 8 | **E**nduran**C**e | **Cerf** | Plans soak/stress testing, resource leak detection, doneness criteria |

---

## The Pipeline: DeFOSPAM → Performance Engineering

```
┌─────────────────────────┐
│   Requirements Document  │
│   (.md, .docx, .pdf)    │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│    DeFOSPAM Skill       │
│    7 validation agents  │
│    Milarna flags missing │
│    NFRs                  │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ openrequirements-       │
│ results.json             │◄── INPUT TO THIS SKILL
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│  Performance Engineering │
│  Skill                   │
│  8 CLASS UME agents      │
│  Ada → Noyce →        │
│  Alan → Liskov →         │
│  Yao → Turing →          │
│  Iverson → Cerf            │
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ perf-results.json       │
│ perf-report.md          │
│ perf-report.html        │
│ Performance Budgets     │
│ Capacity Models         │
│ SLA Definitions         │
│ Test Strategy           │
└─────────────────────────┘
```

---

## Installation

### Claude Code (Recommended)

```bash
git clone https://github.com/AgenticTesting/OpenRequirementsAI.git

mkdir -p .claude/skills/performanceengineering
cp OpenRequirementsAI/performanceengineering/SKILL.md .claude/skills/performanceengineering/SKILL.md

git add .claude/skills/performanceengineering/SKILL.md
git commit -m "Add /performanceengineering NFR analysis skill"
```

**Global install:**
```bash
mkdir -p ~/.claude/skills/performanceengineering
cp path/to/SKILL.md ~/.claude/skills/performanceengineering/SKILL.md
```

**Verify** — type `/` in Claude Code:
```
/performanceengineering    OpenRequirements.AI NFR analysis...
                           [openrequirements-results-json-or-nfr-document]
```

### Visual Studio Code / Cowork / Claude.ai

Same installation patterns as the other OpenRequirements.ai skills.

---

## Usage

### Full Pipeline (DeFOSPAM → PE)

```
# Step 1: Validate requirements
/openrequirements docs/PRD.md

# Step 2: Analyze NFRs
/performanceengineering openrequirements-output/openrequirements-results.json
```

### Direct NFR Analysis

```
# Analyze an existing NFR document
/.performanceengineering-input/nfr-specification.md

# Analyze acceptance criteria with performance targets
/performanceengineering "Login must complete within 5 seconds for 180,000 users per hour across 7 geographic locations with 40% on mobile"
```

### CLI / Pipeline Mode

```bash
claude -p "Use /performanceengineering to analyze NFRs from ./openperformance-output/openrequirements-results.json. Save to ./openperformance-output/"
```

---

## Architecture: 3-Phase Parallel Execution

```
Phase 1 (Foundation):     Ada ──────┐
                          Noyce ───────┤
                          Alan ───────┘
                                       ▼
Phase 2 (Analysis):      Liskov ───────┐
                          Yao ───────┤
                          Turing ────────┘
                                       ▼
Phase 3 (Strategy):      Iverson ───────┐
                          Cerf ────────┘
                                       ▼
Phase 4 (Aggregate):     Main agent compiles NFR assessment
```

---

## Output Schema (`openperformance-results.json`)

```json
{
  "metadata": {
    "tool": "OpenRequirements.ai PE",
    "version": "1.0",
    "methodology": "Effective Performance Engineering (DeCapua & Evans)",
    "agents_run": ["ada", "noyce", "alan", "liskov", "yao", "turing", "iverson", "cerf"]
  },
  "summary": {
    "total_nfrs": 0,
    "by_discipline": {
      "capacity": 0, "latency": 0, "availability": 0, "scalability": 0,
      "security": 0, "usability": 0, "monitoring": 0, "endurance": 0
    }
  },
  "capacity_model": {},
  "performance_budgets": [],
  "availability_requirements": [],
  "scalability_assessment": {},
  "security_performance": [],
  "usability_metrics": [],
  "monitoring_strategy": {},
  "test_strategy": {},
  "nfr_register": [],
  "findings": []
}
```

---

## Companion Skills

| Skill | Integration |
|---|---|
| **[DeFOSPAM](../defospam/)** | Run first — Milarna's missing NFR findings feed directly into this skill |
| **[Requirements Specification](../requirementspecification/)** | SRS Section 3 system attributes complement this NFR analysis |
| **[SBE](../specificationbyexample/)** | Gherkin scenarios can include performance acceptance criteria from Noyce's budgets |
| **[OpenTestAI](https://github.com/AgenticTesting/OpenTestAI)** | Use Cerf's test strategy for performance test execution |
| **xlsx** | Export performance budgets and SLA definitions as spreadsheets |

---

## Credits

- **Effective Performance Engineering**: [Todd DeCapua](https://www.linkedin.com/in/toddcapua/) and [Shane Evans](https://www.linkedin.com/in/shaneevans/) (O'Reilly Media, 2016)
- **DeFOSPAM methodology**: [Paul Gerrard](https://gerrardconsulting.com/), Gerrard Consulting & [Jonathon Wright](https://opentest.ai/), OpenTest.AI
- **Skill implementation**: [OpenRequirements.ai](https://www.openrequirements.ai)

---

<p align="center">
  <sub>Built with the <a href="https://openrequirements.ai">OpenRequirements.ai</a> skill framework</sub>
</p>
