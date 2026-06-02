# Claude Code Skills

A collection of reusable skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that enhance writing quality, research, media processing, and investigation workflows.

## What are Skills?

Skills are markdown instruction files that give Claude Code specialized capabilities. Drop them into `~/.claude/skills/` and invoke them with slash commands (e.g., `/humanizer`, `/arese`).

## Installation

### Install all skills

```bash
git clone https://github.com/Gunshipz/claude-code-skills.git
cp -r claude-code-skills/skills/* ~/.claude/skills/
```

### Install individual skills

Copy any skill folder into your `~/.claude/skills/` directory:

```bash
cp -r claude-code-skills/skills/humanizer ~/.claude/skills/
```

## Available Skills

| Skill | Description | Use When |
|-------|-------------|----------|
| [humanizer](skills/humanizer/) | Removes AI writing patterns from text | Editing drafts to sound natural |
| [arese](skills/arese/) | Adversarial multi-agent document rewriting | "Make this better" for any document |
| [ffmpeg](skills/ffmpeg/) | Audio/video processing orchestration | Trimming, converting, compressing media |
| [docx](skills/docx/) | Word document creation and editing | Building .docx files programmatically |
| [doc-coauthoring](skills/doc-coauthoring/) | Structured collaborative writing workflow | Writing docs, proposals, specs |
| [deep-investigation](skills/deep-investigation/) | Evidence-based investigation protocol | Bugs, outages, complex technical questions |
| [investigation-synthesis](skills/investigation-synthesis/) | Transforms findings into deliverables | 1-pagers, exec summaries, engineering briefs |
| [reddit-research](skills/reddit-research/) | Comprehensive Reddit research | Subreddit analysis, engagement metrics, topic discovery |

## Skill Details

### humanizer

Identifies and removes 29 documented AI writing patterns based on Wikipedia's "Signs of AI writing" guide. Includes voice calibration (match a user's existing writing style) and a two-pass audit process. Works on any text.

### arese

Adversarial Reader-Empathy Synthesis Engine. Spawns isolated agent roles (Synthesizer, Critic, Editor, Judges) that cannot see each other's reasoning, eliminating sycophancy. Iterates until scores converge. Includes a deterministic lint pass for AI-tell removal.

### ffmpeg

Orchestrates ffmpeg/ffprobe for media processing. Covers trimming, format conversion, compression, resizing, merging, stream extraction, audio normalization, GIF creation, speed changes, filters, and batch processing. Always probes first, never overwrites inputs.

### docx

Full .docx manipulation using docx-js (creation) and pandoc (reading). Handles tables, images, headers/footers, TOC, multi-column layouts, tracked changes, and more. Includes critical gotchas for the docx-js library.

### doc-coauthoring

A three-stage workflow for collaborative document creation: Context Gathering (closes knowledge gaps), Refinement & Structure (section-by-section brainstorming/curation/drafting), and Reader Testing (validates with a fresh Claude instance). Works in Claude Code with sub-agents or in claude.ai with manual testing.

### deep-investigation

Structured investigation protocol using parallel sub-agents for evidence gathering. Enforces source citations on every claim, confidence classification (HIGH/MEDIUM/LOW), and produces structured reports with executive summaries, timelines, root cause analysis, and recommendations.

### investigation-synthesis

Takes raw investigation findings and transforms them through four layers (evidence, analysis, narrative, deliverable). Includes templates for 1-pagers and engineering briefs, an expert panel pattern (Skeptic/Operator/Executive), and the "reframe principle" for audience-appropriate delivery.

### reddit-research

Routes through Arctic Shift API (sees deleted/removed posts), Reddit JSON API (live data), and Playwright (fallback). Covers engagement metrics, tone assessment, user activity, subreddit discovery, shadowban detection, and batch analysis. Read-only research only.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI or IDE extension
- For `ffmpeg` skill: ffmpeg/ffprobe installed
- For `docx` skill: pandoc (reading), Node.js (creation via docx-js)
- For `reddit-research`: WebFetch tool access, curl

## Contributing

PRs welcome. Each skill should:
1. Have a `SKILL.md` with proper frontmatter (name, description)
2. Be self-contained (no external dependencies beyond standard tools)
3. Include examples where helpful
4. Follow the existing format

## License

MIT
