# Autonomous AI Exploratory Testing — Implementation Plan

**Companion to:** `confluence-draft.md` (the high-level proposal)
**Audience:** QA + Engineering leadership and the build team
**Status:** Proposed sequence — for discussion and refinement

---

## How to read this document

This is a sequenced backlog. Each phase delivers something usable on its own — there's no "everything has to ship before anything works." Phases stack: each one assumes the previous is in place.

For every story:
- **Goal** — what we're trying to achieve, in plain language.
- **Done when** — what "complete" looks like.
- **Notes** — design decisions worth flagging.

The phases map to the three architecture pieces from the proposal:
- **The Driver** (browser orchestration) → Phase 2
- **The Rulebook** (universal rules) → Phase 1
- **The Lens** (testing point of view) → Phases 3 and 6

Composition, safety, agent integration, reporting, pilot, rollout fill in the rest.

---

## Phase 1 — Foundations

**Goal of the phase:** Stand up the skeleton — folders, contracts, and the universal rules that every later piece will obey.

### Story 1.1 — Repository structure and module contracts
- **Goal:** Decide the shape of the codebase. Each of the three pieces (Driver / Rulebook / Lens) lives in its own folder and doesn't reach into the others.
- **Done when:** Folder structure exists. A short contract per folder explains what it owns and what it doesn't. The top-level README points to each.
- **Notes:** This is the most load-bearing decision. The single-responsibility split is what lets us add new lenses later without touching the Driver, and lets us swap agents without touching the Rulebook.

### Story 1.2 — Universal testing conventions (the Rulebook)
- **Goal:** Write down the rules every session follows, regardless of what we're testing.
- **Done when:** A short doc defines:
  - Finding ID format (sequential, no per-domain prefix)
  - A simple severity scale (Critical / High / Medium / Low / Info)
  - Time-budget tiers (5 / 10 / 15 / 20 / 25–30 min) and what scales with each
  - Coverage logging — how a session records what was tested *and* what was skipped, with reasons
  - Missed-coverage reporting at session end
- **Notes:** "Skipped with reason" is the discipline that turns invisible coverage into auditable coverage.

### Story 1.3 — Agent-neutral entry point
- **Goal:** Write the one document an AI agent reads to know how to compose the pieces.
- **Done when:** A single entry-point file describes the composition rule ("for any session, load the Driver + the Rulebook + one Lens"), the phases of a session, and the safety guardrails. No agent-specific syntax.
- **Notes:** Specific AI tools get thin adapter files later (Phase 4 and Phase 7) — they all point back to this one document.

---

## Phase 2 — The Driver (browser orchestration)

**Goal of the phase:** Stand up the part that actually uses the product — browser, session folder, evidence capture, audit trail.

### Story 2.1 — Browser tooling and environment checks
- **Goal:** Pick the browser automation tool, write an environment-check script, and a host-check script that refuses production by default.
- **Done when:** Running the env check confirms the browser tool is available; running the host check against a production URL refuses unless explicitly authorized.
- **Notes:** Recommend a CLI-driven browser tool (e.g., Playwright CLI) so each agent can drive it via simple shell commands instead of needing a language-specific SDK.

### Story 2.2 — Session folder model
- **Goal:** Define the on-disk shape of every session. The session folder *is* the deliverable.
- **Done when:** Initializing a new session produces a folder with:
  - A metadata file (target, environment, time limit, mission)
  - An empty append-only event log
  - Empty sub-folders for findings, evidence, and DOM snapshots
- **Notes:** Naming convention should include timestamp, lens, and feature so sessions are sortable and identifiable at a glance.

### Story 2.3 — Atomic action scripts
- **Goal:** Wrap every session mutation (navigate, screenshot, log an event, write a finding) behind a small shell script. The agent calls scripts; it never hand-writes to the audit log or finding files directly.
- **Done when:** A small library of scripts exists covering:
  - Navigate to a URL (with the production guardrail invoked automatically)
  - Take a screenshot and log it as evidence in the same call
  - Log a pass / fail check
  - Write a finding (with severity, type, reproduction steps)
  - Append a generic audit entry
- **Notes:** This is the discipline layer. Atomic scripts make sessions deterministic, auditable, and re-runnable. Without them, every session has subtle format drift.

### Story 2.4 — Evidence policy and real-time persistence
- **Goal:** Decide how much evidence to keep, where, and when it's written.
- **Done when:**
  - Screenshots and videos are capped per session (to avoid runaway storage)
  - DOM snapshots are uncapped on disk but never dumped into chat
  - Every event hits disk the moment it happens — no buffering across the session
- **Notes:** Real-time persistence is the safety net. If the agent crashes mid-session, prior findings are already on disk.

---

## Phase 3 — The first Lens (Functional)

**Goal of the phase:** Prove the architecture works end-to-end with one testing domain — user flows and business logic.

### Story 3.1 — Lens contract / skill shape
- **Goal:** Define what every Lens must provide so the Driver can load it.
- **Done when:** Each Lens has a standard structure: a workflow doc, a heuristics reference, optional oracles reference, a time-budget scaling table, and any domain-specific required finding fields.
- **Notes:** Lenses are libraries, not entry points. The Driver loads them; they never run standalone.

### Story 3.2 — Functional testing methodology
- **Goal:** Write the Functional Lens — how to map scenarios, classify them, and probe them.
- **Done when:** The Lens defines:
  - A required "mission statement" the agent writes before any browser action
  - Scenario profiling (a scenario tagged "involves creating/updating/deleting" gets a different mandatory probe set than one tagged "submits an action" or "displays a list")
  - A short library of coverage dimensions to probe (sequence, primary function, data, platform, operations, time)
  - A short library of "sources of truth" (oracles) the agent uses to decide pass vs. fail
- **Notes:** Mandatory probes vs. optional probes — the floor vs. the ceiling. Mandatory probes don't get skipped under time pressure; fewer scenarios with full coverage beats more scenarios with shallow coverage.

### Story 3.3 — Tester perspectives catalogue
- **Goal:** Capture the different lenses a senior tester applies to the same flow — naïve user, hostile user, accessibility user, distracted user, returning user, and so on.
- **Done when:** A catalogue exists of 8–12 perspectives. For each scenario in a session, the agent picks 2–3 perspectives to probe from.
- **Notes:** This is the "thinking like a real tester" layer. Perspectives are orthogonal to lenses — useful in functional, security, accessibility, and performance sessions alike.

### Story 3.4 — First canonical end-to-end example
- **Goal:** Run the system against a real public site, end to end, and commit the resulting session folder as a reference.
- **Done when:** A complete session folder lives in the repo and is reproducible by anyone with the toolkit. It includes a real mission, real findings, and real evidence.
- **Notes:** The example doubles as a regression check — if a future change breaks the canonical session, we know.

---

## Phase 4 — First agent integration and safety

**Goal of the phase:** Make the system actually run autonomously, end to end, in at least one AI tool, with the safety guardrails in place.

### Story 4.1 — First agent adapter
- **Goal:** Pick one AI tool (recommend whichever the team uses most) and write the thin adapter that points it at the entry-point document and pre-approves the safe tool patterns.
- **Done when:** A 15-minute session runs end to end in this tool with **zero approval prompts**. If a prompt appears, the missing pattern goes into the allowlist.
- **Notes:** Approval prompts are the friction that kills autonomy. Pre-approve everything safe; deny everything destructive.

### Story 4.2 — Prompt grammar
- **Goal:** Define the shape of the prompt an operator types to kick off a session.
- **Done when:** The grammar covers:
  - Target URL
  - Authentication (none, form login, single sign-on, basic auth, API key, multi-factor)
  - Focus area (the Lens to load)
  - Continuation (resume the last session or a specific one)
- **Notes:** Defaults applied silently — the agent only asks the operator for values that can't be defaulted.

### Story 4.3 — Production guardrail
- **Goal:** Block sessions against production hosts by default. Allow explicit override with a logged justification.
- **Done when:** A host-check script gates every navigation. Override requires an environment variable with a justification string; the justification is recorded in the audit log.
- **Notes:** This is the most important safety rail. Production is off-limits until someone says, in writing, why it isn't.

### Story 4.4 — Credential handling and deny-lists
- **Goal:** Credentials never appear in any output. Destructive shell patterns are blocked even in autonomous mode.
- **Done when:**
  - Credentials supplied to the agent are redacted in logs, findings, and reports
  - The agent cannot run wildcard deletions, modify git state, or make outbound HTTP calls outside the browser tool
- **Notes:** The deny list is the circuit breaker. Autonomous mode means "approve a lot" — it doesn't mean "approve everything."

---

## Phase 5 — Reporting and validation

**Goal of the phase:** Turn the raw session folder into something a human can read in 30 seconds.

### Story 5.1 — Session close routine
- **Goal:** When a session ends, recompute counters (number of findings by severity), set the session status, and emit a one-line summary.
- **Done when:** A close script wraps every session. Status changes from "running" to "completed." Counters in the metadata file match the audit log.

### Story 5.2 — Compliance validation
- **Goal:** After close, verify the session followed the rules — coverage was logged, every failed check has a finding file, every finding has the required fields.
- **Done when:** A validation script exits clean for compliant sessions and reports specific violations otherwise.
- **Notes:** Catches discipline drift early. Non-compliant sessions are flagged, not silently accepted.

### Story 5.3 — Human-readable report and chat summary
- **Goal:** Generate a short report.md from the raw artifacts and print a chat-friendly summary block.
- **Done when:** A reviewer can open the report, see findings by severity, see what was tested vs. skipped, and triage in minutes.
- **Notes:** The folder is the source of truth; the report is the convenience layer.

---

## Phase 6 — Expand the Lenses

**Goal of the phase:** Prove the architecture supports multiple domains without changing the Driver or the Rulebook.

### Story 6.1 — Security testing lens
- **Goal:** Add a Lens for security — authentication, authorization, input handling, data exposure, configuration.
- **Done when:** The Lens defines attack categories (one per session by default), a surface-mapping step before any probes, stricter reproducibility requirements per finding, and mapping to an industry-standard reference catalogue.
- **Notes:** Security findings need higher rigor than functional ones — payload, exploit path, impact statement.

### Story 6.2 — Accessibility testing lens
- **Goal:** Add a Lens for accessibility — keyboard use, focus behavior, form labels, semantic structure.
- **Done when:** The Lens defines an automated sweep, an ordered set of manual checks, and a mapping from each finding to the relevant accessibility standard. Findings carry both a severity and a user-impact classification.

### Story 6.3 — Performance testing lens
- **Goal:** Add a Lens for performance — console errors, failed or slow requests, load timing, runtime stability.
- **Done when:** The Lens captures a baseline before any probes, attributes every finding to a specific component or request, and includes observed-vs-threshold timing on every finding.
- **Notes:** No raw HAR dumps in findings — compact summaries only.

---

## Phase 7 — Cross-agent compatibility

**Goal of the phase:** Free the team to use whichever AI tool they prefer.

### Story 7.1 — Second agent adapter
- **Goal:** Pick a second commonly-used AI tool and write its adapter.
- **Done when:** A session runs end to end in this tool with zero approval prompts.

### Story 7.2 — Third agent adapter and verification matrix
- **Goal:** Add at least one more adapter and document the verification steps for each tool.
- **Done when:** A short matrix lives in the repo: which tools are verified, which version, what config is required.

### Story 7.3 — Verify the universal entry point works for the long tail
- **Goal:** Confirm that any tool that can read the universal entry-point document can run a session, even without a dedicated adapter.
- **Done when:** A "no adapter" tool successfully completes a session.

---

## Phase 8 — Pilot

**Goal of the phase:** Validate that the system finds defects we care about on real product surfaces.

### Story 8.1 — Pick pilot surface and define success metrics
- **Goal:** Choose one product surface, one team, one feature area. Agree on what "success" looks like.
- **Done when:** Pilot scope is one page. Success metrics are written down: e.g., defects-found vs. defects-escaped, time-to-triage, false-positive rate, maintenance hours saved.
- **Notes:** Pick a surface with both strong existing automated coverage (so we can measure overlap) *and* manual exploratory history (so we can measure marginal lift).

### Story 8.2 — Baseline
- **Goal:** Before introducing the system, capture what current testing finds on the pilot surface.
- **Done when:** A snapshot exists of: scripted-test coverage, recent manual exploratory findings, recent escaped defects.

### Story 8.3 — Pilot run and comparison report
- **Goal:** Run the system against the pilot surface for an agreed period (suggest 4–6 weeks). Compare findings against baseline.
- **Done when:** A report documents:
  - Defects found that scripted tests missed
  - Defects found that manual exploratory missed
  - False positives and their causes
  - Effort spent triaging the agent's output

---

## Phase 9 — Release pipeline integration

**Goal of the phase:** Move from "manually triggered" to "runs on every staging build."

### Story 9.1 — CI trigger on staging deploys
- **Goal:** Wire a session into the staging-deploy pipeline. When a build hits staging, an exploratory session runs against it.
- **Done when:** Every staging deploy produces a session folder automatically. The session respects the production guardrail (staging is allowed; production is not).

### Story 9.2 — Post results to PR or ticket
- **Goal:** When the session completes, post the report summary back to the originating PR or ticket.
- **Done when:** PR reviewers see exploratory findings inline, with links to the full session folder.

### Story 9.3 — Triage routing
- **Goal:** Decide who looks at the findings and on what schedule.
- **Done when:** A documented routing rule exists — e.g., "PR author triages first; QA reviews escalations; security findings page the on-call."
- **Notes:** Without clear routing, findings pile up unread.

---

## Phase 10 — Rollout and continuous benchmarking

**Goal of the phase:** Scale to additional teams and keep proving value.

### Story 10.1 — Rollout playbook
- **Goal:** Write the playbook a new team uses to onboard onto the system.
- **Done when:** A short doc covers: setup, prompt grammar, finding triage process, escalation, and a starter checklist for the first session.

### Story 10.2 — Cross-team onboarding
- **Goal:** Onboard two or three additional teams.
- **Done when:** Each onboarded team has run at least one full session and contributed feedback to the playbook.

### Story 10.3 — Continuous benchmarking
- **Goal:** Keep measuring whether the system is delivering.
- **Done when:** A simple dashboard tracks, monthly:
  - Sessions run
  - Findings found vs. defects escaped to production
  - Time-to-triage trend
  - Scripted-test maintenance hours saved (estimated)
  - False-positive rate trend
- **Notes:** If the metrics regress, the system is on probation. Honest benchmarking is what keeps the project credible.

---

## Sequencing notes

- **Phases 1 through 5** form the minimum viable system — one Lens, one agent, with safety and reporting. This is the smallest unit that can run a useful session end to end.
- **Phase 6** is parallelizable. Once the contract from Phase 3 is stable, the three additional Lenses can be built independently and in parallel.
- **Phase 7** is parallelizable too — adapters are thin and independent.
- **Phases 8 through 10** are sequential and gated by results. We don't roll out to more teams until the pilot shows the system delivers.

## Out of scope for v1

These appeared in scoping conversations but are explicitly deferred:

- **Load testing at scale** — a different tool, a different concern.
- **Multi-user race conditions and concurrent-user testing** — possible but adds session-state complexity we don't need yet.
- **Mobile-native (iOS / Android) apps** — web-only for v1; mobile is a natural v2.
- **Self-driving across multiple products** — one product surface per session keeps scope honest.

---

## Open decisions to make before kickoff

1. **Which AI tool is the first agent integration in Phase 4?** Pick whichever the team uses most today.
2. **Which product surface is the pilot in Phase 8?** Strong candidates are surfaces with both rich existing automation and recent escaped defects.
3. **What's the explicit success bar for the pilot?** A number, not a vibe — e.g., "find at least N defects in 6 weeks that scripted tests would have missed."
4. **Who owns ongoing triage?** PR authors? A QA rotation? A new role?
5. **What's the timeline budget?** Phases 1–5 are roughly a sprint of focused work each, depending on team size. Phases 6 and 7 parallelize. Pilot is 4–6 weeks. Rollout depends on adoption.
