# Oracles — Correctness Judgment Sources

Before deciding whether any observed behavior is a defect or acceptable, identify which source of truth applies and state it explicitly. "This looks wrong" is not a sufficient basis for a finding. "This contradicts what the submit button label says" is.

---

## Sources of Truth

These are the bases on which observed behavior can be judged correct or incorrect. Use the hierarchy in the next section when more than one applies.

| Source | The question to ask | When it applies | Failure signal |
|---|---|---|---|
| **Documentation and label consistency** | Does observed behavior match UI labels, button text, error messages, tooltips, or docs? | Always, when any text describes the feature's behavior | Mismatch between written description and actual behavior |
| **Regression from prior version** | Did this work correctly before and now produce a different result? | After any code change, refactor, or deployment | Behavior changed without intentional reason |
| **Internal consistency** | Is the same rule applied uniformly everywhere it should apply? | Same input/action/rule exists in multiple parts of the app | Different outcomes for identical inputs in different areas |
| **Feature goal fulfillment** | Does the feature achieve its purpose, even if it runs without errors? | Feature works mechanically but doesn't serve the user's task | Completes without errors but doesn't fulfill its purpose |
| **Compliance and standards requirement** | Does behavior comply with regulations, a11y standards, security requirements, or API contracts? | Legal, regulatory, contractual, or standards obligation applies | Creates legal, contractual, or security exposure |
| **User mental model alignment** | Would a reasonable first-time user expect this behavior? | No documentation exists, or behavior would surprise a reasonable user | User would be confused, misled, or make an error |
| **Industry and web conventions** | Does behavior comply with widely accepted web application norms? | Behavior violates a well-established convention users rely on | Any experienced web user would recognize this as incorrect |
| **Brand and quality presentation** | Would the organization want users to see this output? | Technically accurate but embarrassing or trust-eroding | A stakeholder would be embarrassed seeing this |
| **Competitive product comparison** | Does behavior compare unfavorably to leading products in the same category? | No other source applies but clear industry-standard behavior exists | Measurable user friction not present in competitors |
| **Known defect pattern match** | Does behavior match a known class of software defect? | Failure pattern is recognizable (race condition, off-by-one, null pointer, auth bypass) | Pattern recognizable without a specific spec to contradict |
| **Unexplained behavior** | Can anyone explain why this behavior exists? | Behavior appears intentional but no rationale can be found | No spec, design decision, or business rule explains it |

---

## Hierarchy

When more than one source of truth applies to the same observation, use the most specific one.

```
Compliance and standards requirement  ← most specific (legal/contractual obligation)
Documentation and label consistency   ← written description contradicts behavior
Regression from prior version         ← behavior changed without intent
Internal consistency                  ← same rule applied differently in same product
Feature goal fulfillment              ← works mechanically but serves no purpose
User mental model alignment           ← surprising but not otherwise categorized
Industry and web conventions          ← violates broadly accepted norms
Brand and quality presentation        ← correct but damaging to trust
Competitive product comparison        ← no defect by other sources, but unfavorable gap
Known defect pattern match            ← recognizable failure class
Unexplained behavior                  ← suspect with no other applicable source
```

Example: an error message displays the wrong field name. Both "Documentation and label consistency" (the UI text is wrong) and "User mental model alignment" (the user will be confused) apply. Use "Documentation and label consistency" — it is more specific because documentation exists and the text contradicts it.

---

## How to Record a Source of Truth

In the audit log, state the source explicitly before recording the result:

```
[Source: Documentation and label consistency] — "Save draft" button publishes immediately; label does not reflect behavior
[Source: Regression from prior version] — flow returned correct results last sprint; now returns 500
```

When no source clearly fits but the behavior still seems wrong:

```
[Source: User mental model alignment — uncertain] — behavior is surprising for the following reason: [describe]
```

Do not skip this step. An uncertain source logged with a reason is more useful than a finding with no basis for judgment.

---

## Quick Lookup by What You Observed

| What you observed | Source to apply |
|---|---|
| UI label, button text, error message, or tooltip says one thing; behavior does another | Documentation and label consistency |
| This worked correctly in the previous version or last sprint | Regression from prior version |
| The same rule behaves differently in two parts of the same product | Internal consistency |
| The feature runs without errors but does not accomplish what it is meant to do | Feature goal fulfillment |
| The behavior may violate a regulation, accessibility requirement, or security standard | Compliance and standards requirement |
| A first-time user would be confused or would make an error due to this behavior | User mental model alignment |
| The behavior contradicts how all mainstream web applications handle this situation | Industry and web conventions |
| The output is correct but would embarrass the organization | Brand and quality presentation |
| No defect by any other source, but leading competitors handle this better | Competitive product comparison |
| The failure pattern matches a known bug class seen before | Known defect pattern match |
| No one can explain why the behavior exists | Unexplained behavior |
