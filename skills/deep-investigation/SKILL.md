---
name: deep-investigation
description: |
  Structured, evidence-based investigation protocol for bugs, outages, system behavior,
  or complex technical questions. Uses parallel sub-agents for evidence gathering,
  enforces source citations, confidence classification, and produces actionable reports.
license: MIT
---

# Deep Investigation Protocol

Structured, evidence-based investigation for bugs, outages, system behavior, and complex technical questions.

## Overview

Deep investigation is a systematic approach to understanding complex technical problems. It combines structured research with evidence gathering, confidence classification, and actionable output. Every claim must be backed by evidence. Every recommendation must be grounded in data.

## When to Use

- Production incidents or outages requiring root cause analysis
- Bugs that span multiple services or systems
- Performance degradations with unclear origins
- Architecture questions requiring evidence from multiple sources
- Any question where "I think" is not good enough - you need "the evidence shows"

## The Iron Law

EVERY INVESTIGATION USES SUBAGENTS. EVERY CLAIM HAS A SOURCE. EVERY RECOMMENDATION HAS EVIDENCE.

No exceptions. No shortcuts. No "I'm pretty sure" without citations.

## Investigation Flow

```
Start
  |
  +-> Define the question precisely
  |     What EXACTLY are we investigating?
  |     What would "answered" look like?
  |
  +-> Gather evidence (parallel subagents)
  |     +-- Logs / metrics
  |     +-- Code analysis
  |     +-- Issue/ticket history
  |     +-- Chat/communication threads
  |     +-- Documentation
  |     +-- External resources
  |
  +-> Analyze evidence
  |     +-- Correlate timelines
  |     +-- Identify patterns
  |     +-- Test hypotheses
  |     +-- Eliminate alternatives
  |
  +-> Classify confidence
  |     HIGH / MEDIUM / LOW for each finding
  |
  +-> Synthesize findings
  |     Executive summary + detailed analysis
  |
  +-> Produce actionable output
        Recommendations with evidence backing
```

## Subagent Patterns

### Evidence Gathering (Parallel)

Deploy multiple subagents simultaneously for independent evidence streams:

```
Subagent 1: "Search communication channels for [error message / service name / incident]. Look for:
  - When the issue was first reported
  - Who reported it
  - Any workarounds discussed
  - Related incidents
  Return: timeline of relevant messages with channel, author, date, and quote."

Subagent 2: "Search issue tracker for [service / component / error]. Look for:
  - Open issues related to this problem
  - Resolved issues with similar symptoms
  - Any patterns in frequency or severity
  Return: list of relevant issues with ID, status, summary, and resolution."

Subagent 3: "Search codebase for [function / pattern / config]. Look for:
  - Recent changes to related code
  - Configuration that could cause this behavior
  - Error handling patterns
  Return: relevant code snippets with file paths and recent commit history."

Subagent 4: "Search documentation for [system / process / architecture]. Look for:
  - Design documents describing expected behavior
  - Runbooks for this type of issue
  - Known limitations or caveats
  Return: relevant documentation excerpts with source links."
```

### Analysis (Sequential After Gathering)

After evidence is gathered, analyze in the parent context or with a dedicated analysis subagent:

```
Analysis Subagent: "Given the following evidence:
  [Evidence from Subagent 1]
  [Evidence from Subagent 2]
  [Evidence from Subagent 3]
  [Evidence from Subagent 4]

  1. Correlate timelines - what happened in what order?
  2. Identify the most likely root cause
  3. List alternative hypotheses and why they're less likely
  4. Recommend next steps with confidence levels"
```

### Local Verification (When Applicable)

```
Verification Subagent: "Run the following to verify hypothesis:
  1. [specific command or check]
  2. [specific command or check]
  Report: exact output, whether it confirms or refutes the hypothesis"
```

## Source Citation Requirements

Every finding MUST include a source. No exceptions.

### Citation Format

- **Chat/Slack**: `[#channel-name, @author, YYYY-MM-DD]` with relevant quote
- **Issue/Ticket**: `[ISSUE-1234: "Title"]` with status and relevant details
- **Code**: `[file/path.ext:L42-L58]` with relevant snippet
- **Documentation**: `[Doc: "Title" - section name]` with relevant excerpt
- **Logs/Metrics**: `[Monitoring / service-name, YYYY-MM-DD HH:MM]` with relevant data
- **External**: `[URL - "Title"]` with relevant excerpt
- **Verbal/Meeting**: `[Verbal: @person, YYYY-MM-DD, context]` - use sparingly

### Citation Rules

1. If you cannot cite a source, mark the claim as `[UNCITED - needs verification]`
2. Never present uncited claims as facts
3. Prefer primary sources (code, logs) over secondary (chat discussions)
4. When sources conflict, note the conflict and assess which is more reliable

## Confidence Classification

Every finding gets a confidence level:

### HIGH Confidence
- Multiple independent sources agree
- Directly observable in code or logs
- Reproducible behavior
- Confirmed by system owner or domain expert

### MEDIUM Confidence
- Single reliable source
- Consistent with observed behavior but not directly proven
- Logical inference from high-confidence findings
- Uncontradicted by other evidence

### LOW Confidence
- Based on limited evidence
- Inference chain longer than 2 steps
- Contradicted by some evidence
- Based on outdated information
- Relies on assumptions about undocumented behavior

### Marking Confidence

```
**Finding**: The timeout occurs because connection pool exhaustion triggers retry storms.
**Confidence**: HIGH
**Evidence**:
  - Connection pool metrics show saturation at 14:32 [Monitoring, 2026-04-01]
  - Retry logic has no backoff [src/client.ts:L89-L102]
  - Three similar incidents in past quarter [ISSUE-456, ISSUE-789, ISSUE-1012]
```

## Output Structure

Every investigation produces a structured report:

### 1. Executive Summary (3-5 sentences max)

What happened, why, what to do about it. Written for someone who will read ONLY this section.

### 2. Investigation Question

The precise question being investigated, stated clearly and unambiguously.

### 3. Key Findings

Numbered list of findings, each with:
- The finding statement
- Confidence level (HIGH/MEDIUM/LOW)
- Supporting evidence with citations

### 4. Timeline (if applicable)

Chronological sequence of relevant events with timestamps and sources.

### 5. Root Cause Analysis (if applicable)

- Primary cause with evidence
- Contributing factors
- Why existing safeguards didn't prevent it

### 6. Alternative Hypotheses Considered

What else could have caused this, and why those are less likely. This section builds credibility.

### 7. Recommendations

Numbered list, each with:
- The recommendation
- Expected impact
- Evidence supporting this recommendation
- Priority (P0/P1/P2)

### 8. Open Questions

What we still don't know and what would be needed to find out.

## Executive Summary Rules

The executive summary is the most important section. Most readers will read ONLY this.

1. **Lead with the answer**, not the question
   - BAD: "We investigated the timeout issue and found several factors..."
   - GOOD: "Connection pool exhaustion caused cascading timeouts in the payment service starting at 14:32 UTC."

2. **Include the impact**
   - "This affected ~2,400 transactions over 47 minutes."

3. **Include the fix or next step**
   - "Increasing pool size to 50 and adding exponential backoff will prevent recurrence."

4. **Maximum 5 sentences**. If you need more, your summary isn't summarized enough.

5. **No jargon without context**. If a VP couldn't understand it, rewrite it.

## Local Verification Guide

When possible, verify findings locally before reporting:

### Code Verification
- Read the actual code, don't rely on descriptions of it
- Check git blame for recent changes to relevant files
- Verify configuration values match what documentation claims

### Reproduction
- If the issue is reproducible, reproduce it
- Document exact steps and exact output
- Note any differences from the reported behavior

### Metric Verification
- Cross-reference metrics from multiple sources
- Check for data collection gaps or anomalies
- Verify metric definitions match what you think they measure

### What NOT to Verify Locally
- Don't run destructive operations
- Don't access production systems without explicit permission
- Don't modify configuration to "test a theory" without approval

## Subagent Prompt Template

Use this template when dispatching investigation subagents:

```
"Investigate [SPECIFIC QUESTION].

Context: [Brief background - 2-3 sentences max]

Search the following sources:
1. [Source 1 with specific search terms]
2. [Source 2 with specific search terms]
3. [Source 3 with specific search terms]

For each finding, provide:
- The fact or observation
- The exact source (channel, issue ID, file path, URL)
- A relevant quote or data point
- Your assessment of reliability (HIGH/MEDIUM/LOW)

Return findings as a numbered list. If you find nothing relevant, say so explicitly - do not pad with tangential information."
```

## Red Flags

You're doing it wrong if:

- **No citations**: Any finding without a source is an opinion, not an investigation
- **Single source**: Relying on one source for critical findings is fragile
- **No confidence levels**: Every finding needs a confidence assessment
- **Parent context research calls**: All research goes through subagents
- **Confirmation bias**: Only looking for evidence that supports your first theory
- **Missing alternatives**: Not considering other explanations
- **Vague recommendations**: "We should look into this" is not a recommendation
- **No executive summary**: If leadership can't get the answer in 30 seconds, the report fails
- **Sequential research**: Independent evidence streams should be gathered in parallel
- **Mixing facts and opinions**: Facts have citations. Opinions are clearly labeled as such.

## Common Mistakes

| Mistake | Correction |
|---------|------------|
| Starting with a conclusion, then finding evidence | Start with evidence, then draw conclusions |
| Reporting everything found | Report only what's relevant to the investigation question |
| Treating chat messages as authoritative | Chat is leads/context, not source of truth. Verify in code/logs. |
| Ignoring contradictory evidence | Contradictory evidence is the MOST important evidence |
| Confidence: HIGH on everything | If everything is HIGH confidence, you're not being honest |
| Skipping the "alternatives considered" section | This section is what separates investigation from guessing |
| 20-paragraph executive summary | 5 sentences max. Ruthlessly cut. |
| Recommending without evidence | Every recommendation needs a "because [evidence]" |
| Not stating what you DON'T know | Open questions build trust and guide next steps |
| Copy-pasting raw tool output | Synthesize and cite. Raw output is not analysis. |
