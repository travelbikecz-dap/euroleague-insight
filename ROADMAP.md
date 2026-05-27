# EuroLeague Insight Roadmap

## Vision

EuroLeague Insight should not only display data.

It should help users understand:

- Who is likely to win
- Why
- Which factors matter most

Combining:

- Team statistics
- Player statistics
- Form
- Injuries
- Advanced metrics
- Proprietary indicators

---

# Completed

## Core App

- [x] Flutter project setup
- [x] Bottom navigation
- [x] Games screen
- [x] Standings screen
- [x] Teams screen
- [x] Team Detail screen
- [x] About screen

## API

- [x] EuroLeague API connection
- [x] Real standings integration
- [x] Team logo loading from API

## Navigation

- [x] Team Detail navigation from Standings
- [x] Team name normalization system

---

# In Progress

## Standings

- [x] Automatic latest round detection
- [ ] Remove dependency on mock standings

## Team Detail

- [ ] Replace mock statistics with API data
- [ ] Add team record
- [ ] Add recent form

---

# Planned

## Players

- [ ] Players screen
- [ ] Top scorers
- [ ] Top rebounders
- [ ] Top assists
- [ ] Player comparison

## Games

- [ ] Real schedule integration
- [ ] Upcoming games
- [ ] Finished games
- [ ] Game detail screen

## Teams

- [ ] Team comparison
- [ ] Team trends
- [ ] Offensive vs Defensive analysis

---

# Competition

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

## Version 1

- [ ] Win probability model
- [ ] Team power ranking
- [ ] Form score
- [ ] Research and integrate Giasemidis EuroLeague API

## Version 2

- [ ] Matchup advantage score
- [ ] Injury impact score
- [ ] Home court impact

## Version 3

- [ ] Team cohesion score
- [ ] Defensive presence score
- [ ] Clutch performance score

---

# Long-Term Vision

EuroLeague Insight becomes an analysis platform rather than a statistics viewer.

Data
↓
Analysis
↓
Prediction
↓
Insights


## Guiding Principle

The official EuroLeague app already provides results and standings.

EuroLeague Insight should focus on:

- Understanding
- Context
- Prediction
- Decision support

Not just displaying raw statistics.

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

- Real standings integration
- Team logos
- Competition data

Priority:

HIGH

Notes:

This should be the primary source of truth for all official competition data.

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
- Prediction
- Decision support

---

# Source Responsibility Matrix

| Data Type | Source |
|------------|------------|
| Standings | Official EuroLeague API |
| Teams | Official EuroLeague API |
| Logos | Official EuroLeague API |
| Games | Official EuroLeague API |
| Schedule | Official EuroLeague API |
| Playoffs | Official EuroLeague API |
| Final Four | Official EuroLeague API |
| Team Advanced Stats | Giasemidis API |
| Player Advanced Stats | Giasemidis API |
| Historical Analytics | Giasemidis API |
| Competition Metadata | euroleaguer |
| Rounds Metadata | euroleaguer |
| Predictions | EuroLeague Insight |
| Power Rankings | EuroLeague Insight |
| Momentum Score | EuroLeague Insight |
| Matchup Analysis | EuroLeague Insight |
| Win Probability | EuroLeague Insight |

---

# Competitive Advantage

Official EuroLeague App:
- Results
- Standings
- News

EuroLeague Insight:
- Analysis
- Context
- Predictions
- Decision Support

Goal:

Do not compete on data.

Compete on interpretation.