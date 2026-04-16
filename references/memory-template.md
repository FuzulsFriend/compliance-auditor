# Memory templates (Phase 10a)

The skill MUST write these files into the user's project memory at the end of every run, and index them in `MEMORY.md` (the index the user's coding agent loads at session start). Without this, the next session forgets what was learned and the docs drift from the code over time.

## File 1: `memory/{project}-email-addresses.md`

```markdown
---
name: {project} real email addresses
description: Authoritative list of existing {DOMAIN} mailboxes and which to use for which purpose. Domain is {DOMAIN} (not {LEGACY_DOMAIN_IF_ANY}).
type: reference
---

Real mailboxes that exist on `{DOMAIN}` (do NOT invent new local parts):

- {legal_email} - owner inbox; use for **legal docs contact** (Privacy Policy, Terms of Service, OAuth compliance)
- {support_email} - general user support; use wherever UI says "Support" or "Contact us"
- {from_email} - outgoing transactional/marketing FROM address
- {other_emails_from_intake...}

Do NOT use or invent: `privacy@`, `legal@`, `noreply@`, `admin@`, or any other local part unless the user confirms it exists. When replacing legacy references in code/spec, map:

- any `privacy@...` -> {legal_email}
- any `legal@...` -> {legal_email}
- any `support@...` -> {support_email}
- any `reminders@...` -> {from_email_or_dedicated_reminders_inbox}

Any remaining `@{LEGACY_DOMAIN}` reference in new code is a bug.
```

## File 2: `memory/legal-docs-update-rule.md`

```markdown
---
name: Legal docs update rule
description: Whenever the product adds/changes/removes anything that affects data flows, sub-processors, retention, user rights, age gates, AI usage, jurisdictions, or marketing channels, the privacy policy AND terms of service MUST be updated in the same PR.
type: feedback
---

**Rule:** Any change that touches user data, a third-party processor, a new feature that collects/sends data, a new AI model, a new marketing channel, a new jurisdiction, a retention schedule, a user right, or an age policy triggers a REQUIRED update to:

- `{PRIVACY_PAGE_PATH}` (the rendered /privacy page)
- `{TERMS_PAGE_PATH}` (the rendered /terms page)
- `specs/legal/PRIVACY-POLICY.md` (canonical source)
- `specs/legal/TERMS-OF-SERVICE.md` (canonical source)
- The "Last Updated" date in all four files
- A brief "Key changes in this update" entry at the top of each policy so readers can diff versions

**Triggers (non-exhaustive - err on the side of updating):**

1. Adding any new sub-processor / SaaS vendor that sees user data.
2. Dropping or replacing an existing sub-processor.
3. Introducing a new data category (new table, new cookie, new localStorage key, new sessionStorage identifier, new header-based tracking).
4. Changing retention - e.g., flipping advisory purge to enforced, adding a new cron cleanup.
5. Adding or changing an AI feature (new model family, new provider, zero-retention flag toggled).
6. Changing OAuth scopes or adding a new Google API - update the Limited Use disclosure.
7. Adding WhatsApp / Telegram / SMS / email channels beyond what's documented.
8. Enabling paid features, changing the credit system, or changing invoicing - update ToS.
9. Expanding into a new jurisdiction - appoint Art. 27 rep BEFORE marketing launches.
10. Rolling out previously-promised features (self-service export, in-app Calendar revoke, Telegram STOP) - tighten "on request" wording.
11. Database region change or deployment region change - update international-transfers.
12. Chrome Extension permission change or new mobile-store distribution.
13. Regulator guidance that affects our disclosures (updated EDPB guidance on AI, CPPA regs finalizing).

**How to update:**

1. Consult `specs/legal/research-{DATE}.md` for jurisdictional requirements. Rerun the researcher agent if law changed materially.
2. Consult `specs/legal/data-practices-audit-{DATE}.md` and re-audit via grep if you touched data flows.
3. Keep the page styling - prose changes only.
4. Legal contact stays {legal_email}. Support {support_email}. No em dashes. Never invent mailboxes.
5. Mirror edits to both the `.tsx` page AND the `specs/legal/*.md` canonical copy so they don't drift.
6. In the PR description, call out WHICH new fact triggered the update so the reviewer can validate.

**Placeholders that need the owner's input (track these - remove when filled):**

- EU Art. 27 representative identity (appoint before EU marketing)
- UK Art. 27 representative identity
- Physical mailing address (CAN-SPAM) - {filled_or_open}
- Hebrew-language privacy policy commitment under Israel PPL Amendment 13
- Formal DPO designation if thresholds are hit

**Baseline artifacts (do not delete - future runs reference them):**
- Research: `specs/legal/research-{DATE}.md`
- Code audit: `specs/legal/data-practices-audit-{DATE}.md`
- Peer benchmark: `specs/legal/benchmark-peers-{DATE}.md`
- Review trail: `specs/legal/review-6a-*.md`, `review-6b-*.md`, `review-6c-*.md`

Purpose of this rule: prevent the next session from silently shipping a feature that diverges the product from the policy.
```

## File 3: Update to `memory/MEMORY.md`

Add a new section near the top of MEMORY.md so future Claude sees it early:

```markdown
## Email Addresses (CRITICAL - don't invent)
- [Real {DOMAIN} mailboxes]({project}-email-addresses.md) - {short summary}

## Legal Docs Update Rule (CRITICAL - do not ship features past this)
- [Update /privacy and /terms on any data-flow change](legal-docs-update-rule.md) - triggers, where to update, placeholders Tomer still owes. Research baseline: `specs/legal/research-{DATE}.md`. Code audit baseline: `specs/legal/data-practices-audit-{DATE}.md`.
```

## Verification checklist

After writing the memory files, the skill MUST:

- Confirm MEMORY.md has the new entries near the top (visible to future sessions)
- Confirm file paths in the rule match the actual paths in the repo
- Confirm every placeholder still-open is listed in the rule with a concrete "fill by X trigger" note
- Commit the memory files along with the legal docs in the same PR / commit

## Substitution guide

The `{}` placeholders above must be filled at Phase 10a time:

- `{project}` = short project name (kebab-case)
- `{DOMAIN}` = the project's primary domain (e.g., mark-it.co)
- `{legal_email}` = real email for privacy/legal contact (from intake)
- `{support_email}` = real support email
- `{from_email}` = real transactional FROM address
- `{PRIVACY_PAGE_PATH}` = project-relative path to the rendered page
- `{TERMS_PAGE_PATH}` = same for terms
- `{DATE}` = today's date in YYYY-MM-DD format
- `{LEGACY_DOMAIN_IF_ANY}` = any prior domain the project used (for the "do not revert" rule)
