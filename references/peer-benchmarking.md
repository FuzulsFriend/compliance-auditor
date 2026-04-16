# Peer benchmarking

How to pick the 5 peer SaaS companies for Phase 4 reverse-engineering, and what to extract from each.

## Why peer benchmarking matters

Template-based privacy policies fail because they ignore the user's actual product. Peer benchmarking gives the drafter clause structures that already survived regulator scrutiny for a product of the same shape. It is NOT a license to copy-paste - quote sparingly, adapt.

## Selection framework - pick 5 peers, one per slot

| Slot | Goal | How to pick |
|---|---|---|
| 1. Closest product shape | Mirrors the user's core value prop | Match by what the user SAVES (notes? links? media?), by how they ORGANIZE (folders? tags? AI-auto?), by their OUTPUT (search? digest? reminders?) |
| 2. Multi-jurisdictional polish | Shows what "regulator-checked" writing looks like | Companies with a public Trust Center + dedicated sub-processor page. Examples: Notion, Stripe, Cloudflare, Vercel |
| 3. Small-team crisp writing | Shows the friendliest policy that is still compliant | Companies known for plain-English legal. Examples: Linear, Stripe |
| 4. AI-native / privacy-first | Shows how to disclose AI flows cleanly | Companies whose value is AI + privacy. Examples: Raycast, Superhuman, 1Password |
| 5. Upstream dependency | Their DPA is the template the user inherits | The user's database host, auth provider, or biggest SaaS dependency. Examples: Supabase, Auth0, Clerk, Firebase |

## What to extract per peer

For each of the 5, WebFetch their `/privacy`, `/terms`, and `/subprocessors` or `/trust` pages and extract:

1. **Sub-processor disclosure structure** - table vs. prose; columns; subscribe-to-updates link
2. **"Information we collect" formatting** - categories vs. examples; purpose ties; specificity
3. **Legal-basis-per-purpose** - GDPR Art. 6 mapping style
4. **Retention** - concrete periods vs. "as long as necessary" (concrete is better)
5. **International transfers** - DPF / SCCs / UK IDTA phrasing and recipient-country list
6. **CCPA/CPRA structure** - dedicated section vs. interleaved; 11-category handling; GPC, SPI
7. **AI-specific language** - "we do not train on your content" phrasings
8. **User-rights mechanisms** - self-service vs. on-request, with phrasings
9. **Children's section** - age-gate and COPPA language
10. **Liability-limitation carve-outs** - how they preserve non-waivable EU/UK/IL/CA consumer rights
11. **AI-output disclaimers** - "outputs may be wrong, verify before acting"
12. **Acceptable use** - automation / bots / scraping stance (useful when the product itself scrapes)

## Output deliverable

A comparison matrix table (rows = topics, columns = the 5 peers + "recommended for our product") plus short per-peer deep dives with URLs. End with:

- Adopt-worthy clauses (verbatim quotes SHORT, marked as inspiration, URL cited)
- Sub-processor-list gaps our product has vs. peer norms
- Over-promise warnings (things peers claim that we cannot honestly replicate)

## Example peer sets

For reference, here are sets that have worked well in practice:

- **Content-capture / second-brain app:** Readwise, Notion, Linear, Raycast, Supabase
- **AI chat product:** Anthropic, OpenAI, Perplexity, Notion AI, HuggingFace
- **Scheduler / calendar-adjacent:** Reclaim.ai, Motion, Calendly, Fantastical, Google Workspace
- **Developer tool:** Vercel, Linear, GitHub, Stripe, Supabase
- **Email productivity:** Superhuman, Hey, Fastmail, Gmail (as reference not peer), ProtonMail

## Anti-patterns

- Picking five big enterprises (Google, Microsoft, Salesforce, IBM, Oracle). Their policies are over-scoped for a small SaaS.
- Picking a direct competitor whose legal posture is actively bad. Do not inherit their mistakes.
- Picking peers from one jurisdiction only. Spread the selection so the user sees how different regions handle the same clause.
