---
name: investigation-synthesis
description: |
  Transform investigation findings into clear, actionable deliverables. Use when
  synthesizing raw findings into 1-pagers, executive summaries, engineering briefs,
  or presentations that drive decisions.
license: MIT
---

# Investigation Synthesis Protocol

Transform raw investigation findings into clear, actionable deliverables that drive decisions.

## Overview

Investigation synthesis is the art of taking complex, multi-source findings and producing output that actually gets read and acted upon. Raw findings are useless if they sit in a document no one reads. The goal is not completeness - it's clarity and actionability.

This skill takes the output of deep-investigation and transforms it into the right format for the right audience.

## When to Use

- After completing a deep investigation and needing to present findings
- When translating technical findings for non-technical stakeholders
- When creating a 1-pager for leadership review
- When preparing an engineering brief for a team
- When summarizing research for a decision meeting
- When multiple investigations need to be combined into a single narrative

## The Synthesis Stack

Raw evidence flows through layers of increasing abstraction:

```
Layer 1: RAW EVIDENCE
  Logs, code, metrics, chat messages, issues, documentation
  (This is what deep-investigation produces)
          |
          v
Layer 2: ANALYZED FINDINGS
  Findings with confidence levels, citations, and connections
  (Patterns identified, hypotheses tested)
          |
          v
Layer 3: NARRATIVE
  A coherent story connecting findings to impact and action
  (Why this matters, what to do about it)
          |
          v
Layer 4: DELIVERABLE
  The right format for the right audience
  (1-pager, engineering brief, exec summary, presentation)
```

Most people jump from Layer 1 to Layer 4. This produces deliverables that are either too detailed (data dump) or too vague (unsupported claims). Always go through all four layers.

## 1-Pager Structure

The 1-pager is the most common synthesis deliverable. It must fit on a single page when printed.

### Template

```
# [Title - What This Is About in Plain Language]

## TL;DR
[2-3 sentences. The answer, the impact, the recommended action. If someone reads ONLY this, they should know what to do.]

## Background
[2-3 sentences. Why this investigation happened. What triggered it. Just enough context for someone unfamiliar.]

## Key Findings

1. **[Finding statement]** (Confidence: HIGH/MEDIUM/LOW)
   [One sentence of supporting evidence with citation]

2. **[Finding statement]** (Confidence: HIGH/MEDIUM/LOW)
   [One sentence of supporting evidence with citation]

3. **[Finding statement]** (Confidence: HIGH/MEDIUM/LOW)
   [One sentence of supporting evidence with citation]

[Maximum 5 findings. If you have more, you haven't prioritized.]

## Impact
[2-3 sentences. What this means in terms the audience cares about: customers affected, revenue impact, velocity impact, risk level.]

## Recommendations

| Priority | Action | Expected Outcome | Owner |
|----------|--------|-------------------|-------|
| P0 | [Action] | [Outcome] | [Team/Person] |
| P1 | [Action] | [Outcome] | [Team/Person] |
| P2 | [Action] | [Outcome] | [Team/Person] |

## Open Questions
- [What we still don't know]
- [What would help us know it]
```

### 1-Pager Rules

1. **It must fit on one page**. Not "about one page." One page. Print it and check.
2. **TL;DR is mandatory**. It's the most-read section. Write it last, after you understand everything.
3. **Maximum 5 key findings**. More than 5 means you haven't done the hard work of prioritizing.
4. **Every recommendation has an owner**. "We should do X" without an owner is a wish, not a plan.
5. **Impact is in audience terms**. Engineers get latency numbers. VPs get customer/revenue impact.
6. **No appendices on a 1-pager**. If they need the details, link to the full investigation.

## Expert Panel Pattern

For complex synthesis, use the expert panel pattern to pressure-test your narrative before finalizing.

### The Panel

Simulate three perspectives reviewing your synthesis:

```
Skeptic: "What's the weakest evidence here? What alternative
  explanations haven't been considered? Where are you most
  likely wrong?"

Operator: "Can I act on these recommendations tomorrow? What's
  missing for execution? What dependencies aren't mentioned?
  What will go wrong when we try to implement this?"

Executive: "Why should I care? What's the business impact in
  one sentence? Is this a P0 or noise? What decision do you
  need from me?"
```

### Running the Panel

1. Draft your synthesis
2. Run each panel member's questions against it
3. Revise based on gaps identified
4. If any panel member's core question can't be answered, the synthesis isn't ready

### When to Use the Panel

- Always for P0/P1 recommendations
- Always for deliverables going to leadership
- Optional for internal team briefs
- Skip for status updates and FYIs

## Engineering Context Structure

When the audience is engineers, use this structure instead of the 1-pager:

### Template

```
# [System/Component]: [Issue/Question in Technical Terms]

## Summary
[3-5 sentences. Technical summary with specific metrics, error codes, or system names. Written for someone who knows the system.]

## Investigation Scope
- **Time range**: [Start - End]
- **Systems examined**: [List]
- **Data sources**: [Logs, metrics, code, issues, chat]

## Findings

### Finding 1: [Technical Statement]
**Confidence**: HIGH/MEDIUM/LOW

[Detailed technical explanation with code snippets, metric data, or log excerpts]

**Evidence**:
- [Citation 1 with source]
- [Citation 2 with source]
- [Citation 3 with source]

### Finding 2: [Technical Statement]
**Confidence**: HIGH/MEDIUM/LOW

[Detailed technical explanation]

**Evidence**:
- [Citations]

## Root Cause Chain

[Trigger Event]
  -> [First consequence]
    -> [Second consequence]
      -> [Observed symptom]

## Reproduction Steps (if applicable)
1. [Step]
2. [Step]
3. [Expected vs actual behavior]

## Fix / Mitigation

### Immediate (P0)
- [ ] [Action with specific file/config/service]
- [ ] [Verification step]

### Short-term (P1)
- [ ] [Action]
- [ ] [Verification step]

### Long-term (P2)
- [ ] [Architectural change or process improvement]

## Related
- [Links to issues, docs, previous investigations]
```

### Engineering Context Rules

1. **Be specific**. "The service is slow" -> "P99 latency increased from 45ms to 1200ms on the /api/search endpoint starting 2026-04-01 14:32 UTC"
2. **Include reproduction steps** when the issue is reproducible
3. **Root cause chain** shows the causal path, not just the symptom
4. **Fix sections are checkboxes**, not paragraphs. Engineers need todo lists.
5. **Link everything**. Issue IDs, file paths, metric dashboards, chat threads.

## Presentation Anti-Patterns

Things that make deliverables get ignored:

### The Data Dump
**Symptom**: 15 pages of findings with no narrative or prioritization.
**Fix**: Force yourself through all 4 synthesis layers. What's the story? What matters most?

### The Unsupported Claim
**Symptom**: "The service is unreliable" with no metrics, no incidents, no evidence.
**Fix**: Every claim needs a citation. If you can't cite it, caveat it or remove it.

### The Buried Lead
**Symptom**: The most important finding is on page 3, paragraph 4.
**Fix**: TL;DR goes first. Most important finding is Finding #1. Ruthlessly reorder by importance.

### The Kitchen Sink
**Symptom**: Includes everything found during investigation, regardless of relevance.
**Fix**: Ask "does this finding change the recommendations?" If no, cut it.

### The Passive Voice Problem
**Symptom**: "It was determined that improvements could be made..."
**Fix**: "Connection pool exhaustion caused 2,400 failed transactions. Increase pool size to 50."

### The Missing "So What"
**Symptom**: Detailed findings but no impact assessment or recommendations.
**Fix**: Every finding needs a "so what" - why does this matter? What should change?

### The Jargon Wall
**Symptom**: Audience is VPs, document reads like a kernel patch description.
**Fix**: Match language to audience. Translate technical findings to business impact.

### The Recommendation Without Evidence
**Symptom**: "We recommend migrating to Service X" with no supporting analysis.
**Fix**: Every recommendation traces back to evidence. "Because [finding] shows [evidence], we recommend [action]."

## The Reframe Principle

The most powerful synthesis technique: reframe findings in terms of what the audience values.

### For Engineering Teams
- Frame as: system reliability, developer velocity, technical debt reduction
- Metrics: latency, error rates, deployment frequency, incident count

### For Engineering Leadership
- Frame as: risk, capacity, reliability trends, team efficiency
- Metrics: MTTR, incident severity trends, capacity utilization, sprint velocity

### For Business Leadership
- Frame as: customer impact, revenue risk, competitive position, operational cost
- Metrics: customer-facing errors, revenue at risk, market comparisons, cost trends

### For Product Teams
- Frame as: user experience, feature velocity, quality metrics
- Metrics: user-facing error rates, feature delivery timelines, NPS/satisfaction impact

### The Reframe Test

Take your most important finding and express it for each audience:

```
Technical: "P99 latency on /api/search exceeds 1200ms due to connection pool exhaustion"
Eng Lead:  "Search reliability has degraded 26x, causing 3 P2 incidents this quarter"
Business:  "Search failures affect ~2,400 daily transactions worth ~$180K in GMV"
Product:   "1 in 50 customer searches fails, driving support contacts up 15%"
```

Same finding. Different framing. Each audience gets what they need to act.

## Red Flags

You're doing synthesis wrong if:

- **No TL;DR**: If someone has to read the whole document to understand the conclusion, you've failed
- **More than 5 key findings**: You haven't prioritized. Cut to what matters.
- **Recommendations without owners**: Unowned recommendations don't get done
- **Impact in technical terms for non-technical audience**: Match language to audience
- **No confidence levels**: Not all findings are equally certain. Show your uncertainty.
- **Raw tool output in the deliverable**: Synthesize. Don't paste.
- **Deliverable longer than needed**: A 1-pager that's 3 pages is not a 1-pager
- **Missing open questions**: Pretending you know everything undermines credibility
- **No expert panel review for P0/P1**: High-priority deliverables need pressure-testing
- **Same format for every audience**: Engineers and VPs need different deliverables
- **Findings without "so what"**: Every finding must connect to impact or action
- **Burying the lead**: The most important thing goes first, not last
