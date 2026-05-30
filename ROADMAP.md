# EuroLeague Insight Roadmap

> **Working title / brand:** EuroLeague Insight (About screen). Store title still `EuroLeague Predictor` in `main.dart` — **align before public launch** (see [Brand & Positioning](#brand--positioning)).

## Vision

EuroLeague Insight should not only display data.

It should help users understand:

- Who is likely to win
- Why
- Which factors matter most
- **What actually happened — and how that compares to what we predicted**

**Core identity (May 2026):** **scouting & statistical analysis** for EuroLeague — not a livescore clone, not a tipster app. Prediction is the *output* of deep stats work; the *difference* is how we read teams, players, and matchups.

Combining:

- Team statistics
- Player statistics
- Form
- Injuries
- Advanced metrics
- Proprietary indicators

## Brand & Positioning

### What we are

| We are | We are not |
|--------|------------|
| Scouting + stats analysis platform for EuroLeague | Official results / news app |
| MatchUp-driven decision support | Generic multi-sport livescore |
| Honest prediction with factor breakdown | “94% accuracy” tipster |
| Player/team deep dives (roster, compare) | Fantasy game |

**Tagline direction:** *Scout smarter. Predict honestly.* (or similar — stats-first, prediction-second)

### Naming

| Name | Pros | Cons |
|------|------|------|
| **EuroLeague Insight** ✅ (preferred) | Analysis, scouting, room for predictions + post-game | Generic; doesn’t say “basketball” in search |
| EuroLeague Predictor | Clear hook for % | Sounds like tipster; undersells stats/scouting depth |
| EuroLeague Scout / Edge | Strong scouting hook | Harder trademark; less prediction story |

**Decision:** converge on **EuroLeague Insight** for store + UI; subtitle in store listing: *Stats, scouting & match predictions for EuroLeague.*

### Competitive hook (one sentence)

> The app that **scouts every matchup with real stats**, predicts with explanation, and **shows if it was right** after the buzzer.

## Core Philosophy: Honest Predictions

The app must **not** be limited to showing a probability before tip-off.

We are **not** building a model that looks infallible.

We are building a model that is **honest, explainable, and useful** — one that earns trust by showing its reasoning and owning its misses.

That means:

- **Before the game:** show the prediction *and* explain the factors behind it
- **After the game:** preserve what we predicted, show the real outcome, and compare both
- **Post-game:** explain why the prediction hit or missed, what drove the result, and what the model can learn

Prediction history and post-game accountability are a **differentiator** vs. apps that only flash probabilities with no explanation and no follow-up.

---

# Completed

## Core App

- [x] Flutter project setup
- [x] Bottom navigation
- [x] Games screen (UI — real API data, RS v1)
- [x] Standings screen
- [x] Teams screen
- [x] Team Detail screen
- [x] About screen
- [x] MatchUp screen (UI — real standings + team stats, v0 win probability)

## API & Data Layer

- [x] EuroLeague API connection (`EuroleagueApiClient`)
- [x] Response caching (`ApiCache`)
- [x] Season configuration (`SeasonConfig`)
- [x] Real standings integration
- [x] Team stats from API (`TeamStatsApiService`)
- [x] Team logos from local assets mapped to API names
- [x] Roster from API (`RosterApiService`)
- [x] Player season stats from API (`PlayerStatsApiService`)
- [x] Player EuroLeague experience from API (`PlayerExperienceApiService`)
- [x] Last 5 form computed from v1 results XML (`RecentFormService`)
- [x] Advanced team metrics calculated locally (`StatsCalculator`)

## Standings

- [x] Automatic latest round detection
- [x] Remove dependency on mock standings in production flow
- [x] Last 5 form fix (API `last5Form` replaced with own computation)
- [x] **Playoff zone UX** — neutral cards + left stripe (green 1–6 playoffs, amber 7–10 play-in), legend, `PLAY-IN` / `OUT` zone dividers (no full-row blue/orange tint)

## MatchUp (session 30/05)

- [x] Real standings + team stats + v0 win probability
- [x] 30 stat cards horizontal scroll (same stats as Teams)
- [x] Post-game preview blocks (mock): Recap, Prediction vs Result, Post Game Analysis
- [x] Game MVP block (mock) with pending/live/final states
- [x] MVP jump chip (scroll to MVP section; Prediction stays on top)
- [x] Expanded MVP stats: STL, BLK, TOV, +/-
- [x] Live score polling on MatchUp screen

## Team Detail

- [x] Replace mock statistics with API data
- [x] Add team record
- [x] Add recent form
- [x] Swipe navigation between teams
- [x] Team roster section with API photos
- [x] "View Team Roster" CTA with scroll anchor

## Teams Screen

- [x] Team comparison with synchronized horizontal scroll
- [x] Section snap (Overview / Performance / Advanced)
- [x] Compact row layout
- [x] Drag & drop reordering
- [x] One-line team names (`TeamNames.listName`)

## Players & Roster

- [x] Team roster in Team Detail (not a global Players tab)
- [x] Player Detail screen
- [x] Player bio (age, height, weight, nationality, born in, last team)
- [x] Player season stats (GP, MIN, PTS, PIR, REB, OREB, DREB, AST, STL, BLK, TOV, FG%, 3P%, FT%)
- [x] EuroLeague experience (seasons + games from `/summary`)
- [x] Player swipe navigation within roster
- [x] Player photos from API (portrait 3:4)

## Navigation & UX

- [x] Team Detail navigation from Standings
- [x] Team Detail navigation from Teams (via standings data)
- [x] Player Detail navigation from roster
- [x] Team name normalization system (`TeamNames`)

## Platform

- [x] Flutter 3.44 upgrade
- [x] Android built-in Kotlin migration

---

# Current Priorities (May 2026)

> **Agreed execution order.** RS + MatchUp prediction loop first; backend when snapshots must be shared across all users.

## Phase 1 — MatchUp real data (now)

- [ ] **Align app name** — store/UI `EuroLeague Insight`; update `main.dart` title (currently `EuroLeague Predictor`)
- [ ] **Game MVP from API** — `games/{gameCode}/stats` (top PIR, box score stats, headshot)
- [ ] **Official result in post-game blocks** — score/winner from API (replace mock where applicable)
- [ ] Define **`PredictionSnapshot`** domain model (local persistence first)
- [ ] MatchUp reads/writes snapshot on first view pre-tip-off

## Phase 2 — Prediction algorithm v1

- [ ] Win probability model beyond v0 (net rating + home court)
- [ ] Explicit **factor breakdown** (form, offense, defense, home court, pace; injuries later)
- [ ] Deterministic output: same inputs → same probabilities
- [ ] Model version tag on every snapshot

## Phase 3 — Generated text + immutability

Three text types, all tied to snapshots:

| Text | When | Mutable? |
|------|------|----------|
| **Pre-game insight** | Before tip-off | **Yes** — only while snapshot is `draft` (e.g. last-minute injury recalc) |
| **Prediction vs result** | After final | **No** — frozen with post-game snapshot |
| **Post game analysis** | After final | **No** — generated once, never edited |

- [ ] v1: template + factor diff (no LLM)
- [ ] v2: **LLM-generated text on server only** (never in the app — API keys must not ship to clients)
- [ ] Snapshot lifecycle: `draft` → `frozen` (tip-off) → `post_game` (analysis attached)
- [ ] Never overwrite probabilities or text after `frozen`

## Phase 4 — Backend (required for production consistency)

> **Not needed for solo dev/beta.** **Required** when all users must see the same % and same published texts.

See [Backend & Cloud Infrastructure](#backend--cloud-infrastructure).

## Phase 5 — Play-In / Playoffs UI

- [ ] Study **NBA app** bracket UX (phase tabs + in-place bracket grid — primary reference)
- [ ] Approve static bracket mockup before any new routes
- [ ] Implement phase tabs inside Games: `[ RS | Play-In | Playoffs | Final Four ]`
- [ ] Defer until RS MatchUp + snapshot pipeline is stable

## Deferred (nice to have)

- [ ] Global **Players** screen — top-10 rankings by stat, player comparison (roster → Player Detail already covers core need; **not essential now**)
- [ ] Pull-to-refresh on Standings / Teams (Games already has it)
- [ ] **Push notifications** — game start, final score, “prediction ready” pre-tip-off (after backend/snapshots)
- [ ] **News feed** — defer; official app + Twitter cover this; we link out or skip entirely
- [ ] **Live alerts** parity with SofaScore — not core; optional gameday notifications only

---

# Growth, Analytics & Community

> **No user registration in v1.** Measure anonymous active users; build community for discovery.

## Analytics (recommended)

| Phase | Tool | Purpose |
|-------|------|---------|
| Beta | Play Console / App Store Connect | Installs, crash-free, basic active devices |
| Beta+ | **Firebase Analytics** (free) | DAU, MAU, retention D1/D7/D30, screen funnels |

**Key events to track:** `app_open`, `view_matchup`, `view_standings`, `view_team_detail`, `mvp_chip_tap`, `prediction_viewed`

**Stickiness metric:** DAU/MAU ≥ 0.15–0.25 = healthy for niche sports app.

## Social media — do you need Twitter/X?

**Not for MVP.** **Yes for launch + growth** in EuroLeague niche (small but passionate).

| Platform | Role | Priority |
|----------|------|----------|
| **X (Twitter)** | Pre-game MatchUp threads, public hit rate, build trust with #EuroLeague community | **High** at launch |
| Reddit (r/Euroleague) | Occasional posts, not spam | Medium |
| Instagram / TikTok | Highlights-style clips — we don’t produce video | Low |
| Official EuroLeague social | They won’t promote us; we engage, not compete | Awareness only |

**Content that fits our brand (stats/scouting):**
- “MatchUp preview: Madrid vs BAR — our model 67% home, key edge: offensive rebounding”
- Post-game: “We had 64% Madrid — they won. Turnovers swung it. Full analysis in app.”
- Weekly: published model hit rate (transparency = marketing)

**No social required** until MatchUp + snapshots are real; then X is the best ROI for zero budget.

---

# Monetization (phased — agreed May 2026)

> **Do not monetize before prediction + snapshots are credible.**

## Phase 1 — Free (now → beta)

- 100% free; focus on product + retention
- Firebase Analytics; prove MatchUp engagement

## Phase 2 — Freemium subscription (primary model)

| Free | Premium (~€2.99/mo or ~€19.99/yr) |
|------|-----------------------------------|
| Games, standings, teams, basic MatchUp | Full factor breakdown |
| Basic win % | Prediction history + public hit rate |
| | Post-game AI analysis |
| | Pre-game alerts (when notifications exist) |

**Avoid:** aggressive ads (hurts scouting/analysis brand). Optional minimal ads only if growth >> revenue need.

## Phase 3 — B2B (parallel, long-term)

- License prediction API to media, fantasy, data partners
- White-label MatchUp widget — more realistic “€1M path” than consumer app sale alone

## What not to do

- Paid app upfront (kills downloads in niche)
- Sell to NBA as Euroliga-only product (wrong buyer)
- Monetize while mocks still visible in MatchUp

---

# Exit & Partnership Strategy

> **€1–2M valuation** is a valid **north star (5–7 years)**, not a realistic v1 sale price. Requires scale beyond Euroliga-only app.

## Realistic valuation ranges (honest)

| Stage | Typical range |
|-------|----------------|
| Working app, no users | €0 – €20k (often no buyer) |
| 5k MAU + ~€2k/mo revenue | €70k – €150k |
| 50k+ MAU + B2B contracts + brand | €200k – €1M+ |

## Likely buyers (not NBA first)

| Buyer | Fit |
|-------|-----|
| **Euroleague Ventures** | Integrate MatchUp + prediction into official app |
| Sports media / streaming | Engagement layer |
| Data / fantasy platforms | Prediction engine license |
| **NBA** | Only if product expands to **NBA Europe** or engine is league-agnostic |

## Path to €1–2M (if it ever happens)

1. Multi-league engine (Euroliga → basket Europe → optional NBA Europe)
2. Backend + canonical snapshots + verifiable hit rate
3. Recurring revenue (subscription + B2B API)
4. 100k+ MAU or €250k+/yr revenue

## Approach (when ready)

Pitch: *“Scouting + prediction layer with proven accuracy — integrate, license, or acquire.”*  
Requires metrics, not just a demo.

---

# Competitive Landscape (May 2026)

| Competitor | Overlap | Our edge | Their edge |
|------------|---------|----------|------------|
| **Euroleague Mobile** (official) | Games, stats, standings | MatchUp, prediction, scouting depth | Brand, video, news |
| **SofaScore / Flashscore** | Live, standings | Euroliga focus, MatchUp, honest prediction | Installed base, alerts, multi-sport |
| **RealGM / Basketball-Reference** | Deep stats (web) | Mobile UX, matchup context | Historical depth |
| **EuroLeague Fantasy** | Same fans | Analysis vs fantasy points | Official game, prizes |
| **HoopLogic / tipster apps** | Win % | Honesty, stats scouting, post-game review | Multi-league, betting UX |

**We win on:** scouting + stats analysis in matchup context, prediction with explanation, post-game accountability.  
**We lose on:** brand, news, video, notifications, “already installed” livescore apps.

See [Competitive Advantage](#competitive-advantage) for positioning summary.

---

# Next Up

## MatchUp — finish real data

- [ ] Replace mock MVP with API (`games/{gameCode}/stats`)
- [ ] Wire post-game blocks to official result + stored snapshot
- [ ] Remove remaining mock dependencies in MatchUp post-game flow

## Games (remaining)

- [x] Real schedule integration (Official EuroLeague API)
- [x] Regular Season only in v1 (`phaseType.code == RS`); architecture ready for Play-In / Playoffs / Final Four later
- [x] **Dynamic round count from API** — never hardcode 34, 38, etc.; derive rounds from fetched schedule
- [x] Upcoming / finished / postponed game states
- [x] Primary round auto-selection (active → complete/stale → next)
- [x] Replace mock data in Games screen
- [x] Round navigation (swipe + selector)
- [x] Game detail screen (basic)
- [x] MatchUp with real team data (v0 model: net rating + home court; snapshot/history TBD)

> **Architecture note:** MatchUp, Game Detail, and the prediction layer must support **Prediction Snapshots** (immutable pre-game records) and **Post Game Analysis** (comparison + narrative after final). See [Prediction Transparency & Traceability](#prediction-transparency--traceability).

## Data freshness & competition structure (cross-cutting)

The competition is expanding (more teams, more RS rounds). The app must **discover structure from the API**, not from fixed constants.

- [x] **No hardcoded round totals** — RS rounds = distinct `round` values in schedule for current `seasonCode`
- [ ] **No hardcoded team count** — standings / rosters / games derive team list from API per season
- [ ] **Season code** — keep `getCurrentSeasonCode()`; invalidate caches when season changes
- [ ] **Aligned refresh policy** across Games, Standings, Teams, Roster, Player stats (see TTL tiers below)
- [x] Pull-to-refresh on main tabs to force `forceRefresh` on critical services (Games)

### Cache TTL tiers (guideline)

| Tier | Data | TTL | When to shorten |
|------|------|-----|-----------------|
| Season structure | Full RS schedule, round list | 2–6 h | Gameday |
| Live | Games with LIVE status, standings mid-round | 1–15 min | While user on Games / Standings |
| Standard | Standings, team stats, rosters | 15 min | After known round completion |
| Stable | Player bio, career summary | 15 min – 24 h | Off-season |

When the league adds teams or rounds, the next fetch automatically picks up the new schedule — no app update required unless new clubs need logo assets locally.

---

# Planned

## Players

> **Priority:** Deferred — not essential for current milestone. Roster → Player Detail already works.

- [ ] Global Players screen / leaderboards *(nice to have)*
- [ ] Top scorers / rebounders / assists — top-10 by stat
- [ ] Player comparison (2–3 players)
- [ ] Drag-and-drop compare UX (mirror Teams screen pattern)

## Teams

- [ ] Team trends
- [ ] Offensive vs Defensive analysis

## Games

- [x] Live score updates (auto-poll Header API every 45s on gameday)
- [ ] Game log / box score in Game Detail
- [ ] Post-game result block in Game Detail (final score, top PIR / MVP)
- [ ] Prediction vs result comparison in Game Detail (when snapshot exists)

### Live play-by-play (future — UX TBD)

The EuroLeague live API exposes play-by-play (`live.euroleague.net/api/PlayByPlay`). Integration is **possible but not prioritized**.

**UX concern:** a full scrolling PBP feed for an entire game is likely **too long and boring** for most users — especially on mobile.

**Preferred direction (if we add it later):**

- **Live:** show only the **last 1–2 plays** as a compact ticker (no infinite scroll during the game)
- **Optional expand:** tap to open full PBP for power users
- **Post-game:** full log belongs in Game Detail / box score, not on the Games list

**Defer until:** live scores and Game Detail post-game blocks are solid. Revisit when designing the live Game Detail layout.

---

# Prediction Transparency & Traceability

> **Status:** Philosophy and architecture direction — **not implemented yet**.
> All new work on Games, Game Detail, and MatchUp should keep this model in mind.

## Why this matters

Most sports apps show win probabilities and move on. EuroLeague Insight should show the full arc:

```
Pre-game prediction → Real outcome → Honest post-game review
```

The user should always be able to answer: *"What did we think, what happened, and why?"*

## Desired user flow

### Before the game — Prediction

Example:

- Team A: **64%**
- Team B: **36%**

With explanation of contributing factors, e.g.:

- Recent form
- Offensive statistics
- Defensive statistics
- Home court advantage
- Other model factors (injuries, pace, matchup edges, etc.)

**Screen:** MatchUp (primary) · Game Detail (summary + link to MatchUp)

### After the game — Result

- Final score
- Top PIR / MVP
- Side-by-side: **prediction vs actual outcome**

**Screen:** Game Detail (primary) · Games list (compact badge: predicted winner ✓/✗)

### Post Game Analysis

Reserved space for a narrative that explains:

- Why the prediction was right or wrong
- Which factors had the most impact on the real result
- Whether there was a statistically significant surprise
- What the model learned from that game (for future transparency, not black-box retraining)

**Screen:** Game Detail (dedicated section, below result block)

## Architecture principles (future)

Design decisions should preserve **traceability** from day one:

| Concept | Purpose |
|---------|---------|
| **Prediction Snapshot** | Immutable record of model output + factor breakdown at prediction time (`gameCode`, `seasonCode`, timestamp, probabilities, factor weights, model version). Never overwrite after tip-off. |
| **Prediction History** | Store and query snapshots across games/seasons for accuracy tracking and user trust. |
| **Outcome Record** | Official result linked to the same `gameCode` (score, winner, MVP/PIR from API). |
| **Prediction vs Result** | Derived comparison: predicted winner, probability assigned, actual winner, Brier/log-loss optional. |
| **Post Game Analysis** | Generated narrative (rules + model-assisted) attached to the snapshot + outcome. |
| **Model Versioning** | Tag every snapshot with model/version ID so comparisons remain fair when the model evolves. |

### Screen responsibilities

| Screen | Pre-game | Post-game |
|--------|----------|-----------|
| **Games** | Indicator that prediction exists for upcoming games | Compact result + prediction hit/miss badge |
| **Game Detail** | Prediction summary + link to full MatchUp | Result, MVP/PIR, prediction comparison, Post Game Analysis |
| **MatchUp** | Full prediction UI + factor breakdown | Read-only snapshot view + link to post-game analysis |

### Data boundary

- **Official EuroLeague API** → facts only (schedule, result, box score, PIR)
- **EuroLeague Insight engine** → predictions, snapshots, explanations, post-game analysis
- Never retroactively change a stored snapshot when new stats arrive; new data informs *future* predictions only

## Roadmap items (future)

- [ ] Define `PredictionSnapshot` domain model (+ status: `draft` | `frozen` | `post_game`)
- [ ] Persist snapshots locally (dev) → **canonical store on backend** (production)
- [ ] MatchUp generates and stores snapshot on first view / before tip-off
- [ ] **Pre-game recalc** only on `draft` snapshots (injuries, late news) — new version, old retained in history
- [ ] **Freeze at tip-off** — cron or game-status trigger; no further probability or pre-game text changes
- [ ] Game Detail: pre-game prediction block
- [ ] Game Detail: post-game result + MVP/PIR block (API)
- [ ] Game Detail: prediction vs result comparison UI
- [ ] Post Game Analysis generation (v1: template; v2: LLM on server)
- [ ] Prediction accuracy dashboard (season-level hit rate, calibration)
- [ ] Games list badges (predicted / result / hit-miss)

### Snapshot immutability rules

```
draft      → probabilities + pre-game insight CAN update (new model run / injury)
frozen     → locked at tip-off; read-only for all users
post_game  → comparison + analysis appended once; permanently read-only
```

Pre-game text and % are **not** retroactively changed after tip-off. Post-game text is **never** edited after publication.

---

# Backend & Cloud Infrastructure

> **Status:** Planned — required for shared predictions and AI text across all app installs.
> **Auth:** No user registration planned for v1 (read-only public API for the app).

## Why a backend?

| Goal | Client-only app | With backend |
|------|-----------------|--------------|
| Same win % for all users | ❌ Each device computes at different times | ✅ Single canonical snapshot |
| Same insight / analysis text | ❌ | ✅ Generated once, served to all |
| Immutable published content | ❌ Local only | ✅ Server is source of truth |
| LLM API keys safe | ❌ Keys in app = exposed | ✅ Keys on server only |
| Tip-off freeze for everyone | ❌ | ✅ One `frozen` event |

**EuroLeague API** remains the source of **facts** (schedule, results, box scores). **Our server** is the source of **predictions, snapshots, and generated text**.

## Recommended architecture

```
┌─────────────────┐     facts      ┌──────────────────────┐
│  EuroLeague API │ ─────────────► │  EuroLeague Insight  │
│  (official)     │                │  Backend             │
└─────────────────┘                │  • fetch + cache     │
                                   │  • run model         │
        ┌──────────────────────────│  • LLM text gen      │
        │  predictions + text      │  • snapshot store    │
        ▼                          └──────────┬───────────┘
┌─────────────────┐                           │
│  Flutter app    │ ◄── GET /predictions/... ─┘
│  (no LLM keys)  │     GET /games/.../insight
└─────────────────┘
```

### App responsibilities (production)

- Display data from **our API** for predictions, insights, and post-game analysis
- May still call EuroLeague API directly for **non-prediction** data (standings, rosters) until fully proxied — or proxy everything later for consistency
- Never embed OpenAI / LLM keys

### Backend responsibilities

- Poll or webhook EuroLeague API on schedule (respect rate limits; central cache)
- Run prediction algorithm on game data
- Store and serve `PredictionSnapshot` records
- Generate pre-game / post-game text (templates v1, LLM v2)
- Freeze snapshots at tip-off; trigger post-game generation on `FINAL`
- Expose read-only HTTP API to the app

## Cloud options (recommended tiers)

> Costs are approximate (2026); verify on provider sites. EuroLeague Insight is low-traffic early on.

### Tier 1 — Start here (MVP backend, ~€0–15/mo)

**Supabase (Postgres + Edge Functions)** or **Firebase (Firestore + Cloud Functions)**

| | Supabase | Firebase |
|---|----------|----------|
| DB | Postgres (snapshots table) | Firestore |
| Compute | Edge Functions (Deno) | Cloud Functions |
| Free tier | Generous for dev | Generous for dev |
| Best for | SQL snapshots, simple queries | Real-time, Google ecosystem |
| Est. prod | ~€10–25/mo low traffic | ~€10–25/mo low traffic |

**Also good:** **Railway** or **Fly.io** — single Docker container (Python/FastAPI or Node) + managed Postgres. ~€5–20/mo.

**Recommendation for this project:** **Supabase + Edge Function** or **Railway + FastAPI** — simple, cheap, Postgres fits snapshot schema well.

### Tier 2 — Growth (~€25–80/mo)

- **Railway / Fly.io** scaled container + Postgres
- Or **AWS**: API Gateway + Lambda + RDS (more setup, pay-per-use)
- Add **Redis** (Upstash) for cache layer if needed

### Tier 3 — Not needed yet

- Kubernetes, multi-region, etc.

## Minimal API surface (v1)

```
GET  /v1/games/{seasonCode}/{gameCode}/prediction     → latest snapshot (draft or frozen or post_game)
GET  /v1/games/{seasonCode}/{gameCode}/prediction/history
POST /v1/internal/snapshots/freeze/{gameCode}         → internal/cron only
POST /v1/internal/snapshots/generate-post-game/{gameCode}  → internal/cron only
```

Public endpoints are **read-only**. Write/freeze/generate endpoints protected by **service API key** (cron job or Cloud Scheduler), not end users.

## Security (no user registration)

No login does **not** mean no security.

### Must implement

| Measure | Purpose |
|---------|---------|
| **HTTPS only** | Encrypt all traffic |
| **Secrets in env** | LLM keys, internal API keys — never in repo or app |
| **App API key** (optional v1) | Simple header `X-App-Key` baked in app — weak alone but blocks casual scraping; rotate per release |
| **Rate limiting** | Per IP / per app key on public endpoints (e.g. 100 req/min) |
| **Read-only public API** | App cannot trigger generation or freeze |
| **Internal endpoints** | Separate key for cron/functions; not exposed to app |
| **Input validation** | gameCode, seasonCode whitelisting |
| **CORS** | Restrict to app if web; mobile uses same API with key |
| **Dependency updates** | Keep runtime and libs patched |
| **Logging + alerts** | Error rates, LLM cost spikes |

### Should implement (before wide release)

| Measure | Purpose |
|---------|---------|
| **Certificate pinning** (mobile) | Mitigate MITM on API calls |
| **Play Integrity / App Attest** | Harder to scrape API with stolen app key |
| **WAF** (Cloudflare in front) | DDoS and bot protection — free tier available |
| **EuroLeague API cache on server** | Single egress IP; respect their ToS/rate limits |

### Not required for v1

- User accounts, OAuth, JWT sessions
- Personal data / GDPR user tables (no registration = minimal PII; still document analytics if added)

### LLM-specific

- Keys **server-side only**
- Rate limit generation (one post-game analysis per game, ever)
- Cap token usage per request
- Log prompts/responses for debugging (no user PII)

## Migration path from current app

1. **Now:** App calls EuroLeague API directly + local v0 predictor + mocks
2. **Dev backend:** Snapshots in Supabase; app fetches prediction for MatchUp; rest unchanged
3. **Production:** Freeze cron; LLM post-game; optionally proxy EuroLeague reads through backend
4. **Optional later:** User accounts only if favorites, sync, or premium — not planned for v1

## Infrastructure checklist

- [ ] Choose provider (Supabase or Railway recommended)
- [ ] Postgres schema: `prediction_snapshots`, `snapshot_history`, `model_versions`
- [ ] Deploy API service (FastAPI / Edge Functions)
- [ ] Cloud Scheduler: tip-off freeze job, post-game generation job
- [ ] Store secrets (Supabase vault / Railway env / GitHub Actions secrets)
- [ ] Rate limiting middleware
- [ ] Flutter: `InsightApiService` pointing to backend for predictions/text
- [ ] Remove LLM keys and prediction logic from client (or keep predictor as fallback offline-only)

---

# Competition

> **UX direction (2026):** Do not build Play-In / Playoffs screens yet. Finalize bracket layout first, then implement when RS + MatchUp prediction loop is stable.
>
> **Reference:** NBA app — phase tabs within competition, bracket grid that updates in place, tap cell → game detail / MatchUp. Primary inspiration for layout.

## Bracket-first design (proposed)

Use a **permanent grid/bracket** that stays on screen and **updates in place** as series progress — rather than a new list screen per round.

### Navigation (future)

Option A — **Phase tabs inside Games** (recommended v1):

```
[ Regular Season ] [ Play-In ] [ Playoffs ] [ Final Four ]
```

Same app shell; only the content below changes. RS keeps current PageView by round; knockout phases use bracket grids.

Option B — dedicated **Competition** tab (later, if bracket grows too rich for Games).

### Play-In grid

Compact **2×2 → 2 → 2** style layout:

| Slot | Content |
|------|---------|
| Cell | Home vs Away logos, seed (7–10), series score or single-game result |
| State | `scheduled` · `live` · `final` |
| Tap | Opens MatchUp for that game/series |

Cells **empty / TBD** until teams are known from standings + API schedule (`phaseType.code == PI`).

### Playoffs grid (Best-of-5)

**Rows = matchups**, **columns = G1 · G2 · G3 · G4 · G5** (or fewer if series ends early).

```
        G1    G2    G3    G4    G5
MAD ── BAR  [W]   [L]   [W]   ·     ·     → MAD 3–1
```

Each mini-cell: winner highlight, score, live dot if playing. Row header: series record + team logos. Tap cell → MatchUp for that game.

Grid is **scrollable horizontally** on mobile if needed; series rows stack vertically.

### Final Four

Single **weekend bracket**: two semifinals + final (+ optional 3rd place). Same cell language as Playoffs but max 3–4 games total.

### Data model (when implementing)

- Reuse `EuroleagueGame` + `GamePhase` (`PI`, `PO`, `FF`) — already in models
- `GamesApiService` filters by phase (today: RS only)
- Bracket layout derived from API games grouped by `round` + `group` + home/road pairing — **never hardcode pairings**
- Primary view = **current active series/game** (same philosophy as RS primary round)

### What NOT to do yet

- No new routes/screens until bracket mockups are approved
- No duplicate schedule lists for PO — the grid *is* the schedule
- PBP stays out of bracket; live scores via existing Header polling on active cells only

---

## Play-In

- [ ] Play-In screen
- [ ] Play-In predictions

## Playoffs

- [ ] Playoff bracket
- [ ] Series tracker
- [ ] Series predictions

## Final Four

- [ ] Final Four screen
- [ ] MVP tracking
- [ ] Final predictions

---

# Insights Engine

Grounded in [Prediction Transparency & Traceability](#prediction-transparency--traceability): every prediction must be explainable before the game and reviewable after it.

## Version 1

- [ ] Win probability model (v1 — factor breakdown; v0 net rating + home court done in app)
- [ ] Team power ranking
- [ ] Form score
- [ ] Factor breakdown for MatchUp (form, offense, defense, home court, …)
- [ ] **Prediction Snapshot** — store pre-game output per `gameCode` (`draft` → `frozen`)
- [ ] Pre-game insight text (template v1; LLM v2 on server)
- [ ] Research and integrate Giasemidis EuroLeague API

## Version 2

- [ ] Matchup advantage score
- [ ] Injury impact score (+ trigger `draft` snapshot recalc pre-tip-off)
- [ ] Home court impact (refined)
- [ ] **Prediction vs result comparison** in Game Detail + MatchUp
- [ ] Model accuracy tracking (hit rate, calibration over season)
- [ ] **Backend canonical snapshots** — same output for all users

## Version 3

- [ ] Team cohesion score
- [ ] Defensive presence score
- [ ] Clutch performance score
- [ ] **Post Game Analysis** — LLM narrative on server; immutable after publish
- [ ] **Model learning transparency** — surface what changed after significant upsets

---

# Long-Term Vision

EuroLeague Insight becomes an analysis platform rather than a statistics viewer.

```
Data
  ↓
Analysis
  ↓
Prediction (+ explanation)
  ↓
Outcome (official result)
  ↓
Prediction vs Result (+ Post Game Analysis)
  ↓
Insights & model transparency
```

## Guiding Principle

The official EuroLeague app already provides results and standings.

EuroLeague Insight should focus on:

- Understanding
- Context
- Prediction **with explanation**
- **Accountability after the game**
- Decision support

Not just displaying raw statistics — and not pretending the model is always right.

---

# Data Sources & Architecture

## Primary Source

### Official EuroLeague API

Official Website:

https://www.euroleaguebasketball.net/

API Base URL:

https://api-live.euroleague.net/

Status:

- [x] Active

Purpose:

- Standings
- Games
- Schedule
- Teams
- Logos
- Play-In
- Playoffs
- Final Four
- Official competition data

Current implementation:

- Standings (v2)
- Team club stats (v2)
- Team rosters (v2)
- Player season stats (v2)
- Player career summary (v2)
- Last 5 form (computed from v1 results XML)
- Team logos (local assets mapped to API names)

All main screens use real API data. Prediction snapshots and full Insights Engine model remain planned.

Priority:

HIGH

Notes:

This should be the primary source of truth for all official competition data.
MatchUp and the Insights Engine layer predictions on top — see [Prediction Transparency & Traceability](#prediction-transparency--traceability).

---

## Secondary Source

### Giasemidis EuroLeague API

Repository:

https://github.com/giasemidis/euroleague_api

Language:

Python

Status:

- [ ] Research phase

Purpose:

- Advanced statistics
- Historical data
- Team analytics
- Player analytics
- Predictive modelling
- Insights Engine

Potential future uses:

- Win probability model
- Team strength model
- Player impact model
- Matchup analysis
- Momentum indicators

Priority:

HIGH

Notes:

Potential cornerstone of the future Insights Engine.

---

## Research Source

### euroleaguer (R Package)

Repository:

https://github.com/FlavioLeccese92/euroleaguer

Language:

R

Status:

- [ ] Research phase

Purpose:

- Discover EuroLeague endpoints
- Competition metadata
- Rounds metadata
- Games metadata
- API reverse engineering

Interesting functions:

- getCompetitionRounds()
- getCompetitionGames()
- getGameRound()
- getPlayerStats()
- getTeamStats()

Priority:

MEDIUM

Notes:

Useful for understanding how EuroLeague data is structured and discovering additional endpoints.

---

## Future Sources

### Injury Data

Status:

- [ ] Not selected

Potential uses:

- Injury impact score
- Availability tracking
- Prediction adjustments

---

### Betting Markets

Status:

- [ ] Future research

Potential uses:

- Market comparison
- Prediction validation
- Consensus probability

---

## Proprietary EuroLeague Insight Metrics

Future internal indicators:

- Form Score
- Momentum Score
- Team Cohesion Score
- Matchup Advantage Score
- Defensive Presence Score
- Clutch Performance Score
- Home Court Impact Score
- Injury Impact Score

---

## Data Architecture

Official EuroLeague API
↓
Competition Data

Giasemidis EuroLeague API
↓
Advanced Analytics

EuroLeague Insight Engine
↓
Proprietary Indicators

Result:
↓
Predictions & Insights

---

## Guiding Data Principle

Use the best source for each data type.

Official API:
- Facts
- Results
- Standings
- Schedule

Analytics Repositories:
- Context
- Advanced metrics
- Historical trends

EuroLeague Insight:
- Interpretation
- Prediction **with explanation**
- **Post-game accountability**
- Decision support

---

# Source Responsibility Matrix

| Data Type | Source | Status |
|------------|--------|--------|
| Standings | Official EuroLeague API | Live |
| Teams | Official EuroLeague API | Live |
| Logos | Local assets (mapped to API names) | Live |
| Team season stats | Official EuroLeague API + local calculations | Live |
| Roster | Official EuroLeague API | Live |
| Player season stats | Official EuroLeague API | Live |
| Player EuroLeague experience | Official EuroLeague API | Live |
| Last 5 form | EuroLeague Insight (v1 results XML) | Live |
| Games / Schedule | Official EuroLeague API | Live |
| Playoffs | Official EuroLeague API | Planned |
| Final Four | Official EuroLeague API | Planned |
| Team Advanced Stats (extended) | Giasemidis API | Research |
| Player Advanced Stats (extended) | Giasemidis API | Research |
| Historical Analytics | Giasemidis API | Research |
| Competition Metadata | euroleaguer | Research |
| Rounds Metadata | euroleaguer | Research |
| Predictions | EuroLeague Insight | Planned |
| Prediction Snapshots (pre-game) | EuroLeague Insight Backend | Planned |
| Prediction History | EuroLeague Insight Backend | Planned |
| Pre-game insight text | EuroLeague Insight Backend (LLM v2) | Planned |
| Post Game Analysis | EuroLeague Insight Backend (LLM v2) | Planned |
| Prediction vs Result | EuroLeague Insight (derived) | Planned |
| Power Rankings | EuroLeague Insight | Planned |
| Form Score | EuroLeague Insight | Planned |
| Momentum Score | EuroLeague Insight | Planned |
| Matchup Analysis | EuroLeague Insight | Planned |
| Win Probability | EuroLeague Insight | Planned |

---

# Competitive Advantage

Official EuroLeague App:
- Results
- Standings
- News

Typical third-party apps:
- Win probabilities
- No explanation
- No follow-up after the game

EuroLeague Insight:
- **Scouting & statistical analysis** (teams, players, 30-stat MatchUp)
- Analysis and context over raw data dumps
- Predictions **with factor breakdown**
- **Prediction history and post-game review**
- **Honest model transparency**
- Decision support for fans who want to *understand*, not just check scores

Goal:

Do not compete on raw data or news.

Compete on **scouting, stats interpretation, explanation, and accountability**.

**Strengths today:** MatchUp concept, Teams compare, Standings zones, roster/player depth.  
**Gaps today:** mocks in post-game, simple v0 model, no backend, no notifications, no brand/community.