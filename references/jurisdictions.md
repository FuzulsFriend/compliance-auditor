# Jurisdictions reference

Per-jurisdiction requirement summaries and primary-source anchor URLs. The researcher agent (Phase 2) uses this as a starting checklist; it then confirms each requirement against the primary source at run time because laws change faster than static files.

Table of contents:
1. EU GDPR
2. UK GDPR + DPA 2018
3. California CCPA / CPRA
4. US COPPA
5. Israel PPL (Amendment 13, 2025)
6. EU ePrivacy / PECR (cookies + marketing email)
7. Google API Services User Data Policy (Limited Use)
8. Meta / WhatsApp Business Platform Policy
9. CAN-SPAM Act + RFC 8058
10. EU AI Act touchpoints (2024/1689)
11. Web Content Accessibility Guidelines (WCAG / EAA / ADA)
12. Cross-cutting: DPF, SCCs, transfer mechanisms

---

## 1. EU GDPR

Regulation (EU) 2016/679. Applies where: the business is established in the EU, OR the business offers services to data subjects in the EU, OR monitors behaviour of EU data subjects.

### Minimum policy fields (Art. 13 / 14)

- Identity + contact of the controller
- Contact of the DPO (or statement of no DPO if below threshold)
- Purposes of processing + legal basis per purpose (Art. 6(1)(a)-(f))
- Legitimate interests detail (if relied on)
- Recipients / categories of recipients
- Transfers to third countries + the mechanism (SCCs, DPF, adequacy)
- Retention per purpose
- Rights (access, rectification, erasure, restriction, portability, objection, not be subject to automated decision-making)
- Right to withdraw consent (where consent is the basis)
- Right to lodge complaint with a supervisory authority (name the user's national DPA)
- Source of data (if not from the subject directly)
- Existence of automated decision-making + consequences + logic

### Art. 27 representative

Required for non-EU controllers who offer services to EU data subjects, UNLESS the "occasional, low-risk, no special categories" exemption applies (Art. 27(2)(a)). Vibe-coder threshold: when marketing begins in EU, appoint one. Until then, state the obligation is acknowledged and a rep will be appointed.

### Sources

- https://eur-lex.europa.eu/eli/reg/2016/679/oj (regulation text)
- https://edpb.europa.eu/edpb_en (EDPB guidelines)
- https://commission.europa.eu/law/law-topic/data-protection_en (EC portal)

## 2. UK GDPR + DPA 2018

Post-Brexit, the UK adopted a parallel regime. ICO is the regulator. Transfer mechanism to non-adequate jurisdictions: UK IDTA or the UK Addendum to EU SCCs.

### Delta from EU GDPR

- ICO, not EDPB, is the supervisory authority
- UK Art. 27 representative needed separately from EU Art. 27 rep
- Cookie rules come from PECR, not the ePrivacy Directive directly

### Sources

- https://ico.org.uk/for-organisations/
- https://www.legislation.gov.uk/ukpga/2018/12/contents

## 3. California CCPA / CPRA

Applies to businesses processing data of CA residents when they meet ONE of: $25M gross revenue, buys/sells/shares PI of 100k+ consumers, derives 50%+ revenue from selling PI. Vibe-coder threshold is usually below all three but the CCPA disclosures are industry-standard so ship them anyway.

### Minimum disclosures

- The 11 enumerated categories of PI collected (Cal. Civ. Code § 1798.140(v))
  - A. Identifiers (name, email, IP)
  - B. Customer records (Cal. Civ. Code § 1798.80(e))
  - C. Protected classifications under CA or federal law
  - D. Commercial information (products purchased, tendencies)
  - E. Biometric information
  - F. Internet or network activity (browsing, search, interaction)
  - G. Geolocation data
  - H. Sensory data (audio, visual, thermal, olfactory)
  - I. Professional or employment-related information
  - J. Education information (non-public, under FERPA)
  - K. Inferences drawn from the above
- Sensitive Personal Information statement (Cal. Civ. Code § 1798.140(ae))
- Sale / share position (explicit "we do not sell or share" if applicable)
- Global Privacy Control (GPC) honoring
- Consumer rights (know, delete, correct, opt-out, limit, non-discrimination)
- ADMT (Automated Decisionmaking Technology) disclosure per CPPA regs adopted Sept 2025 - phased implementation, monitor the CPPA site for dates
- Shine the Light Act (Cal. Civ. Code § 1798.83) for third-party direct marketing

### Sources

- https://oag.ca.gov/privacy/ccpa
- https://cppa.ca.gov/regulations/

## 4. US COPPA

Children's Online Privacy Protection Act. Applies if the service is directed at children under 13 OR the operator has actual knowledge it is collecting PI from children under 13.

### Safe wording

"MarkIt is not directed to children under 13. We do not knowingly collect personal information from children under 13. If a parent or guardian believes that we have collected information from a child under 13, contact [legal email] and we will delete it within 48 hours."

### Sources

- https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa

## 5. Israel Privacy Protection Law (Amendment 13, in force August 2025)

Applies to database owners in Israel. Major 2025 changes:

- New notice obligations (similar to GDPR Art. 13 but lighter)
- Hebrew-language access to policy on request (best practice, not strictly mandated, but regulator-preferred)
- PPA (Privacy Protection Authority) is the supervisor
- Terminology - "controller" concept in Israeli law maps to "database owner" (בעל מאגר)
- Transfer out of Israel - adequacy or consent or registered-DPA with destination

### Sources

- https://www.gov.il/en/departments/israel_privacy_protection_authority
- https://www.gov.il/BlobFolder/legalinfo/privacy_protection_law/he/The%20Privacy%20Protection%20Law.pdf

## 6. EU ePrivacy / PECR (cookies + marketing email)

Directive 2002/58/EC as amended by 2009/136/EC; UK Privacy and Electronic Communications Regulations 2003 (PECR).

### Cookies

Consent required for non-essential cookies. The "strictly necessary" exception covers: auth sessions, load-balancing cookies, CSRF tokens, remembered consent state. Everything else (analytics, personalization, marketing) requires opt-in BEFORE being set.

### Marketing email

"Soft opt-in" (PECR Reg. 22(3) and similar national transpositions of Art. 13(2)): marketing to existing customers about similar services is permitted without fresh consent IF:
- Email was collected during a sale or negotiation of a sale
- Every email offers a one-click unsubscribe
- First email explicitly offered opt-out

### Sources

- https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32002L0058
- https://www.legislation.gov.uk/uksi/2003/2426/contents/made

## 7. Google API Services User Data Policy (Limited Use)

Applies if the product uses Google OAuth to access user data beyond basic profile. The FOUR exceptions under which accessing / using / storing Google user data is permitted must be stated in the policy:

1. "To provide or improve your appropriate access or user-facing features that are visible and prominent in the requesting application's user interface and only with the user's consent"
2. "For security purposes (for example, investigating abuse)"
3. "To comply with applicable laws"
4. "As part of a merger, acquisition, or sale of assets of the developer after obtaining explicit prior consent from the user"

Quote these verbatim. Paraphrasing invalidates Google's annual OAuth audit.

### Sources

- https://developers.google.com/terms/api-services-user-data-policy (authoritative; WebFetch this to confirm current wording before shipping)

## 8. Meta / WhatsApp Business Platform

If the product runs a WhatsApp bot or Messenger integration:

- WhatsApp Business Terms: https://www.whatsapp.com/legal/business-terms/
- WhatsApp Commerce Policy: https://business.whatsapp.com/policy
- Opt-in requirement for marketing templates
- Quality rating affects deliverability
- Link to these in the ToS third-party services section

## 9. CAN-SPAM Act + RFC 8058

US commercial email law + IETF one-click unsubscribe standard.

### CAN-SPAM requirements for every commercial email

- Accurate header / subject lines (15 USC § 7704(a)(1)-(2))
- Clear "this is an advertisement" identification IF the primary purpose is commercial
- **Valid physical postal address** (15 USC § 7704(a)(5)(A)(iii)) - every commercial email, not just the policy
- Clear and conspicuous unsubscribe (15 USC § 7704(a)(5)(A)(ii))
- Honor opt-out within 10 business days (15 USC § 7704(a)(4)(A))

### RFC 8058 one-click unsubscribe

Set these headers on marketing email:
```
List-Unsubscribe: <https://yourapp/unsub?u=...>, <mailto:unsub@yourdomain>
List-Unsubscribe-Post: List-Unsubscribe=One-Click
```

Gmail and Yahoo enforce this for senders >5k messages/day as of Feb 2024.

### Sources

- https://www.ftc.gov/business-guidance/resources/can-spam-act-compliance-guide-business
- https://datatracker.ietf.org/doc/html/rfc8058

## 10. EU AI Act (Regulation 2024/1689)

Phased effective dates:
- Prohibited practices: Feb 2025
- GPAI rules: Aug 2025
- High-risk obligations: Aug 2026 (transitions through 2027)

### For vibe-coder SaaS products

Most consumer AI features are NOT high-risk. Light-touch requirements:
- Art. 50 transparency: if AI output could be mistaken for a human or for factual content, label it
- Art. 50(2): AI-generated or AI-manipulated content must be machine-readable flagged
- If the product uses foundation models (OpenAI, Anthropic, etc.), document the model family used

### Sources

- https://eur-lex.europa.eu/eli/reg/2024/1689/oj
- https://artificialintelligenceact.eu/

## 11. Accessibility (WCAG / EAA / ADA)

### WCAG 2.2

Level AA is the conformance target for most SaaS. Key deliverables for the accessibility statement on the website:

- Statement of conformance level claimed
- Known limitations / ongoing work
- Contact for accessibility feedback
- Date of last review

### EAA (European Accessibility Act)

Applies from June 28 2025 to consumer-facing digital services in the EU (with small-enterprise exemption for <10 employees AND <€2M turnover, but ship compliance anyway because exemptions are narrow).

### ADA Title III

US private businesses. Courts have generally held that websites of places of public accommodation must be accessible. DOJ guidance recommends WCAG 2.1 AA as the de facto standard.

### Sources

- https://www.w3.org/TR/WCAG22/
- https://www.europarl.europa.eu/RegData/docs_autres_institutions/commission_europeenne/com/2015/0615/COM_COM(2015)0615_EN.pdf
- https://www.ada.gov/resources/web-guidance/

## 12. Cross-cutting: DPF, SCCs, transfer mechanisms

### EU-US / UK-US / Swiss-US Data Privacy Framework

Replaces Privacy Shield. A US recipient certified under DPF provides an adequacy-equivalent legal basis for transfer from EU/UK/Switzerland. Certification lookup: https://www.dataprivacyframework.gov/list

### Standard Contractual Clauses (SCCs)

Commission Implementing Decision (EU) 2021/914. Four modules (C2C, C2P, P2P, P2C). UK has a separate Addendum bolted onto the EU SCCs for UK transfers.

### Adequacy decisions relevant to vibe coders

- Israel: EU has adequacy for Israel (Commission Decision 2011/61/EU), partial and under review
- UK: EU and UK have mutual adequacy
- Canada: partial adequacy (commercial orgs under PIPEDA)
- Japan, South Korea: adequacy
- US: DPF for certified organizations only

### Sources

- https://www.dataprivacyframework.gov/list (certification lookup - bookmark for the policy build)
- https://eur-lex.europa.eu/eli/dec_impl/2021/914/oj (SCCs text)
