# Banner disclaimer - the exact message to show the user before Phase 0

Use this text verbatim at the start of every skill invocation. It is NOT optional.

---

**WARNING - NOT LEGAL ADVICE**

I'm about to draft your privacy policy, terms of service, and related compliance documents through a multi-agent workflow that reads your codebase, researches current regulator guidance, and benchmarks against peer SaaS policies.

Before we start, please acknowledge:

1. This skill is **not** a substitute for a licensed attorney in your jurisdiction.
2. Regulators (EU DPAs, ICO, California CPPA, FTC, Israeli PPA), app-store reviewers, and courts treat legal docs as legally binding regardless of how they were drafted.
3. You are **solely responsible** for having a qualified lawyer review the output before you rely on it - especially if any of these apply:
   - You charge users or will charge users
   - You have EU, UK, or California users at scale
   - You handle health, financial, biometric, or children's data
   - You sign enterprise B2B contracts with DPA clauses
   - You are responding to a regulator inquiry, DSAR, or complaint
4. The primary-source citations I'll include are aids for your attorney's review, not a substitute for it.

**Reply with "yes" to proceed, "no" to stop, or "explain" if you want more detail on any of the above.**

---

**After the user acknowledges:** move to Phase 0 (intake).

**If the user declines:** end the skill gracefully. Do not proceed.

**If the user pushes back ("I don't need a lawyer, just do it"):** repeat the warning once more, add a concrete example of what goes wrong (e.g., "Termly was sued in 2025 for users pasting their generator output without review; the generator disclaimed but users are still on the hook"), and ask again. If the user still insists, proceed but note in the output files that the user declined counsel review.
