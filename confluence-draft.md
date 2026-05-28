# Autonomous AI Exploratory Testing

**Audience:** QA + Engineering leadership
**Status:** Proposal — this document is the first step

---

## TL;DR

Today we have two ways to test our software:
- **Manual exploratory testing** finds the bugs that matter, but a tester can only cover so much in a day.
- **Automated regression tests** scale, but they only re-check what we already knew to write — they don't discover anything new.

Between these two sits the work nobody is doing at scale: **exploring** the product the way a senior tester would, on every build, across every feature, looking for the bugs nobody thought to test for.

This document proposes that we close that gap with **AI agents that explore the product on our behalf** — running continuously, producing structured findings, and freeing our human testers to focus on the work only humans can do.

This document is the first step. If the direction is endorsed, the next step is a small pilot to validate the approach on a real product surface.

---

## Why we're proposing this

### Manual exploratory testing — where it falls short

- **It doesn't scale.** A senior tester can deeply explore roughly one feature per hour. With dozens of features changing every week, most of the product goes unexplored between releases.
- **It depends on who's available.** The same feature tested by two people produces different results. The same person on a tired day misses what they'd catch on a sharp one.
- **The knowledge stays in heads.** Our most experienced testers carry years of intuition that new hires re-learn from scratch.
- **Coverage is invisible.** After a session, it's hard to answer "what *didn't* we test?" — we know what was found, not what was skipped.
- **It's expensive.** Exploratory testing is expert work, and expert time is our most constrained resource. We ration it to the highest-risk features and accept blind spots everywhere else.

### Automated regression testing — where it can't reach

- **It verifies, it doesn't explore.** A scripted test only confirms what we already wrote it to check. A bug nobody anticipated stays hidden across green builds.
- **It's brittle.** Tests break on cosmetic changes — selector renames, copy tweaks, layout shifts. Often the maintenance costs more time than the defects the tests catch.
- **It's slow to grow.** New features take days to write meaningful coverage for. The newest code — which carries the most risk — has the thinnest safety net.
- **It tests one thing at a time.** Functional tests don't catch accessibility regressions. Accessibility scans don't catch broken business logic. Each domain has its own tools, owners, and gaps.
- **It has no judgment.** A scripted check confirms "the button exists." It doesn't ask "would a real user understand what this button does?"

### The gap in the middle

Scripted automation answers *"did the thing we wrote still work?"*. Manual exploratory answers *"what's broken that we didn't think to check?"*. We have no scalable answer to the second question — and that's where most user-impacting defects live.

---

## The goal

We want AI agents that, given a target product and a focus area, behave like a senior tester for the length of a session:

- Decide what's worth exploring
- Probe the product the way a curious, skeptical human would
- Judge whether what they find is correct or broken
- Write up findings clearly enough for any engineer to triage
- Run alongside our existing tools, not instead of them

Concretely, we want a future where:

1. **Every staging build** can trigger an exploratory pass without booking a tester's calendar.
2. **Every finding** arrives with clear reproduction steps, evidence, and severity — ready to triage on first read.
3. **Coverage is auditable** — every session leaves a record of what was tested and what was skipped.
4. **The methodology is the artifact** — what our best testers know lives in the system, not just in their heads.
5. **It works with whichever AI tools each team prefers** — no vendor lock-in.

This is **not** a replacement for our human testers. It is a force multiplier — humans set the direction and review what matters; the agent handles the high-volume probing.

---

## What this unlocks

### For engineering
- **Faster feedback on every change.** Exploratory passes happen on every staging build, not only when a tester has bandwidth.
- **Less brittle automation to maintain.** Stop scripting flows the agent can discover unprompted. Reserve scripted tests for the few things that truly need a guard-rail.
- **Broader coverage from one system.** Functional behavior, security, accessibility, performance — the same framework, different points of view.

### For QA
- **Senior judgment, available everywhere.** The intuition our best testers carry becomes a reusable system every team can benefit from.
- **Continuous discovery, not scheduled.** Exploration runs on every release candidate, not when the calendar allows.
- **Better-formed findings to triage.** Every finding lands with reproduction steps, evidence, and a suggested severity. Triage gets faster, not slower.
- **Visible coverage.** For the first time, we can show what was tested *and* what was skipped — and why.

### For product and leadership
- **Earlier signal on risk.** Regressions surface in days, not weeks or post-release.
- **Auditability.** Every session is a reproducible record. Anyone can re-run it.
- **Compounding value.** Every improvement to the methodology benefits every future session, across every team.

### What it does NOT promise
- It doesn't replace senior testers — it amplifies them.
- It will produce false positives; findings still need human triage.
- It is not a substitute for security penetration tests, formal accessibility audits, or load testing at scale. Think of it as continuous coverage *beneath* those targeted efforts.

---

## High-level architecture

The system has three independent pieces that work together. Each piece has one job, and none of them know about the others — they're combined at the top.

```
┌─────────────────────────────────────────────────────────────┐
│                    Composition layer                        │
│  Decides which pieces to combine for any given session      │
└────────────────────────────────┬────────────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
┌──────────────────┐  ┌───────────────────────┐  ┌─────────────────────┐
│   The Driver     │  │     The Rulebook      │  │      The Lens       │
│                  │  │                       │  │                     │
│ Opens a real     │  │ Universal rules every │  │ The point of view   │
│ browser, clicks  │  │ session follows: how  │  │ for this session —  │
│ around, captures │  │ findings are written, │  │ functional,         │
│ evidence, writes │  │ how coverage is       │  │ security,           │
│ everything down  │  │ logged, how a session │  │ accessibility, or   │
│ in real time.    │  │ is sized.             │  │ performance.        │
└──────────────────┘  └───────────────────────┘  └─────────────────────┘
                                 │
                                 ▼
                ┌────────────────────────────┐
                │   Session output           │
                │                            │
                │   Reproducible record:     │
                │   what was tested,         │
                │   what was found,          │
                │   what was skipped.        │
                └────────────────────────────┘
```

### What each piece does

| Piece | Responsibility |
|---|---|
| **The Driver** | The part that actually *uses* the product — opens a browser, navigates, fills forms, captures screenshots, writes everything down as it goes. |
| **The Rulebook** | Universal conventions every session follows: how findings are formatted, how coverage is logged, how long a session lasts. The same rules apply no matter what we're testing. |
| **The Lens** | The point of view we're testing from — functional flows, security, accessibility, or performance. New lenses can be added without changing anything else. |
| **The Composition layer** | The thin glue at the top that decides, for any given session: which Driver, which Rulebook, which Lens. |

### Why this matters

- **Each piece has one job.** The Driver doesn't know what "good" looks like — that's the Lens's job. The Lens doesn't know how to open a browser — that's the Driver's job. The Rulebook doesn't care which Lens is loaded — it's universal. This separation is what makes the system easy to extend and easy to reason about.
- **New lenses drop in cleanly.** Want to add a new domain — say, visual quality or content review? Add a new Lens; the Driver and Rulebook don't change.
- **It's vendor-neutral.** The system can be driven by whichever AI tools each team already uses.

---

## How a session works (in plain terms)

A typical session is short — about 15 minutes by default — and follows this shape:

1. **Set up.** Pick the target URL, the focus area, and the environment. Production is off-limits by default.
2. **Plan.** Write down what we're trying to find and where to look first.
3. **Explore.** Drive the product, probe it from a few different user perspectives, judge what we see, and write down findings the moment they're found.
4. **Wrap up.** Produce a short report — findings, severity, what was tested, what was skipped — ready to share.

### Built-in guardrails

- **Production is off-limits** unless explicitly authorized and logged.
- **Credentials are redacted** in every output.
- **Nothing is buffered** — every event is written down the moment it happens, so a crash never costs prior findings.
- **Sessions are reproducible** — anyone can re-run a session from its recorded output.

---

## Proposed next steps

If the direction in this document is endorsed, the proposed sequence is:

1. **Scoped pilot.** Pick one product surface (one team, one feature area) and run the approach end-to-end against staging. Goal: produce real session output we can review together.
2. **Compare against current coverage.** Overlay pilot findings against existing automated tests and recent manual exploratory passes. Quantify overlap, marginal lift, and false-positive rate.
3. **Wire into the release pipeline.** Once the pilot signal is positive, attach exploratory sessions to staging deploys and post results back to the originating PR or ticket.
4. **Rollout playbook.** Onboard additional teams with documented practices and triage process.
5. **Benchmark continuously.** Track defects-found vs. defects-escaped, time-to-triage, and maintenance hours saved.

---

## Open questions for this review

1. **Where does this slot into our release pipeline?** Pre-merge, post-merge, nightly, on-demand — or some combination?
2. **Who triages the agent's findings?** A rotating QA shift, the PR author, a dedicated reviewer?
3. **Which teams pilot first?** Suggestion: one team with strong existing automation (to measure overlap), one with thin automation (to measure lift).
4. **What's the success metric for a 90-day pilot?** Candidates: defects-found-vs-escaped, time-to-triage, maintenance hours saved, regression discovery rate.
5. **Where does this stop?** Explicit non-goals to keep scope honest — e.g., load testing at scale, multi-user race conditions, mobile-native apps.
