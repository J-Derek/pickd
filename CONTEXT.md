# CONTEXT.md — Pickd Shared Language

> This document is the single source of truth for all terminology used in the Pickd project.
> Every agent, developer, and document must use these terms consistently.

---

## Project Identity

| Term | Definition |
|---|---|
| **Pickd** | The app name. Stylized lowercase "pickd" in UI contexts. Solves streaming decision fatigue. |
| **MVP** | Solo mode, no auth required, local Hive storage, TMDB + YouTube APIs, mood check-in, taste profiling, trailer swiping, hidden gems. No multiplayer, no JustWatch, no backend. |
| **V2** | Multiplayer swiping (partner match), JustWatch affiliate integration, user accounts, social features. |

---

## Core Features

| Feature | What It Means |
|---|---|
| **Mood Check-In** | The onboarding flow where the user selects their current emotional state. Maps moods to TMDB genres and keyword filters. |
| **Taste Profile** | A local record of the user's favourite movies (entered manually, min 3, max 10). Used to seed the recommendation engine via TMDB's `/movie/{id}/recommendations` and `/movie/{id}/similar` endpoints. |
| **Swipe Deck** | The core Tinder-style card stack UI. Each card = one movie or series. Swipe right = save to watchlist. Swipe left = skip. Tap = open detail with trailer. |
| **Trailer View** | Full-screen YouTube player opened on card tap. Tap-to-play only. Uses TMDB `/movie/{id}/videos` to get the YouTube key, then launches via `url_launcher` or embedded `youtube_player_flutter`. |
| **Hidden Gems Mode** | A filter toggle. When ON, only shows content where `popularity < 30` AND `release_date < 2020-01-01`. Excludes franchise sequels where possible. |
| **Watchlist** | Locally stored (Hive) list of right-swiped movies. Persists across sessions. No sync until auth. |
| **Swipe Session** | One uninterrupted round of swiping. Tracks how many swipes have occurred for the delayed auth trigger. |

---

## User & Auth Concepts

| Term | Definition |
|---|---|
| **Guest User** | Any user before sign-up. All data stored locally in Hive. |
| **Swipe Gate** | The moment after 5 swipes when the app prompts sign-up. Non-blocking — user can dismiss and continue as guest. |
| **Local Profile** | The Hive-stored object containing: taste profile movies, watchlist, mood history, swipe count, and app preferences. |
| **Delayed Auth** | Our auth strategy. Don't ask for sign-up upfront. Let the user experience value first, then prompt after the Swipe Gate. |

---

## Data & API Concepts

| Term | Definition |
|---|---|
| **TMDB** | The Movie Database API (api.themoviedb.org/3). Primary data source for all movie/series metadata, genres, recommendations, and video links. |
| **YouTube Key** | The `key` field from TMDB's video endpoint. Used to construct the YouTube URL `https://www.youtube.com/watch?v={key}`. |
| **Popularity Score** | TMDB's internal float field (`popularity`). Higher = more mainstream. Hidden Gems filter uses `popularity < 30`. |
| **Hidden Gem Threshold** | `popularity < 30` AND `release_date.year < 2020`. Defined here, applied in the discovery service. |
| **Mood-to-Genre Map** | A hardcoded lookup table mapping user mood selections to TMDB genre IDs and optional keywords. Lives in `mood_config.dart`. |
| **Recommendation Seed** | The set of TMDB movie IDs from the user's taste profile that are used to generate the swipe deck. |
| **JustWatch** | V2 only. Affiliate platform for streaming service deep links. Not in MVP. |

---

## UI/UX Concepts

| Term | Definition |
|---|---|
| **Card Stack** | The visual representation of the Swipe Deck. Top card is always the active card. |
| **Card Peek** | The visual treatment of the next 1-2 cards behind the active card, slightly scaled down and offset. |
| **Swipe Indicator** | The "WATCH" (right) and "SKIP" (left) overlay text that appears on the card as the user drags. |
| **Vibe Tags** | Short descriptive tags shown on each movie card (e.g. "Slow Burn", "Mind-Bending", "Feel Good"). Derived from TMDB keywords. |
| **Genre Chips** | Compact UI chips showing genre labels on movie cards. |
| **Cinematic Mode** | The full-screen detail view that opens when tapping a card. Shows poster, synopsis, vibe tags, trailer button, and watchlist action. |

---

## Flutter/Architecture Concepts

| Term | Definition |
|---|---|
| **Feature-First Structure** | Our folder structure. Each feature (mood, swipe, watchlist, gems, profile) has its own folder with screens/, widgets/, models/, services/. |
| **Hive Box** | A Hive data container. We have boxes for: userProfile, watchlist, swipeHistory, preferences. |
| **Discovery Service** | The class responsible for calling TMDB, applying filters (mood, hidden gem threshold, taste seeds), and returning a curated list of movies for the swipe deck. |
| **Riverpod** | State management library. All state flows through Riverpod providers. No setState outside of trivial local widget state. |
| **go_router** | Navigation library. Handles all app routing declaratively. |

---

## Moods (MVP Set)

| Mood Label | TMDB Genres Mapped | Vibe |
|---|---|---|
| Fun & Silly | Comedy (35) | Light, no-brainer |
| On the Edge | Thriller (53), Horror (27) | Tense, heart-pumping |
| Emotional | Drama (18), Romance (10749) | Feel-something |
| Mind-Bending | Sci-Fi (878), Mystery (9648) | Think-hard |
| Epic & Action | Action (28), Adventure (12) | Hype, spectacle |
| Something Different | Documentary (99), Foreign (10769) | Expand horizons |

---

## What We Are NOT Building in MVP

- Multiplayer / partner swiping
- JustWatch streaming availability
- Social features (following, shared lists)
- Push notifications
- In-app purchases or subscriptions
- Backend server (everything is local + direct API calls)
- Web or desktop versions
