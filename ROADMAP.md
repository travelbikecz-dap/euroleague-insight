# EuroLeague Insight Roadmap

## Vision

EuroLeague Insight should not only display data.

It should help users understand:

- Who is likely to win
- Why
- Which factors matter most
- **What actually happened — and how that compares to what we predicted**

Combining:

- Team statistics
- Player statistics
- Form
- Injuries
- Advanced metrics
- Proprietary indicators

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

# Next Up

## Games (priority)

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

- [ ] Global Players screen / leaderboards
- [ ] Top scorers
- [ ] Top rebounders
- [ ] Top assists
- [ ] Player comparison

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

- [ ] Define `PredictionSnapshot` domain model
- [ ] Persist snapshots locally (later: optional sync)
- [ ] MatchUp generates and stores snapshot on first view / before tip-off
- [ ] Game Detail: pre-game prediction block
- [ ] Game Detail: post-game result + MVP/PIR block
- [ ] Game Detail: prediction vs result comparison UI
- [ ] Post Game Analysis generation (v1: template + factor diff; v2: richer narrative)
- [ ] Prediction accuracy dashboard (season-level hit rate, calibration)
- [ ] Games list badges (predicted / result / hit-miss)

---

# Competition

> **UX direction (2026):** Do not build Play-In / Playoffs screens yet. Finalize bracket layout first, then implement when RS + MatchUp prediction loop is stable.

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

- [ ] Win probability model
- [ ] Team power ranking
- [ ] Form score
- [ ] Factor breakdown for MatchUp (form, offense, defense, home court, …)
- [ ] **Prediction Snapshot** — store pre-game output per `gameCode` (immutable)
- [ ] Research and integrate Giasemidis EuroLeague API

## Version 2

- [ ] Matchup advantage score
- [ ] Injury impact score
- [ ] Home court impact
- [ ] **Prediction vs result comparison** in Game Detail
- [ ] Model accuracy tracking (hit rate, calibration over season)

## Version 3

- [ ] Team cohesion score
- [ ] Defensive presence score
- [ ] Clutch performance score
- [ ] **Post Game Analysis** — narrative explaining hit/miss and key drivers
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
| Prediction Snapshots (pre-game) | EuroLeague Insight | Planned |
| Prediction History | EuroLeague Insight | Planned |
| Post Game Analysis | EuroLeague Insight | Planned |
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
- Analysis
- Context
- Predictions **with factor breakdown**
- **Prediction history and post-game review**
- **Honest model transparency**
- Decision support

Goal:

Do not compete on raw data.

Compete on **interpretation, explanation, and accountability**.