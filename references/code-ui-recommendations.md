# Code and UI punch list (Phase 9)

After the policy docs land, the code and UI must actually match what was promised. This is the forgotten phase of compliance work and the difference between "good docs" and "real compliance".

Use this checklist as the starter. Tailor each item to what the drafted policy actually claims.

## Sign-up consent flow

**Why it matters:** US case law (Meyer v. Uber, 2nd Cir 2017; Berkson v. GoGo) repeatedly held that "browsewrap" - legal notice below or separate from the action button - often fails in court. "Sign-in-wrap" - notice directly above the action - is the industry standard.

**What to check:**
- Notice "By clicking Sign up, you agree to the Terms of Service and Privacy Policy" sits DIRECTLY above the Sign up / Sign in / Continue button, not below, not in a separate footer block.
- Notice adapts verb to action mode: "signing up" vs "signing in" vs "continuing".
- Links open in new tab with `target="_blank" rel="noopener noreferrer"`.
- Same notice appears for Google OAuth, email signup, magic link, any other signup path.

**What to AVOID:** double checkbox patterns. No successful SaaS uses them. They kill conversion and are not legally required for a properly-worded sign-in-wrap + GDPR soft opt-in + one-click unsub combo.

## CAN-SPAM email footer

Every commercial / engagement / marketing email (not purely transactional) must include:

- Sender identification (who the email is from)
- Physical postal address (valid postal mail delivery)
- Unsubscribe link (clear, conspicuous)
- RFC 8058 `List-Unsubscribe` + `List-Unsubscribe-Post: List-Unsubscribe=One-Click` headers

**Where to check in code:**
- Email template file (e.g., `app/lib/email/templates/*.ts` or `emails/*.tsx` for React Email)
- Resend / Postmark / SendGrid send calls - confirm the headers are set
- The actual rendered email output from a test send

**Exempt emails** (true transactional): password resets, reminder-you-scheduled, order confirmations, account status. Physical address is nice-to-have but not strictly required.

## Cookie banner + GPC

If the site sets any non-essential cookies OR ships analytics / advertising SDKs, you need a consent layer.

- **EU / UK / CH:** opt-in BEFORE cookies are set (strictly-necessary ones fine without consent).
- **California:** honor Global Privacy Control (GPC) signal - treat as an opt-out of sale / share.
- **Record consent:** log that the user consented and with what choices, so a regulator request can be answered.

Recommendation: if the site uses only strictly-necessary cookies (auth, CSRF, consent state), you do not need a banner. Add analytics only if you also ship a banner. Skip the third-party cookie banner SDKs if possible - a simple home-grown component keeps the code auditable.

## Data export

If the privacy policy claims self-service data export, a real endpoint MUST exist. Otherwise the policy says "on request via {legal_email} within 30 days".

**Check:**
- Does `app/app/api/user/export/route.ts` (or equivalent) exist?
- Does it return ALL user-linked data in a portable format (JSON or ZIP)?
- Is it rate-limited?

If no endpoint exists, either SHIP one (best) or FIX the policy to say "on request" (honest).

## Account deletion cascade

If the policy says "deleting your account deletes all your data", the cascade must actually work.

**Check:**
- The `/api/user/delete` endpoint exists.
- Every table with a user_id foreign key has `ON DELETE CASCADE` OR is cleaned up in a transaction inside the delete endpoint.
- Bot message logs, engagement message logs, audit logs, admin logs all cascade.
- Soft-deleted records are hard-deleted at retention expiry by a cron job (or the policy hedges to "up to X days").

**Common failure:** old tables added over time use `ON DELETE SET NULL` instead of CASCADE. These orphaned rows survive account deletion and are a GDPR Art. 17 erasure violation.

## Row-level security (RLS)

For Supabase or any multi-tenant Postgres, RLS must be enabled on every user-data table.

**Check:**
- Each migration for a user-data table ends with `ALTER TABLE {name} ENABLE ROW LEVEL SECURITY;` and an appropriate policy.
- Queries from server code honor `auth.uid()` rather than bypassing with service-role keys.
- Tests exist for cross-tenant access attempts.

## One-click unsubscribe

Per RFC 8058, marketing email should honor one-click. Since Feb 2024 Gmail + Yahoo REQUIRE this for senders over 5k messages/day.

**Check:**
- `List-Unsubscribe` and `List-Unsubscribe-Post` headers set.
- The endpoint at the header URL handles unsubscribe without requiring login.
- Preferences table has the opt-out recorded.
- Next send to that user actually skips them (this is the one that fails most often - add an integration test).

## Channel-specific opt-outs

For every messaging channel claimed in the policy:

- **Email:** RFC 8058 one-click + in-app preferences toggle.
- **WhatsApp:** STOP keyword handler. Bilingual if the product serves non-English users.
- **Telegram:** `/stop` or `/unsubscribe` command. Also an in-app unlink button.
- **SMS:** STOP keyword per carrier rules.

Each must be tested with a real send-and-STOP flow in staging. Silent opt-out failure is a CAN-SPAM / PECR violation.

## Admin access controls

If the policy says "only staff on the ADMIN_EMAILS list can access production data":

- Confirm the env var or equivalent control exists.
- Confirm access attempts are logged to an admin_audit_log table.
- Confirm the log is immutable or tamper-evident.

## Security headers

Match what the policy's security section claims.

**Common claims:**
- HTTPS enforced (HSTS header + `Strict-Transport-Security: max-age=31536000; includeSubDomains`)
- CSP (Content-Security-Policy). If the claim is "strict CSP", verify it is not `Content-Security-Policy-Report-Only`. If it IS report-only, say so in the policy.
- X-Frame-Options or `frame-ancestors` in CSP
- X-Content-Type-Options: nosniff
- Referrer-Policy
- Permissions-Policy

## Data Privacy Framework status

If the policy names specific US sub-processors and claims DPF as a transfer mechanism, periodically (quarterly) check DPF certification:

- https://www.dataprivacyframework.gov/list
- Remove a recipient from the DPF reliance column if their certification lapses; fall back to SCCs.

## Accessibility

If an accessibility statement is shipped, make sure the site actually meets it.

**Check:**
- Keyboard navigation works end-to-end.
- Focus states visible.
- Form fields have labels.
- Images have alt text (or `alt=""` for decorative).
- Color contrast meets WCAG 2.2 AA.
- Screen reader tested on the primary flows (Axe, Lighthouse, or manual).

## Logging content retention

If server logs are mentioned in the policy with a retention period, the claim must match infrastructure. Vercel platform logs are ~30 days for Pro; confirm the policy's number.

## Output format for the punch list

Write `{REPO_ROOT}/specs/legal/code-ui-punch-list-{YYYY-MM-DD}.md` as a checklist. Each item:

- **Status:** DONE / OPEN / NEEDS ATTENTION
- **Evidence:** `file:line` OR "no evidence found - must ship or change policy"
- **Action:** specific next step (move notice above button, add `scope="col"` to table headers, ship data-export endpoint, etc.)

Commit this file alongside the legal docs. Future Claude sessions will use it as the compliance todo list.
