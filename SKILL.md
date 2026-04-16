---
name: compliance-auditor
description: Use this skill whenever the user asks for a privacy policy, terms of service, cookie policy, accessibility statement, GDPR / CCPA / COPPA / Israel PPL / UK GDPR review, sub-processor list, or any "make my site compliant" task. Also trigger when the user mentions Privacy Policy, Terms, ToS, ToU, "legal pages", compliance audit, data processing agreement, DPA, DPIA, consent flow, cookie banner, CAN-SPAM footer, data retention, breach-notification, or regulator names (EDPB, ICO, CPPA, FTC, Israeli PPA). The skill runs a deterministic multi-agent pipeline - researches primary-source regulator requirements, audits the user's actual codebase for real data flows, reverse-engineers peer SaaS policies, drafts new legal docs into the codebase, and runs three parallel reviewers (code-vs-claims, legal-accuracy, prose-consistency) before shipping. Use this even when the user says "help me with my privacy policy" casually - the skill is the right tool because template generators miss actual data flows and miscite law.
---

# Compliance Auditor

## Disclaimer - read this first and surface it to the user EVERY TIME

```
WARNING - NOT LEGAL ADVICE

This skill produces drafts and research artifacts to help engineers
reason about privacy, terms of service, and compliance. It is not a
substitute for a licensed attorney in the user's jurisdiction.

The user MUST have a qualified lawyer review the output before the
docs are relied on in production, especially for any of:
- Paid product / monetization
- EU, UK, or California users at scale
- Health, financial, biometric, or children's data
- Enterprise B2B contracts
- Any live incident or regulator contact

Primary-source citations in the output are aids for the attorney's
review, not a substitute for it. Regulatory interpretation requires
professional judgement.
```

The final legal docs the user ships MUST include a disclaimer line in their "Who we are" or "About this policy" section that notes professional review was performed (or not) - the drafter agent is instructed to ASK the user about this before writing.

## What this skill does

The skill turns a vague "make my legal pages compliant" request into a rigorous multi-agent pipeline that produces accurate Privacy Policy, Terms of Service, and related compliance artifacts that:

1. Reflect the user's ACTUAL data flows (discovered by reading the user's codebase, not assumed from a template)
2. Cover the jurisdictions that ACTUALLY apply to their user base (EU GDPR, UK GDPR, CCPA/CPRA, COPPA, Israel PPL, etc.)
3. Mirror clause structures from best-in-class SaaS peers (Notion, Linear, Stripe, Vercel, Readwise, Raycast, Supabase) that already survive regulator scrutiny
4. Cite primary-source regulators (EDPB, ICO, CPPA, FTC, PPA, Google Limited Use policy) rather than blog paraphrases
5. Are internally consistent, prose-clean, and TypeScript-clean when rendered into the user's web app
6. Commit an audit trail to the repo so the next maintainer (human or AI) can diff against the reasoning

The skill also produces a follow-up punch list of code / UI changes the user should make to match what the docs now promise - consent flow positioning, email footer contents, data-export endpoint, cookie banner, opt-out handling, RLS checks, and so on. Producing the docs without the matching code changes creates liability drift; the skill is explicit about both.

## When to use - stronger triggers

Trigger this skill BEFORE responding when any of these appear in the user's message:

- "privacy policy", "terms", "ToS", "ToU", "privacy page", "legal pages", "compliance"
- "GDPR", "CCPA", "CPRA", "COPPA", "UK GDPR", "Israel PPL", "ePrivacy", "CAN-SPAM"
- "data processing agreement", "DPA", "DPIA", "sub-processor", "controller", "processor"
- "cookie banner", "cookie policy", "consent flow", "consent banner"
- "data retention", "breach notification", "right to erasure", "right to access", "portability"
- "EU representative", "Article 27", "DPO", "data protection officer"
- "Google Limited Use", "OAuth data policy", "Limited Use disclosure"
- "accessibility", "a11y compliance", "WCAG", "ADA compliance"
- Regulator names - EDPB, ICO, CNIL, DPC, CPPA, FTC, PPA, Garante

Skill should NOT trigger for: one-off document reads ("what does section 4 of Stripe's ToS say?"), legal-research questions ("what does Art. 6 GDPR require?") where the user is not working on their own docs, or pure factual lookups.

## The Pipeline - Ten Phases

This skill runs as a deterministic orchestration. Do not skip phases. Do not shortcut. Run each phase in full before starting the next, with one exception: Phase 2 (research) and Phase 3 (code audit) and Phase 4 (peer benchmark) are mutually independent and MUST run in parallel for efficiency.

### Phase 0 - Intake and scope

Ask the user, before writing any code or spawning agents, these FIVE questions (combine them into a single message):

1. **Project identity.** What is the product, what is the domain, where is the codebase, what tech stack is the legal surface (Next.js pages? a Jekyll site? a PDF? backend-only?).
2. **Jurisdictions in scope.** Where are they based, and where are their users? (US only? EU? UK? California? Israel? Global?) If unsure, default to: "business based in [country from git config or user], users possibly global" - and research the matching framework.
3. **What exists today.** Do they already have /privacy and /terms pages, or are we writing from scratch? Provide paths if any.
4. **Real gaps vs. aspirational.** What user-facing features exist but might be missing from the legal docs? What are they about to ship that will add new data flows? Prompt them to mention AI, payments, social bots, Chrome extensions, mobile apps, email marketing, analytics, etc.
5. **Attorney review status.** Do they already have a lawyer on retainer, or are they pre-attorney (most vibe coders)? The disclaimer text shipped in the final docs depends on this.

Save these answers to `.compliance-auditor/intake.md` in the user's repo. This file is the anchor for every downstream agent.

### Phase 1 - Memory and prior-art lookup

Check whether the user already has project memory files (`memory/MEMORY.md`, `CLAUDE.md`, `.claude/memory/`) that the skill should load. Look specifically for:

- Existing email addresses (DO NOT invent new mailboxes - the skill must use real ones)
- Existing known sub-processors
- Existing legal-docs-update rule (if this skill has run before)
- Deployment region / controller location hints

If `legal-docs-update-rule.md` memory already exists from a prior run, load it and use as the baseline. If not, the skill will CREATE this memory at the end (see Phase 9).

### Phase 2 - Primary-source legal research (agent A, parallel)

Dispatch a `researcher` subagent (Claude Code) or equivalent. Skills it should load: `parallel-web-search`, and WebFetch for primary-source reading. Instruct it to output `specs/legal/research-<YYYY-MM-DD>.md` with per-jurisdiction requirements + 2+ primary-source URLs per jurisdiction + any 2025/2026-specific changes. See `references/orchestration.md` for the full agent prompt template, and `references/jurisdictions.md` for the list of jurisdictions to research.

### Phase 3 - Code data-practices audit (agent B, parallel with Phase 2)

Dispatch a `code-analyzer` or equivalent subagent to produce a factual inventory of the user's actual code. Use the 12-topic audit template in `references/orchestration.md#phase-3`. The audit MUST cite `file:line` for every claim. When the code does not clearly support a claim, the auditor says so - the drafter then uses honest hedging language rather than inventing behavior.

This step is what distinguishes the skill from every template generator on the market - we do not let the drafter assume behavior, we require evidence.

### Phase 4 - Peer benchmark (agent C, parallel with Phase 2 and 3)

Dispatch a `researcher` subagent to reverse-engineer 5 peer SaaS policies most structurally similar to the user's product. See `references/peer-benchmarking.md` for a selection framework (match by content-shape, user-base region, AI exposure, OAuth posture, small-team pedigree). Output: `specs/legal/benchmark-peers-<YYYY-MM-DD>.md` with clause-level comparison + adopt-worthy-with-attribution + over-promise warnings.

### Phase 5 - Draft (agent D, sequential, after 2+3+4 all complete)

Dispatch a `coder` subagent with the `elements-of-style:writing-clearly-and-concisely` skill loaded. Give it the three Phase-1 reports + the user's intake + the existing policy (if any) as input. Require it to:

- Write ONLY what the code audit supports
- Cite the research file for each jurisdictional claim
- Use peer-benchmark phrasings as inspiration, not copy-paste
- Use real contact emails (from intake / memory, never invented)
- Preserve the user's project style conventions (style rules from CLAUDE.md)
- Output into the user's actual page components (e.g. `app/app/(public)/privacy/page.tsx` for Next.js) AND mirror the canonical markdown copies in `specs/legal/` or equivalent
- Include a "Key changes in this update" block at the top summarizing what the revision corrected
- Leave explicit placeholders for open items (EU/UK Article 27 reps, physical mailing address, Hebrew translation, etc.) rather than inventing facts
- Run `tsc --noEmit` or equivalent type-check at the end and confirm zero errors

See `references/orchestration.md#phase-5` for the full drafter prompt.

### Phase 6 - Parallel three-reviewer quality gate

Dispatch THREE subagents in PARALLEL (same message, multiple tool calls), each with a different lane. None is optional. See `references/orchestration.md#phase-6` for full prompts.

- **Reviewer A - code-vs-claims** (`security-auditor` type, loads `security-review` skill). Verifies every factual claim against real code. Grep sub-processors, retention, cookies, user-rights. Catches hallucinations and missed data flows.

- **Reviewer B - legal accuracy** (`researcher` type, loads `parallel-web-search` skill). Validates each statement of law against primary-source regulators. WebFetches Google Limited Use, CPPA ADMT, the applicable regulator texts. Catches misstatements and outdated citations.

- **Reviewer C - prose + cross-doc consistency** (`reviewer` type, loads `elements-of-style:writing-clearly-and-concisely`). Em-dash sweep, fake-email sweep, plain-English pass, markdown-JSX sync, a11y (table `scope="col"`, alt text), voice consistency.

Each reviewer writes a review file to `specs/legal/review-6<a|b|c>-<YYYY-MM-DD>.md` with a verdict (PASS / PASS WITH FIXES / FAIL) plus a list of fixes with proposed exact replacement text.

### Phase 7 - Handle LIVE-VERIFY items

The legal-accuracy reviewer may flag items it could not verify (often because its sandboxed WebFetch failed). The main Claude session MUST handle these itself - WebFetch the regulator page, confirm exact wording, pass the verified text into the fixer's context.

Common LIVE-VERIFY items:
- Google API Services User Data Policy four Limited Use exceptions (verbatim)
- CPPA ADMT regulations effective date and scope
- Data Privacy Framework (DPF) certification status for specific US recipients
- Regulator addresses / complaint portals

### Phase 8 - Consolidated fixer (agent E, sequential)

Dispatch ONE consolidator subagent with all three review files + the main-session-verified text as input. It applies all critical fixes in the correct order, applies high-value non-critical fixes, and runs these sweeps at the end:

- `tsc --noEmit` or project's equivalent - must pass
- Em dash count across shipped files - must be 0
- Fake email sweep (invented local parts like `privacy@`, `legal@`, `noreply@` that weren't in the real-mailboxes list) - must be 0
- Verbatim appearance of any regulator quotes (Google Limited Use four exceptions, etc.) - must be exact
- Cross-doc consistency (Last Updated date, controller identity, sub-processor list, retention periods match everywhere)

### Phase 9 - Code and UI punch list (the forgotten phase)

This is what makes the skill genuinely useful. Writing accurate docs creates an obligation to ALSO ship the code changes the docs now promise. Before ending, enumerate for the user the code-and-UI tasks they need to do to match the docs. See `references/code-ui-recommendations.md` for a starter checklist that covers:

- Signup-consent placement (sign-in-wrap ABOVE the CTA, not below)
- CAN-SPAM physical address in every marketing email footer
- Cookie banner presence and GPC signal honoring
- Data-export endpoint (if docs say self-service; if not, policy must say "on request")
- Account-deletion cascade completeness (all user-linked rows, not just the users row)
- RLS on user tables (Supabase) or equivalent row-level isolation
- One-click unsubscribe per RFC 8058 on marketing email
- Opt-out handler for each messaging channel (WhatsApp STOP, Telegram /stop or equivalent)
- Admin access log + ADMIN_EMAILS env guard
- CSP / HSTS / security headers

Output this as a `specs/legal/code-ui-punch-list-<YYYY-MM-DD>.md` file committed to the repo. It's both documentation and a todo list.

### Phase 10 - Memory + commit + handoff

Do BOTH of the following before ending - do not skip either.

10a. **Write / update the user's coding-agent memory.** The skill relies on future sessions remembering (i) which mailboxes are real, (ii) where the legal files live, (iii) the update rule. Write or update:

- `memory/markit-email-addresses.md` (or equivalent - the project's name substituted)
- `memory/legal-docs-update-rule.md` (covers: when to update, where to update, which placeholders are still open, citations to the baseline research and audit files)
- Index these in `memory/MEMORY.md` under a visible heading

See `references/memory-template.md` for the exact content template.

10b. **Commit and push.** Use the project's git rules (from CLAUDE.md). Default commit style: `feat(legal): comprehensive Privacy Policy + Terms of Service rewrite - GDPR / UK GDPR / CCPA / COPPA / <country> compliant` with a detailed body enumerating what changed and what placeholders remain. Push to main or the branch the user specified in Phase 0.

## Orchestration cheat-sheet

| Tool | When to use it | Why |
|---|---|---|
| **Agent-Team (parallel subagents via Claude Code Agent tool)** | Default for the 6 agents in this skill | Each agent has its own context, its own tools, its own budget. Parallelism cuts wall time roughly in half. |
| **ruflo agent-teams** | When the user's repo uses the Ruflo MCP integration | Ruflo adds task tracking + handoff protocol on top of bare subagents. |
| **ralph-loop** | When compliance is ongoing, not a one-shot | Example: a recurring quarterly audit to re-check DPF status, new Supabase regions, new sub-processors added since last run. NOT for the initial build. |
| **parallel-web-search skill** | Researcher agents (Phase 2, Phase 4, Reviewer B) | Primary research is the #1 determinant of legal accuracy. Web search must be parallelized. |
| **security-review skill** | Reviewer A | Provides the verification discipline for code-claim mapping. |
| **elements-of-style:writing-clearly-and-concisely skill** | Drafter (Phase 5) + Reviewer C | Legal prose fails when padded. Apply Strunk's rules. |
| **playwright-cli** | Post-ship verification | After Phase 10 push, spin up Playwright on the deployed `/privacy` and `/terms` pages to confirm the consent flow, footer address, and unsubscribe links render correctly on real browsers. |
| **WebFetch** | Main-session Phase 7 LIVE-VERIFY | Regulator primary sources are authoritative. |

## Anti-patterns to avoid

These are failure modes observed in the real world; the skill must actively prevent them:

- **Template-copying.** Never copy boilerplate privacy policy language from a template site. It never matches actual code behavior and misses the user's unique sub-processors. Every clause is code-audit-driven.
- **Inventing mailboxes.** `privacy@`, `legal@`, `noreply@`, `support@` are NOT assumed to exist. The skill ONLY uses mailboxes confirmed by the user in Phase 0 intake or already present in the project's memory. Inventing a mailbox has caused real users to have their CAN-SPAM unsubscribe mail bounce.
- **Inventing regulators.** If the user has no EU users, do not cite EDPB. If no Israeli users, do not invoke PPL. Research should be scoped to realistic jurisdiction exposure.
- **Over-promising user rights.** Don't write "self-service data export" unless the export endpoint ACTUALLY exists in the code. The drafter softens language when the code does not support the claim.
- **Vague retention.** "As long as necessary" is a regulator red flag. Replace with concrete periods or an "up to N days" with audit-sourced justification.
- **Copy-pasting peer policies.** Peer benchmarks are for structure and inspiration. Copy-pasting paragraphs is both a copyright issue and a context mismatch.
- **Skipping the code-UI punch list (Phase 9).** Shipping docs without the matching code changes creates documented liability gaps. Never skip Phase 9.

## How to use this skill

### For the end user (the vibe coder)

Invoke with phrases like:

- "Audit my privacy policy"
- "Write a privacy policy for my app"
- "Make my /privacy and /terms pages GDPR compliant"
- "Check if my legal docs match what my code actually does"
- "Add a cookie banner and update the policy"

Claude will invoke this skill and proceed through the Phase 0 intake. Expect the full pipeline to take 30-90 minutes of wall time in a well-tooled environment (subagents in parallel). Most of the time is research + review, which happens in the background.

### For the operator (the Claude session)

1. Invoke this skill in response to the triggers in the description.
2. Surface the disclaimer (top of this file) to the user FIRST.
3. Run Phase 0 intake; save answers to `.compliance-auditor/intake.md`.
4. Read ALL files in `references/` now, not later. They're scoped and short.
5. Spawn Phase 2 + Phase 3 + Phase 4 subagents in a SINGLE message with three tool calls.
6. When all three return, spawn Phase 5.
7. When Phase 5 returns, spawn Phase 6a + 6b + 6c in ONE message.
8. Handle Phase 7 LIVE-VERIFY items yourself in main session.
9. Spawn Phase 8 consolidator.
10. Run Phase 9 punch list.
11. Phase 10 memory + commit + push.

See `references/orchestration.md` for the agent prompt templates. DO NOT reinvent the prompts - use the templates; they encode what we learned from the real-world run.

## Files

- `references/jurisdictions.md` - per-jurisdiction requirement summaries + primary-source anchors
- `references/orchestration.md` - the agent prompt templates for all 10 phases
- `references/peer-benchmarking.md` - how to pick peers + what to extract
- `references/code-ui-recommendations.md` - Phase 9 punch-list source
- `references/memory-template.md` - Phase 10a templates for the user's project memory
- `references/disclaimer.md` - full-length disclaimer language for the policy itself (not just the warning to the user)
- `scripts/final-sweep.sh` - Phase 8 verification sweep (em dashes, fake emails, placeholders)
- `scripts/find-data-flows.sh` - Phase 3 helper that greps known third-party SDK imports to accelerate the code audit
- `assets/banner-disclaimer.md` - the user-visible "NOT LEGAL ADVICE" banner text to surface in chat
