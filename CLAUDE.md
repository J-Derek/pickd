# CLAUDE.md — Pickd Project Primer

> Read this first. Every time. Before touching a single file.
> This is the single source of truth for Claude Code to understand Pickd instantly.

---

## What is Pickd?

**Pickd** is a mood-based movie & TV discovery app for mobile (Android-first).
It solves streaming decision fatigue by combining a Tinder-style swipe UI with a
mood-driven recommendation engine powered by TMDB.

**Core loop:** Select mood → build taste profile → swipe cards → save to watchlist → watch trailer.

**Tagline:** *Stop scrolling. Start watching.*

---

## Current Status

| Phase | Status |
|---|---|
| MVP (v1.0) | Shipped — feature-complete, tested on physical Android device (Tecno BG7) |
| v1.1 | In progress — see V1.2 Features section below |
| V2 (multiplayer, auth, backend) | Not started — out of scope until V2 |

---

## Full Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart 3, SDK >=3.0.0 <4.0.0) |
| **State Management** | Riverpod 2.x (flutter_riverpod, riverpod_annotation, riverpod_generator) |
| **Navigation** | go_router ^14.0.0 |
| **HTTP Client** | dio ^5.4.3+1 |
| **Local Storage** | hive ^2.2.3 + hive_flutter ^1.1.0 |
| **Remote/Auth** | supabase_flutter ^2.16.0 (wired in, auth not yet enforced in MVP) |
| **Primary Data API** | TMDB (https://api.themoviedb.org/3) — Bearer token auth |
| **Video** | TMDB /videos endpoint -> YouTube key -> url_launcher (no YouTube API calls) |
| **UI Packages** | flutter_card_swiper ^7.0.1, cached_network_image, shimmer, google_fonts, lucide_icons |
| **Code Gen** | build_runner, freezed, json_serializable, hive_generator |
| **Target Platforms** | Android (primary), iOS (secondary), Windows (dev only) |

---

## Folder Structure

```
lib/
├── main.dart                        # Entry point — Hive init, ProviderScope, runApp
├── app.dart                         # MaterialApp.router, go_router config, AppTheme
│
├── core/
│   ├── config/
│   │   ├── app_theme.dart           # Full ThemeData — ALWAYS use tokens from DESIGN.md
│   │   ├── mood_config.dart         # Mood enum -> TMDB genre IDs + keyword map
│   │   └── env.dart                 # API keys via String.fromEnvironment()
│   ├── constants/
│   │   └── api_constants.dart       # TMDB base URL, image CDN paths
│   ├── models/
│   │   ├── movie.dart               # Movie/Series model (TMDB shape), Hive typeId: 0
│   │   ├── mood.dart                # Mood enum + display metadata
│   │   └── user_profile.dart        # Local profile model, Hive typeId: 1
│   ├── services/
│   │   ├── tmdb_service.dart        # All TMDB API calls (see API Layer section)
│   │   ├── discovery_service.dart   # Recommendation engine — builds swipe deck
│   │   └── hive_service.dart        # Hive box init + CRUD helpers
│   └── widgets/
│       ├── genre_chip.dart          # Reusable genre chip
│       ├── vibe_tag.dart            # Vibe tag chip (from TMDB keywords)
│       ├── rating_badge.dart        # TMDB rating display
│       └── shimmer_loader.dart      # Skeleton loader
│
└── features/
    ├── onboarding/                  # Mood selection + taste profile screens
    ├── swipe/                       # Core swipe deck experience
    ├── detail/                      # Cinematic Mode — full movie detail + trailer
    ├── watchlist/                   # Right-swiped movies, Hive-persisted
    ├── gems/                        # Hidden Gems mode (popularity < 30, pre-2020)
    ├── profile/                     # Stats, settings, watched vault
    ├── auth/                        # Auth screen (Supabase, accessed from profile/swipe gate)
    └── shell/                       # MainShell — bottom nav, PopScope back handler
```

Each feature follows this internal structure:
```
features/<feature>/
├── screens/      # Full-page screens
├── widgets/      # Feature-specific components
├── providers/    # Riverpod providers/notifiers for this feature
└── models/       # Feature-specific models (if needed)
```

---

## Navigation Routes (go_router)

```
/                        -> SplashScreen
/onboarding/mood         -> MoodSelectionScreen
/onboarding/taste        -> TasteProfileScreen
/swipe                   -> SwipeScreen (MainShell)
/movie/:id               -> MovieDetailScreen
/watchlist               -> WatchlistScreen
/gems                    -> GemsScreen
/profile                 -> ProfileScreen
/auth                    -> AuthScreen
```

---

## Key Architectural Decisions (Already Made — Do Not Revisit)

| Decision | What Was Chosen | Why |
|---|---|---|
| Architecture pattern | Clean Architecture, feature-first folders | Scalable, separates concerns |
| State management | Riverpod 2.x only | No setState outside trivial local widget state |
| Navigation | go_router declarative routing | Predictable, deep-link ready |
| Local storage | Hive (not SQLite/SharedPreferences) | No migrations needed for MVP, fast |
| Auth strategy | Delayed auth — swipe gate at 5 swipes | Reduces friction, value-first UX |
| YouTube integration | TMDB /videos -> url_launcher (no YouTube Data API) | Free, avoids quota costs |
| Swipe implementation | flutter_card_swiper package | Battle-tested physics, saves weeks |
| API secrets | Compile-time --dart-define=TMDB_TOKEN=xxx | Never hardcoded in source |
| Icons | lucide_icons package | Replaced Material icons in MVP polish pass |
| Backend | None in MVP | Supabase is wired in but auth is not enforced yet |

---

## State Management Reference (Riverpod)

| Provider | Type | Responsibility |
|---|---|---|
| onboardingProvider | StateNotifier | Selected mood, taste movies, onboarding step |
| swipeDeckProvider | AsyncNotifier | Current deck of movies, loading state |
| swipeSessionProvider | StateNotifier | Swipe count, swipe gate trigger |
| watchlistProvider | StateNotifier | Watchlist CRUD, synced to Hive |
| gemsModeProvider | StateProvider<bool> | Hidden gems toggle |
| userProfileProvider | StateNotifier | Local profile read/write |

---

## Local Storage (Hive Boxes)

| Box | Type | Contents |
|---|---|---|
| userProfile | UserProfileModel (typeId: 1) | Taste seeds, selected mood, swipe count, allowOldMovies |
| swipeHistoryV2 | Map<String, String> (JSON) | Swiped media keys (`movie_123`, `tv_456`) mapped to action & full metadata |
| recentSearches | String | Recently searched titles |

---

## API Layer (TMDB Service)

Base URL: https://api.themoviedb.org/3
Auth: Authorization: Bearer {TMDB_READ_ACCESS_TOKEN} (compile-time dart-define)
Client: dio with logging interceptor (debug only), _CacheInterceptor (bounded LRU memory cache, max 200)

| Method | Endpoint | Used For |
|---|---|---|
| searchMulti(query) | /search/multi | Taste profile search (movies & TV) |
| getMovieDetails(id) | /movie/{id} | Full movie detail + watch/providers |
| getTvDetails(id) | /tv/{id} | Full TV detail + watch/providers |
| getRecommendations(id) | /movie/{id}/recommendations | Seed-based movie deck building |
| getTvRecommendations(id) | /tv/{id}/recommendations | Seed-based TV deck building |
| discoverMovies(params) | /discover/movie | Mood/genre/gems filtered movie discovery |
| discoverTv(params) | /discover/tv | Mood/genre/gems filtered TV discovery |
| getMovieVideos(id) | /movie/{id}/videos | YouTube trailer key |
| getTvVideos(id) | /tv/{id}/videos | YouTube trailer key |

---

## Discovery Engine Logic

discovery_service.dart -> buildDeck(...):

1. Run movie and TV recommendation pipelines based on selected `MediaFilter` (moviesOnly, tvOnly, both)
2. Fetch seed-based recommendations & discover queries (with `vote_average.desc` for gems mode)
3. Interleave movie & TV items
4. Deduplicate results by `mediaKey` (`movie_100` vs `tv_100`)
5. Filter out already-swiped `mediaKey` items (from local Hive + Supabase)
6. If gemsMode = true: filter popularity < `Env.hiddenGemMaxPopularity` AND releaseYear < `Env.hiddenGemMaxYear`
7. Return max 30 items per deck

---

## Mood -> Genre Mapping (mood_config.dart)

| Mood | TMDB Genre IDs |
|---|---|
| Fun & Silly | Comedy (35) |
| On the Edge | Thriller (53), Horror (27) |
| Emotional | Drama (18), Romance (10749) |
| Mind-Bending | Sci-Fi (878), Mystery (9648) |
| Epic & Action | Action (28), Adventure (12) |
| Something Different | Documentary (99), Foreign (10769) |

---

## Design System (From DESIGN.md)

**Theme:** Dark mode by default. Cinematic and premium.

**Fonts:**
- Display/Headlines: Syne (600, 700, 800)
- Body/UI: Inter (400, 600)
- Loaded via google_fonts package

**Key Colors:**
- Background: #0e1417
- Primary Accent: #00d1ff (Electric Cyan)
- Primary Text: #dde3e7
- Secondary Text: #bbc9cf

**Glassmorphism** (used on overlays/cards):
- Background: rgba(22, 29, 31, 0.4)
- Blur: BackdropFilter(filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32))
- Border: 1px solid rgba(255, 255, 255, 0.05)

**Spacing grid:** 8px base. Container margin mobile: 20px.
**Border radii:** Cards/sheets: 12px | Buttons/inputs: 8px | Pills: 9999px

All theme tokens live in lib/core/config/app_theme.dart. Never hardcode colors or fonts inline.

---

## What Is NOT In Scope (MVP Guardrails)

Do not build, suggest, or scaffold any of the following unless explicitly told:

- NO: Multiplayer / partner swiping
- NO: JustWatch streaming availability integration
- NO: Social features (following, shared lists)
- NO: Push notifications
- NO: In-app purchases
- NO: A backend server (Supabase auth exists but is not yet enforced)
- NO: Web or desktop targets
- NO: YouTube Data API v3 (TMDB /videos is sufficient)

---

## V1.1 / V1.2 — Currently In Progress

These features are the active workstream. When in doubt, work on these:

- [ ] TV Series Integration — Expand Movie model and TMDB service to handle /tv endpoints. Add MediaType enum (movie | tv). Filter toggle UI: Movies | Both | TV Shows (3-segment pill on SwipeScreen).
- [ ] Swipe Up -> Watched Vault — Swipe up gesture marks as "Watched", triggers 5-star rating dialog, saves to a new watchedVault Hive box. New screen: WatchedVaultScreen (GridView with star badge on each poster).
- [ ] Profile Screen — Stats section (total watched, total saved), watched vault CTA, Supabase auth connect/sign-out.
- [ ] "Allow Classics" Setting — Toggle in SettingsSheet on Profile: when ON, removes the year < 2020 guard from Hidden Gems and allows pre-1990 films.
- [ ] Streaming Providers on Detail — Show provider logo row on MovieDetailScreen using TMDB /movie/{id}/watch/providers. Display only, no deep links yet.

---

## Conventions & Rules

### File Naming

| Type | Convention | Example |
|---|---|---|
| Dart source files | snake_case | swipe_provider.dart |
| Markdown docs | kebab-case | v1-2-features.md |
| Assets/images | snake_case | empty_state_gems.png |

### Code Rules

- Never use setState outside trivial local widget state — all state goes through Riverpod
- No hardcoded colors, fonts, or spacing — always reference AppTheme tokens
- No hardcoded API keys — all secrets via String.fromEnvironment()
- Run build_runner after editing any @freezed, @riverpod, or @HiveType annotated files:
  dart run build_runner build --delete-conflicting-outputs
- Run the app via --dart-define for API keys:
  flutter run --dart-define=TMDB_TOKEN=your_token_here

### Git Rules

HARD RULE: NEVER commit directly to main. Ever.

Branch structure:
  main          -> production-ready only
    dev         -> active development base
      feature/<name>    -> one feature at a time
      fix/<bug-name>    -> bug fixes
      refactor/<what>   -> refactors

Always branch off dev:
  git checkout dev
  git checkout -b feature/tv-series-integration

Merge back to dev when done. Only dev -> main when stable and reviewed.

---

## Quick Reference: Where Things Live

| What you need | Where to look |
|---|---|
| Project terminology | CONTEXT.md |
| System architecture & data flow | ARCHITECTURE.md |
| Colors, fonts, spacing tokens | DESIGN.md |
| What is in progress | This file, V1.2 section above |
| Past decisions & what shipped | HANDOFF.md |
| App routing | lib/app.dart |
| Theme tokens | lib/core/config/app_theme.dart |
| TMDB calls | lib/core/services/tmdb_service.dart |
| Recommendation logic | lib/core/services/discovery_service.dart |
| Swipe state | lib/features/swipe/providers/swipe_provider.dart |
| Watchlist state | lib/features/watchlist/providers/watchlist_provider.dart |
