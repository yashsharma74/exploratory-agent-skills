# Autonomous AI Exploratory Testing — Stories and Sub-tasks

**Companion to:** `implementation-plan.md`
**Audience:** Build team and engineering managers — for estimation and sprint planning
**Status:** Draft backlog — refine sizes and dependencies with the team

---

## How to read this document

The work is grouped into **10 top-level stories** (one per phase from the implementation plan). Each story is broken into **sub-tasks** sized **S** (a day or less) or **M** (a few days to a week).

**Top-level story format**
- **Size:** XL (always — these are epic-scale).
- **Goal:** what this story delivers.
- **Done when:** what "complete" looks like for the whole story.
- **Sub-tasks:** the granular work units.

**Sub-task format**

> **{ID} ({size})** — Short title. One-sentence description. *Acceptance:* what done looks like. *Depends on:* sub-task IDs or `—`.

Sub-task IDs are scoped to their parent story (e.g., `1.3` is sub-task 3 of Story 1). Cross-story dependencies use the full path (`S2.04`).

---

## Story 1 — Foundations
**Size:** XL
**Goal:** Stand up the skeleton — folders, contracts, and the universal rules every later piece will obey.
**Done when:** A new contributor can read the entry-point doc and understand how the three pieces compose; the Rulebook covers every rule that doesn't depend on a specific Lens.

**Sub-tasks**

- **1.1 (S)** — Repository scaffolding. Create top-level folders for the Driver, Rulebook, and a placeholder Lens; add `.gitignore`; initialize README. *Acceptance:* folder structure exists; README links to entry-point doc and modules. *Depends on:* —
- **1.2 (S)** — Universal finding ID format. Document 3-digit sequential format, no per-Lens prefix. *Acceptance:* format + rationale + worked example committed. *Depends on:* 1.1
- **1.3 (S)** — Severity scale. Define Critical / High / Medium / Low / Info with one-paragraph definitions and example failure modes. *Acceptance:* fits one screen; example per level. *Depends on:* 1.1
- **1.4 (S)** — Time-budget tiers. Define the 5 / 10 / 15 (default) / 20 / 25–30 minute tiers and what scales with each. *Acceptance:* tiers documented; default marked. *Depends on:* 1.1
- **1.5 (S)** — Coverage logging shorthand. Single-line, grep-friendly format that records tested + not-tested dimensions with reasons. *Acceptance:* format + worked examples. *Depends on:* 1.1
- **1.6 (S)** — Missed-coverage reporting at session end. Define the required "Missed coverage" section on every session summary. *Acceptance:* documented; reasons required. *Depends on:* 1.5
- **1.7 (S)** — Reproducibility requirements for findings. Mandatory fields: steps, environment, evidence pointer, severity, type. *Acceptance:* documented; Lens-specific additions can be layered on. *Depends on:* 1.2
- **1.8 (M)** — Agent-neutral entry-point document. The single document an AI agent reads to compose the system. *Acceptance:* composition rule explicit; 4-phase shape documented; safety summarized; Lens-picking rule included. *Depends on:* 1.1–1.7

---

## Story 2 — The Driver (browser orchestration)
**Size:** XL
**Goal:** Build the part that actually uses the product — opens a browser, navigates, captures evidence, writes everything down in real time.
**Done when:** Any agent can call a small set of atomic scripts to drive a real browser through a session and produce a complete on-disk record.

**Sub-tasks**

- **2.1 (S)** — Pick the browser automation tool. Choose a CLI-driven option and document why. *Acceptance:* ADR-style note + install instructions. *Depends on:* —
- **2.2 (S)** — Environment check script. Verify the browser tool is installed; print the install command on failure. *Acceptance:* runs first in every session. *Depends on:* 2.1
- **2.3 (M)** — Production guardrail script. Three exit codes (proceed / block / ask); configurable production-host detection; explicit override with logged justification. *Acceptance:* a production URL is blocked unless override is set. *Depends on:* —
- **2.4 (S)** — Session folder naming and structure. Format: timestamp-Lens-feature; sub-folders for findings/evidence/snapshots; metadata file template. *Acceptance:* template committed. *Depends on:* S1.08
- **2.5 (S)** — Audit log format. Line-based, append-only, with timestamp + category + message. *Acceptance:* categories enumerated; sample line per category. *Depends on:* 2.4
- **2.6 (M)** — Session init script. Creates the session folder, seeds metadata, opens an empty audit log, returns the path. *Acceptance:* supports output-dir override via env var. *Depends on:* 2.4, 2.5
- **2.7 (S)** — Audit log append script. The only path the agent uses to write to the log. *Acceptance:* normalized format; refuses if the session folder is missing. *Depends on:* 2.6
- **2.8 (M)** — Navigate-with-guardrail script. Wraps every browser nav so it goes through the production check, emits a NAV entry, and auto-captures a snapshot. *Acceptance:* refusing prod is logged; success leaves a snapshot + log entry. *Depends on:* 2.3, 2.7
- **2.9 (S)** — Screenshot script with paired audit entry. One call = one screenshot + one EVIDENCE log entry. *Acceptance:* caps at 5 per session. *Depends on:* 2.7
- **2.10 (M)** — Pass-check and fail-check scripts. Pass logs the check; fail logs the check **and** writes a finding atomically. *Acceptance:* failed check cannot leave log and findings out of sync. *Depends on:* 2.7, 2.11, 2.12
- **2.11 (S)** — Sequential finding ID counter. Atomic read-and-increment within the session folder. *Acceptance:* first finding gets `001`. *Depends on:* 2.4
- **2.12 (M)** — Finding file template + writer script. Required fields (ID, title, severity, type, steps, evidence, env); updates severity counter in same call. *Acceptance:* rejects findings missing required fields. *Depends on:* S1.07, 2.11
- **2.13 (S)** — DOM snapshot capture. Saved under `snapshots/`; unbounded on disk; never dumped to chat. *Acceptance:* each snapshot has a stable filename. *Depends on:* 2.4
- **2.14 (S)** — Element reference helper. Given a snapshot and a hint, returns a stable selector. *Acceptance:* surfaces all candidates when ambiguous. *Depends on:* 2.13
- **2.15 (S)** — Metadata field updater. Edits a single labeled row in the session metadata file. *Acceptance:* fails clearly when the field doesn't exist. *Depends on:* 2.4
- **2.16 (S)** — Silent defaults for setup. Document defaults for environment, time, evidence level, viewport, headless, credentials. *Acceptance:* agent only asks for the undefaultable. *Depends on:* S1.08
- **2.17 (S)** — Viewport reference. Three named viewports (desktop, tablet, mobile) with dimensions. *Acceptance:* desktop is default. *Depends on:* 2.16
- **2.18 (S)** — Credentials handling reference. One section per auth method (none, form, SSO, basic, API key, MFA). *Acceptance:* source + redaction expectation per method. *Depends on:* 2.16

---

## Story 3 — First Lens (Functional)
**Size:** XL
**Goal:** Prove the architecture works end-to-end with one testing domain — user flows and business logic.
**Done when:** A canonical functional session against a public site lives in the repo and is reproducible.

**Sub-tasks**

- **3.1 (M)** — Lens contract / SKILL.md schema. Frontmatter, required sections, required and optional references. *Acceptance:* schema committed. *Depends on:* S1.08
- **3.2 (S)** — Mission statement format + anti-patterns. `Test [area] using [approach] to find [risk]`; table of 3+ anti-patterns with fixes. *Acceptance:* mission is logged before any browser action. *Depends on:* 3.1
- **3.3 (M)** — Scenario mapping and classification. Each scenario records flow, screen, entry point, strategy, oracle. *Acceptance:* live refinement allowed; changes logged with reason. *Depends on:* 3.2
- **3.4 (M)** — Profile tags catalogue. Five tags (create/update/delete, multi-state, submit action, has inputs, displays list); each carries mandatory probes. *Acceptance:* a scenario can carry multiple tags; quick-reference table committed. *Depends on:* 3.3
- **3.5 (S)** — Coverage heuristic for functional flows. Six dimensions (sequence / primary function / data / platform / operations / time). *Acceptance:* glossary + coverage shorthand. *Depends on:* S1.05, 3.1
- **3.6 (S)** — Oracles library. Named sources of truth (user goal, documented behavior, prior version, similar feature, common sense). *Acceptance:* agent names the oracle in the audit log before recording any pass/fail. *Depends on:* 3.1
- **3.7 (S)** — Functional finding type field. Allowed values: Validation / Navigation / State / Logic / UI-Feedback. *Acceptance:* writer rejects findings without a valid type. *Depends on:* S2.12
- **3.8 (S)** — Functional time-budget scaling table. Scenarios + probe depth per tier; mandatory probes never skipped under time pressure. *Acceptance:* covers all five tiers. *Depends on:* 1.4, 3.4
- **3.9 (S)** — Functional strictness principles. Non-negotiables: mandatory probes, mission required, oracle named, scope changes logged, coverage logged. *Acceptance:* documented. *Depends on:* 3.2–3.8
- **3.10 (M)** — Tester perspectives catalogue. 8–12 perspectives (naïve, power, anonymous, cross-user, hostile, distracted, mobile, accessibility, slow-network, returning, expert); 2–3 per scenario rule; default-selection table. *Acceptance:* one profile per perspective + selection table. *Depends on:* 3.1
- **3.11 (S)** — Checkpoint cadence and coverage logging. 5-minute checkpoints; each emits coverage shorthand + profile-gate status. *Acceptance:* documented. *Depends on:* 1.5, 3.5
- **3.12 (S)** — Pick a target for the canonical example. Stable public web app, documented rationale. *Acceptance:* target + auth method committed. *Depends on:* 3.9, 3.10
- **3.13 (M)** — Run and capture the canonical functional session. Real session against the chosen target, committed under `EXAMPLE-*`. *Acceptance:* reproducible end-to-end; linked from README. *Depends on:* 3.12, full Story 2

---

## Story 4 — First agent integration and safety
**Size:** XL
**Goal:** Make the system actually run autonomously in one AI tool, with the safety guardrails in place.
**Done when:** A 15-minute session runs end to end with zero approval prompts and zero credential leakage.

**Sub-tasks**

- **4.1 (S)** — Pick the first AI tool. Choose + document rationale. *Acceptance:* setup instructions captured. *Depends on:* —
- **4.2 (S)** — First-agent shim file. Short adapter pointing to the universal entry-point doc; no duplicated content. *Acceptance:* picked up automatically on session start. *Depends on:* S1.08, 4.1
- **4.3 (M)** — Permission allow-list for the first agent. Cover browser tool, Driver scripts, common reads, writes confined to session folder; personal-override file gitignored. *Acceptance:* documented in autonomy doc. *Depends on:* 4.2, full Story 2
- **4.4 (S)** — Permission deny-list. Wildcard recursive delete, outbound HTTP outside the browser tool, git push, git reset --hard. *Acceptance:* each denial is logged when triggered. *Depends on:* 4.3
- **4.5 (S)** — Zero-prompt verification run. Run a full session and add any missing patterns. *Acceptance:* a 15-min session completes prompt-free. *Depends on:* 4.3, 4.4
- **4.6 (M)** — Prompt grammar — target URL and auth methods. One section per auth method (none / form / SSO / basic / API key / bearer / MFA) with examples. *Acceptance:* worked examples per method. *Depends on:* S2.18
- **4.7 (S)** — Prompt grammar — Lens selection and continuation. Cover all four Lenses + "no focus → ask"; resume the last session or one by ID. *Acceptance:* examples committed. *Depends on:* 4.6
- **4.8 (M)** — Credential redaction in outputs. Audit log, findings, snapshots, reports — credentials must never appear. *Acceptance:* a test session with credentials shows zero leakage. *Depends on:* S2.07, S2.12
- **4.9 (S)** — Autonomy reference document. Operator-facing doc explaining pre-approval and the safety boundary. *Acceptance:* one short section per supported agent. *Depends on:* 4.3, 4.4

---

## Story 5 — Reporting and validation
**Size:** XL
**Goal:** Turn the raw session folder into something a human can read in 30 seconds, with compliance checks catching drift.
**Done when:** Every closed session produces a one-page report and passes a compliance check.

**Sub-tasks**

- **5.1 (M)** — End-of-session script. Recomputes severity counters from the audit log, sets status to "completed," emits a one-line summary. *Acceptance:* idempotent; counters match the audit log exactly. *Depends on:* S2.06, S2.10
- **5.2 (M)** — Compliance validation rules. Rules cover: every fail-check has a finding file, every finding has required fields, coverage logged at checkpoints, mission recorded. *Acceptance:* committed to a single reference doc. *Depends on:* 1.6, S3.09
- **5.3 (M)** — Compliance validation script. Walks a closed session and reports violations. *Acceptance:* exit 0 = clean; exit 1 with structured output on violations; runnable against historical sessions. *Depends on:* 5.2
- **5.4 (S)** — Human-readable report template. Sections: summary, findings by severity, coverage log, missed coverage, evidence index. *Acceptance:* fits under 2 screens for a typical session. *Depends on:* 5.1
- **5.5 (M)** — Report generation script. Generates `report.md` from raw artifacts only. *Acceptance:* idempotent; output linked from the session folder. *Depends on:* 5.4
- **5.6 (S)** — Chat summary script. Compact block (<25 lines) for posting back into the agent. *Acceptance:* names top findings, severity counts, link to the folder. *Depends on:* 5.5

---

## Story 6 — Expand the Lenses (security / accessibility / performance)
**Size:** XL
**Goal:** Prove the architecture supports multiple domains without changing the Driver or the Rulebook. Three Lenses can be built in parallel by separate teams once the contract is stable.
**Done when:** All four Lenses exist, each with its own methodology, finding schema, time-budget scaling, and strictness principles.

**Sub-tasks — Security Lens**

- **6.1 (S)** — Security: attack categories. List supported categories (injection, AuthN, AuthZ, CSRF, data exposure, misconfiguration); one-category-per-session rule with the 25–30 min exception. *Acceptance:* categories documented. *Depends on:* S3.01
- **6.2 (S)** — Security: attack-surface mapping step. Mandatory before any probes — list inputs, auth boundaries, sensitive endpoints. *Acceptance:* invasive probes require operator-confirmed scope. *Depends on:* 6.1
- **6.3 (M)** — Security: heuristics references. Document the probe heuristics (input/output flow, endpoint-style, threat lens, impact lens). *Acceptance:* coverage glossary + shorthand for security sessions. *Depends on:* 6.2
- **6.4 (S)** — Security: industry-standard reference mapping. Every finding maps to an industry catalogue ID. *Acceptance:* writer requires a reference field. *Depends on:* S2.12, 6.1
- **6.5 (M)** — Security: required additional finding fields. Payload, context, exploit path, impact, reference ID; impact statement required for High/Critical. *Acceptance:* writer rejects findings missing these. *Depends on:* 6.4
- **6.6 (S)** — Security: time-budget scaling + strictness. Table for all five tiers; strictness principles documented. *Acceptance:* documented. *Depends on:* 6.5

**Sub-tasks — Accessibility Lens**

- **6.7 (S)** — Accessibility: page selection rule. One page per session; prioritize login, forms, primary CTAs, dialogs. *Acceptance:* documented as first workflow step. *Depends on:* S3.01
- **6.8 (M)** — Accessibility: automated sweep step. Specific tool chosen; output summarized to audit log; can't be skipped. *Acceptance:* sweep runs before any manual checks. *Depends on:* 6.7
- **6.9 (S)** — Accessibility: ordered manual checks. Keyboard → focus → forms → semantic structure; persist after each. *Acceptance:* order is enforced. *Depends on:* 6.8
- **6.10 (S)** — Accessibility: heuristics references. Document the dimensions (perceivable / operable / understandable / robust + keyboard supplementaries). *Acceptance:* glossary + shorthand for a11y sessions. *Depends on:* 6.9
- **6.11 (S)** — Accessibility: WCAG mapping requirement. Every finding maps to a WCAG criterion; default baseline 2.2 AA. *Acceptance:* writer requires criterion field. *Depends on:* S2.12
- **6.12 (S)** — Accessibility: User Impact classification. Blocked task / Severe friction / Minor friction — orthogonal to severity. *Acceptance:* both severity and User Impact on every finding. *Depends on:* 6.11
- **6.13 (S)** — Accessibility: finding types, scaling, strictness. Type enum, time-budget scaling, strictness principles. *Acceptance:* documented. *Depends on:* 6.10–6.12

**Sub-tasks — Performance Lens**

- **6.14 (M)** — Performance: baseline capture step. Page load + key-interaction timing; persists as the session reference. *Acceptance:* baseline required before any probes. *Depends on:* S3.01
- **6.15 (S)** — Performance: filtered diagnostics. Console errors, failed/slow requests, top heavy resources; no raw HAR. *Acceptance:* raw dumps explicitly disallowed. *Depends on:* 6.14
- **6.16 (S)** — Performance: per-interaction flow. Trigger → observe → persist; one interaction at a time. *Acceptance:* persistence enforced between interactions. *Depends on:* 6.15
- **6.17 (S)** — Performance: heuristics references. Response / animation / idle / load + consistency lens. *Acceptance:* glossary + shorthand for perf sessions. *Depends on:* 6.16
- **6.18 (S)** — Performance: required additional finding fields. Component or endpoint, observed-vs-threshold timing, user-impact statement. *Acceptance:* "the page is slow" is rejected. *Depends on:* S2.12
- **6.19 (S)** — Performance: finding types, scaling, strictness. Type enum, time-budget scaling, strictness principles. *Acceptance:* documented. *Depends on:* 6.17, 6.18

**Sub-tasks — Cross-Lens**

- **6.20 (S)** — Update entry-point Lens picker. Intent-to-Lens table covers all four Lenses; "unclear / multi-domain" guidance preserved. *Acceptance:* updated and reviewed. *Depends on:* 6.6, 6.13, 6.19

---

## Story 7 — Cross-agent compatibility
**Size:** XL
**Goal:** Free each team to use whichever AI tool they prefer.
**Done when:** Three commonly-used AI tools have verified adapters; a fourth tool runs the system from the universal entry point alone.

**Sub-tasks**

- **7.1 (S)** — Pick the second AI tool. Choose + rationale. *Acceptance:* choice committed. *Depends on:* S4.05
- **7.2 (M)** — Second-agent adapter. Shim + any tool-specific config; verify with a session. *Acceptance:* zero-prompt session completes. *Depends on:* 7.1
- **7.3 (M)** — Third AI tool integration. Repeat the pattern. *Acceptance:* third adapter exists, verified. *Depends on:* 7.2
- **7.4 (S)** — Long-tail tool verification. Run a session in a tool without a dedicated adapter. *Acceptance:* session completes; rough edges filed as issues. *Depends on:* S1.08
- **7.5 (S)** — Verification matrix doc. Short matrix: tool, version, config required, last verified. *Acceptance:* committed to a stable path. *Depends on:* 7.2, 7.3, 7.4

---

## Story 8 — Pilot
**Size:** XL
**Goal:** Validate that the system finds defects we care about on a real product surface.
**Done when:** A pilot comparison report is in front of stakeholders with a clear go / no-go recommendation.

**Sub-tasks**

- **8.1 (S)** — Identify candidate pilot surfaces. Shortlist 3–5 with one-paragraph summaries (traffic, coverage, recent defects). *Acceptance:* shortlist committed. *Depends on:* —
- **8.2 (M)** — Choose surface + define success. Numerical success metrics + failure-to-graduate criterion. *Acceptance:* surface + metrics committed. *Depends on:* 8.1
- **8.3 (S)** — Baseline scripted-test coverage. Coverage snapshot + known gaps. *Acceptance:* committed. *Depends on:* 8.2
- **8.4 (S)** — Baseline manual exploratory history. Last 6 months of findings, summarized. *Acceptance:* recurring failure modes highlighted. *Depends on:* 8.2
- **8.5 (S)** — Baseline escaped defects. Defects that reached production in the last 6 months, categorized. *Acceptance:* committed. *Depends on:* 8.2
- **8.6 (S)** — Pilot run schedule and cadence. Decide trigger + frequency + owner. *Acceptance:* schedule + owner committed. *Depends on:* 8.2
- **8.7 (M, sustained)** — Run the pilot. 4–6 calendar weeks. Findings triaged within SLA; weekly status posted. *Acceptance:* sessions complete on schedule; triage SLA honored. *Depends on:* 8.6
- **8.8 (M)** — Pilot comparison report. Defects caught vs. scripted/manual; false positives; triage effort; go / no-go. *Acceptance:* report reviewed by stakeholders. *Depends on:* 8.7

---

## Story 9 — Release pipeline integration
**Size:** XL
**Goal:** Move from manually-triggered sessions to sessions that run on every staging build, with results landing on the originating PR or ticket.
**Done when:** Every staging deploy produces a session, posts a summary back to the PR/ticket, and routes findings to the right people.

**Sub-tasks**

- **9.1 (S)** — Pick the CI platform. Choose + rationale. *Acceptance:* committed. *Depends on:* S8.08
- **9.2 (M)** — CI workflow file. Triggered by staging deploy; respects production guardrail; persists session as artifact. *Acceptance:* runs on a non-critical staging branch first. *Depends on:* 9.1
- **9.3 (S)** — Secrets management for CI. Credentials via the CI platform's secrets store. *Acceptance:* redaction verified in CI logs. *Depends on:* 9.2
- **9.4 (S)** — Artifact storage. Sessions retained for the agreed period; stable URLs. *Acceptance:* retention policy committed. *Depends on:* 9.2
- **9.5 (M)** — Post results to PR or ticket. Comment with finding counts by severity + link to artifact; format stable across runs. *Acceptance:* PR / ticket integration verified. *Depends on:* 9.4
- **9.6 (M)** — Severity-based triage routing. Critical → page on-call; High → notify PR author + QA channel; Medium / Low / Info → review queue. *Acceptance:* routing rules implemented. *Depends on:* 9.5
- **9.7 (S)** — Triage SLA and escalation. SLA per severity + escalation path documented and agreed. *Acceptance:* doc committed. *Depends on:* 9.6

---

## Story 10 — Rollout and continuous benchmarking
**Size:** XL
**Goal:** Scale to additional teams and keep proving value with measurable KPIs.
**Done when:** Two to three additional teams are onboarded; a benchmark dashboard updates monthly; a recurring review is in place.

**Sub-tasks**

- **10.1 (S)** — Onboarding checklist. Install / setup / first-session guide / common pitfalls. *Acceptance:* committed. *Depends on:* S8.08
- **10.2 (S)** — Team-facing prompt-grammar examples. Worked examples for the team's top 5 surfaces + relevant auth methods. *Acceptance:* per-team examples committed. *Depends on:* 10.1
- **10.3 (S)** — Triage process docs. Rubric per severity + true-positive / false-positive / known-issue examples. *Acceptance:* committed. *Depends on:* S9.07
- **10.4 (M, sustained)** — First additional team onboarding. Run unaided session; feedback at week 1 and week 4; playbook updated. *Acceptance:* team produces sessions independently. *Depends on:* 10.3
- **10.5 (M, sustained)** — Second / third team onboarding. Repeat for two more teams. *Acceptance:* each team has produced sessions; cross-team gotchas added to playbook. *Depends on:* 10.4
- **10.6 (S)** — Benchmark KPIs. Sessions run, defects found vs. escaped, time-to-triage, maintenance hours saved, false-positive rate. *Acceptance:* KPI list with definitions and data sources. *Depends on:* S8.08
- **10.7 (M)** — Benchmark data pipeline. Sessions + triage outcomes feed the KPI source; monthly snapshot generated. *Acceptance:* KPI snapshot updates automatically. *Depends on:* 10.6
- **10.8 (M)** — Benchmark dashboard. KPI trends month-over-month; anomalies highlighted; shared with stakeholders. *Acceptance:* dashboard live. *Depends on:* 10.7
- **10.9 (S)** — Monthly review cadence. Standing meeting + agenda template + first two months held. *Acceptance:* minutes captured. *Depends on:* 10.8

---

## Summary

| Story | Sub-tasks | Approx. effort | Parallelizable? |
|---|---|---|---|
| 1 — Foundations | 8 | 1 sprint | sub-tasks largely sequential |
| 2 — The Driver | 18 | 2 sprints | several sub-tasks in parallel |
| 3 — First Lens (Functional) | 13 | 1–2 sprints | depends on Story 2 |
| 4 — First agent + safety | 9 | 1 sprint | partly parallel with Story 5 |
| 5 — Reporting & validation | 6 | < 1 sprint | partly parallel with Story 4 |
| 6 — Expand Lenses | 20 | 2–3 sprints | **three Lenses fully parallel** |
| 7 — Cross-agent compatibility | 5 | < 1 sprint | **adapters fully parallel** |
| 8 — Pilot | 8 | 4–6 calendar weeks | mostly sequential |
| 9 — CI integration | 7 | 1 sprint | mostly sequential |
| 10 — Rollout + benchmark | 9 | sustained quarter | partly parallel |
| **Total** | **~103 sub-tasks** | **~6–8 months wall time** | depends on parallelism |

---

## Notes for the build team

- **Sizes are starting points.** Refine in backlog grooming. S and M reflect rough complexity, not a sprint commitment.
- **Acceptance criteria are the contract.** If "done when" reads vague, refine before pulling the sub-task.
- **Mixed work types.** Some sub-tasks are pure docs, others are code. The mix is intentional — discipline lives in docs, mechanics in code.
- **Dependencies are conservative.** Some are logical rather than strict; flag where a dependency could be relaxed to unlock parallel work.
- **Biggest parallel wins:**
  - Story 6 — three Lenses can be built by three teams simultaneously once Story 3 lands.
  - Story 7 — adapters are independent of each other.
  - Stories 4 and 5 — can overlap once Story 2 is solid.
