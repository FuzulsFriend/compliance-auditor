# Orchestration - agent prompt templates

These are the proven agent prompts used in the production run that created this skill. Paste them into `Agent(...)` calls with only the project-specific substitutions. Do not rewrite them - they encode lessons from a real compliance rewrite.

## Phase 2 - Primary-source legal research (parallel)

**Subagent type:** `researcher` (Claude Code) or equivalent with web-search and WebFetch tools.

**Skills to load:** `parallel-web-search`.

**Prompt template:**

> You are researching authoritative primary-source requirements for a privacy policy and terms of service rewrite for {PROJECT_NAME}. Your output will feed a drafter agent that rewrites the legal docs. Be rigorous about primary sources - regulators and official texts, not blog posts.
>
> **Scope of the product:** {PROJECT_SCOPE - summary from Phase 0 intake}
>
> **Jurisdictions the docs must cover:** {ENUMERATED FROM INTAKE}
>
> For EACH jurisdiction, produce:
> a) The 5-10 most important concrete requirements the policy / ToU text must state or satisfy (specific clauses regulators check for, not general theory).
> b) At least 2 primary-source URLs per jurisdiction.
> c) Any 2025/2026-specific changes (Israel PPL Amendment 13, CPPA ADMT regs final text, EU AI Act touchpoints, Google API updates).
>
> Prefer these source domains: edpb.europa.eu, eur-lex.europa.eu (EU); ico.org.uk, legislation.gov.uk (UK); oag.ca.gov, cppa.ca.gov (California); ftc.gov (COPPA / CAN-SPAM); gov.il, justice.gov.il (Israel); developers.google.com/terms/api-services-user-data-policy; business.whatsapp.com, developers.facebook.com; datatracker.ietf.org; chromewebstore.google.com/developer-policies; dataprivacyframework.gov.
>
> **Output** at `{REPO_ROOT}/specs/legal/research-{YYYY-MM-DD}.md`. Structure:
> - `# {PROJECT_NAME} Legal Research - {YYYY-MM-DD}`
> - Per jurisdiction: `## N. Jurisdiction`, `### Requirements`, `### Sources`, `### 2025/2026 notes`
> - `## Cross-cutting requirements` (DPO thresholds, EU representative thresholds, DPIA triggers, breach timelines)
> - `## Recommended document structure` (outline of sections, ordered for regulator discoverability)
>
> Be pragmatic: flag which requirements apply to small ops vs. kick in at scale. Do NOT invent - if no primary source, say so.
>
> Budget: aim for 3000-5000 words. No filler.

## Phase 3 - Code data-practices audit (parallel)

**Subagent type:** `code-analyzer` or equivalent with Grep, Read, Glob.

**Prompt template:**

> You are auditing {PROJECT_NAME}'s codebase at {REPO_ROOT} to produce a FACTUAL inventory of data practices. Your output feeds a legal drafter who will rewrite the privacy policy + terms of service. The drafter CANNOT invent practices - they can only say what you tell them is true. Therefore: no speculation. When a practice exists, cite `file:line`. When you are unsure, say "unclear".
>
> **What to inventory:**
> 1. Categories of personal data collected (account data, user content, metadata, interaction events, device/session, communication IDs).
> 2. Third-party processors - for each: what data flows, purpose, hosting region, retention, cite code. {SEED_LIST_OF_LIKELY_PROCESSORS}.
> 3. Data retention actually implemented (soft-delete vs hard-delete, TTL jobs, cron cleanups, log expiry).
> 4. User-rights mechanisms (delete account, export, unsub, STOP, revoke OAuth, what ACTUALLY works vs. what is promised).
> 5. Cookies and storage - every cookie / localStorage / sessionStorage key with purpose.
> 6. Age gate / children enforcement (or absence).
> 7. Security measures in code (RLS, rate limiting, CSRF, CSP, hashing).
> 8. International transfers (where each processor is hosted).
> 9. Automated decision-making - what decisions does the AI make?
> 10. Google Limited Use compliance (if OAuth integration present) - does the code actually honor it?
> 11. Engagement / marketing messaging flow - legal basis, cap, unsub plumbing.
> 12. Anonymous vs. pseudonymous vs. identifiable telemetry.
>
> Use Grep + Read traversal. Read memory files (`memory/`, CLAUDE.md) for context.
>
> Output at `{REPO_ROOT}/specs/legal/data-practices-audit-{YYYY-MM-DD}.md`. Each bullet = one concrete fact with a `file:line` citation or "unclear". Also include a "Surprises / gaps / things that need policy language but have no code hook" section.
>
> Aim for 2000-3500 words of pure signal. Reply with path + a 150-word exec summary of the 5 most significant findings.

## Phase 4 - Peer benchmark (parallel)

**Subagent type:** `researcher` with parallel-web-search.

**Prompt template:**

> Reverse-engineer 5 SaaS peer companies to benchmark {PROJECT_NAME}'s legal posture against. Selection criteria (see `references/peer-benchmarking.md` of the compliance-auditor skill for the framework): match by product-shape, AI exposure, region, OAuth posture, small-team pedigree, compliance maturity.
>
> Default peer set if unsure:
> 1. Closest-product-shape peer (e.g., Readwise for content-capture apps)
> 2. Multi-jurisdictional polished-docs peer (e.g., Notion)
> 3. Small-team crisp-writing peer (e.g., Linear)
> 4. AI-native / privacy-first peer (e.g., Raycast)
> 5. Upstream dependency peer (e.g., the project's own database host - Supabase, Neon, etc.)
>
> For each, extract: sub-processor disclosure structure, legal-basis-per-purpose formatting, retention language, international-transfers mechanism, CCPA categories section style, AI-training language ("we do not train on your data"), user-rights wording, children's section, liability-limitation carve-outs, AI-output disclaimers, acceptable-use stance.
>
> Output at `{REPO_ROOT}/specs/legal/benchmark-peers-{YYYY-MM-DD}.md`. Lead with a comparison matrix table. Then per-peer deep dives with short verbatim quotes and URLs (no large blocks - inspiration not plagiarism). Conclude with "adopt-worthy clauses", "sub-processor list gaps vs. peer norms", "over-promises to watch".
>
> Budget: 2500-4000 words.

## Phase 5 - Draft

**Subagent type:** `coder` with file-edit tools.

**Skills to load:** `elements-of-style:writing-clearly-and-concisely`.

**Inputs:** research file + audit file + benchmark file + existing pages (if any) + Phase 0 intake.

**Prompt template:**

> You are rewriting {PROJECT_NAME}'s privacy policy and terms of service pages. Regulators and app-store reviewers read these. Your output will be reviewed by a three-reviewer quality gate.
>
> **Read first and let these drive every word:**
> 1. {RESEARCH_PATH}
> 2. {AUDIT_PATH}
> 3. {BENCHMARK_PATH}
> 4. {INTAKE_PATH}
>
> **Hard constraints:**
> - Accuracy over aspiration. If the audit says "no data-export endpoint exists", write "on request via support" not "self-service export".
> - Sub-processor list MUST be complete (every vendor in the audit, none missing, none added).
> - Jurisdictions per intake - cover every one in scope, with named regulator + primary-source citations.
> - Real contact emails only - {LIST_FROM_INTAKE}.
> - Last Updated: {TODAY}.
> - Project style rules from CLAUDE.md (no em dashes, etc.).
> - Leave placeholders for open items rather than inventing (EU/UK Art. 27 reps, physical mailing address, Hebrew translation, DPO statement, CAN-SPAM address if not yet supplied).
> - Include a "Key changes in this update" block at the top summarizing corrections.
>
> **Write to:**
> - {REPO_ROOT}/{PRIVACY_PAGE_PATH}
> - {REPO_ROOT}/{TERMS_PAGE_PATH}
> - {REPO_ROOT}/specs/legal/PRIVACY-POLICY.md (canonical source, kept in sync)
> - {REPO_ROOT}/specs/legal/TERMS-OF-SERVICE.md
>
> **Verify at end:** `tsc --noEmit` or project's equivalent returns zero errors.
>
> **Reply** with file paths + ~200-word summary structured as (a) what was corrected, (b) what was added per audit/research, (c) placeholders still requiring user input, (d) language deliberately softened + why.

## Phase 6 - Three parallel reviewers

Dispatch all three in ONE message with three tool calls. Do not serialize.

### 6a - code-vs-claims

**Subagent type:** `security-auditor`. **Skill:** `security-review`.

**Prompt:**

> You are Reviewer A. Lane: factual accuracy vs. code. Read {AUDIT_PATH}, then the drafted pages. For every claim in the pages, verify with grep/read. Cite `file:line` for findings. Check: sub-processor list completeness both ways, retention periods backed by code, user-rights mechanisms exist, cookies actually set match the table, security controls present, Google Limited Use four exceptions verbatim if applicable, int'l transfers match hosting, age gate claims match reality, AI-training statement matches provider contracts, admin-access claims match ADMIN_EMAILS or equivalent.
>
> Output at `{REPO_ROOT}/specs/legal/review-6a-code-vs-claims-{YYYY-MM-DD}.md`. Structure: Verdict (PASS / PASS WITH FIXES / FAIL). Critical issues (with proposed exact replacement text). Non-critical issues. Confirmed-accurate highlights. Gaps. Over-disclosure.

### 6b - legal accuracy

**Subagent type:** `researcher`. **Skill:** `parallel-web-search`.

**Prompt:**

> You are Reviewer B. Lane: legal accuracy vs. primary sources. Read {RESEARCH_PATH} + {BENCHMARK_PATH} + drafted pages. Validate every statement of law. Per jurisdiction (EU GDPR Art. 6 bases + Art. 13 fields + Art. 27 rep statement + Art. 44 transfer mechanism + Art. 33 breach); UK GDPR (ICO as authority, UK IDTA); CCPA/CPRA (11 categories, sale/share, GPC, SPI, ADMT); COPPA + EU Art. 8 age; Israel PPL Amendment 13 (PPA, Hebrew); Google Limited Use four exceptions verbatim (WebFetch to confirm); Meta WhatsApp; RFC 8058; AI Act touchpoints; LoL consumer carve-outs.
>
> WebFetch primary sources to verify. If WebFetch is unavailable, flag LIVE-VERIFY items for main session.
>
> Output at `{REPO_ROOT}/specs/legal/review-6b-legal-accuracy-{YYYY-MM-DD}.md`. Critical misstatements + non-critical polish + missing disclosures + over-precise claims.

### 6c - prose + consistency

**Subagent type:** `reviewer`. **Skill:** `elements-of-style:writing-clearly-and-concisely`.

**Prompt:**

> You are Reviewer C. Lane: prose quality + cross-doc consistency. Grep em dashes (U+2014) - must be 0 per project rule if applicable. Grep fake emails / placeholder domains. Plain-English pass - passive->active, cut "very/just/simply", split >30-word sentences, replace "pursuant to"/"in the event that"/"utilize". Voice consistency. Section numbering. Sub-processor list in /privacy matches /terms references. Last Updated consistent. Key-changes block truthful. Internal cross-links correct. External links rel="noopener noreferrer". Markdown-JSX sync. A11y: table scope="col", alt text, color contrast.
>
> Output at `{REPO_ROOT}/specs/legal/review-6c-prose-consistency-{YYYY-MM-DD}.md`. Every finding with an exact find/replace suggestion.

## Phase 7 - Main-session LIVE-VERIFY

When Reviewer B flags LIVE-VERIFY items (often because its WebFetch was sandbox-denied), the main Claude session handles these. Use `WebFetch` with these exact URLs at minimum:

- https://developers.google.com/terms/api-services-user-data-policy (Limited Use four exceptions, verbatim)
- https://cppa.ca.gov/regulations/ (CPPA ADMT status and effective dates)
- https://www.dataprivacyframework.gov/list (certification status of US recipients)
- Any other primary source Reviewer B marked LIVE-VERIFY

Pass the verified text into the Phase 8 fixer's prompt as "main-session-verified text".

## Phase 8 - Consolidated fixer

**Subagent type:** `coder`.

**Prompt template:**

> Consolidate fixes from three reviews into {PRIVACY_PATH} and {TERMS_PATH}. Surgical only - no re-architecture.
>
> Inputs:
> - {REVIEW_6A_PATH}
> - {REVIEW_6B_PATH}
> - {REVIEW_6C_PATH}
> - Main-session-verified text (pasted): {VERIFIED_TEXT_FROM_PHASE_7}
>
> Apply priority:
> 1. Every 6a critical.
> 2. Every 6b critical.
> 3. Cross-doc asymmetries from 6c.
> 4. A11y fixes (scope="col", alt text).
> 5. Top-10 prose tightenings from 6c.
>
> Mirror all edits to canonical markdown spec copies.
>
> Append to the Key-changes block the additional entries reflecting THIS revision (concise).
>
> Verify at end:
> - `tsc --noEmit` zero errors.
> - Em dash count across shipped files: 0.
> - Fake email / placeholder domain sweep: 0.
> - Verbatim appearance of Google Limited Use four exceptions, if applicable.
> - Cross-doc consistency of Last Updated + controller identity + retention + sub-processor list.
>
> Reply with: files modified, tsc result, grep counts, 200-word change summary, list of reviewer findings NOT applied + why.

## Phase 10a - Memory templates

Two files to write / update in the user's project memory:

### `memory/{project}-email-addresses.md`

```
---
name: {project} real email addresses
description: Authoritative list of existing {DOMAIN} mailboxes and which to use for which purpose.
type: reference
---

Real mailboxes on `{DOMAIN}` - do NOT invent local parts:

- {legal_email} - legal / privacy / policy contact
- {support_email} - general user support
- {from_email} - outgoing transactional email FROM address
- {other_emails_from_intake...}

Mapping rules when replacing legacy references:
- privacy@ -> {legal_email}
- legal@ -> {legal_email}
- support@ -> {support_email}
- noreply@ -> never use; pick from the real list above

Do NOT use or invent other local parts. Confirm via user before adding any new address to this list.
```

### `memory/legal-docs-update-rule.md`

See `references/memory-template.md` (full file).

## Notes on tool choice

The skill is designed around the Claude Code Agent tool. If the user's environment is different:

- **Cowork:** subagents work but no browser. Use `--static` for generate_review. All other phases run unchanged.
- **Claude.ai:** no subagents. Collapse the 6 agents into sequential main-session work. The skill still provides value but wall time is ~3x longer. Skip the parallelism notes; proceed linearly.
- **Claude API without agents:** the skill is less effective but the references still useful as a research checklist.
