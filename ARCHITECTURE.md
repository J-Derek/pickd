# ARCHITECTURE.md — Pickd System Architecture

> Flutter + TMDB API + YouTube API. No backend. All local. MVP only.

---

## Architecture Pattern

**Clean Architecture** with feature-first folder structure.  
State management: **Riverpod** (providers, notifiers).  
Navigation: **go_router**.  
Local storage: **Hive**.  
No backend. All API calls are direct client-to-API.

---

## Folder Structure

```
lib/
├── main.dart                      # App entry, Hive init, ProviderScope
├── app.dart                       # MaterialApp.router, go_router config, theme
│
├── core/
│   ├── config/
│   │   ├── app_theme.dart         # Full ThemeData from DESIGN.md tokens
│   │   ├── mood_config.dart       # Mood → TMDB genre/keyword map
│   │   └── env.dart               # API keys (loaded from .env or compile-time)
│   ├── constants/
│   │   └── api_constants.dart     # Base URLs, image CDN paths
│   ├── models/
│   │   ├── movie.dart             # Movie/Series model (TMDB response)
│   │   ├── mood.dart              # Mood enum + metadata
│   │   └── user_profile.dart      # Local profile (Hive)
│   ├── services/
│   │   ├── tmdb_service.dart      # All TMDB API calls
│   │   ├── discovery_service.dart # Recommendation engine logic
│   │   └── hive_service.dart      # Hive box init + CRUD helpers
│   └── widgets/
│       ├── genre_chip.dart        # Reusable genre chip
│       ├── vibe_tag.dart          # Vibe tag chip
│       ├── rating_badge.dart      # TMDB rating display
│       └── shimmer_loader.dart    # Loading skeleton

├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── mood_selection_screen.dart
│   │   │   └── taste_profile_screen.dart
│   │   ├── widgets/
│   │   │   ├── mood_card.dart
│   │   │   └── movie_search_tile.dart
│   │   └── providers/
│   │       └── onboarding_provider.dart
│   │
│   ├── swipe/
│   │   ├── screens/
│   │   │   └── swipe_screen.dart
│   │   ├── widgets/
│   │   │   ├── swipe_card.dart        # Core card widget
│   │   │   ├── card_stack.dart        # Stack of 3 cards
│   │   │   ├── swipe_indicator.dart   # WATCH/SKIP overlay
│   │   │   └── action_buttons.dart    # Skip/Watch FAB row
│   │   └── providers/
│   │       └── swipe_provider.dart
│   │
│   ├── detail/
│   │   ├── screens/
│   │   │   └── movie_detail_screen.dart  # Cinematic Mode
│   │   └── widgets/
│   │       ├── trailer_button.dart
│   │       └── detail_backdrop.dart
│   │
│   ├── watchlist/
│   │   ├── screens/
│   │   │   └── watchlist_screen.dart
│   │   └── providers/
│   │       └── watchlist_provider.dart
│   │
│   └── gems/
│       ├── screens/
│       │   └── gems_screen.dart      # Hidden Gems swipe mode
│       └── providers/
│           └── gems_provider.dart
```

---

## Data Flow

```
User selects Mood
       │
       ▼
MoodSelectionScreen → onboarding_provider (stores selected mood)
       │
       ▼
TasteProfileScreen → user enters 3+ fav movies → tmdb_service.searchMovies()
       │                stores IDs in Hive userProfile box
       ▼
SwipeScreen loads → swipe_provider.loadDeck()
       │
       ▼
discovery_service.buildDeck(mood, tasteSeeds, isGemsMode)
       │
       ├── tmdb_service.getRecommendations(seedId) × seeds
       ├── tmdb_service.discoverByGenre(genreIds, moodKeywords)
       ├── Filter: dedup, remove already-swiped (swipeHistory Hive box)
       ├── If gemsMode: filter popularity < 30 AND year < 2020
       └── Return List<Movie> (30 items per deck)
       │
       ▼
CardStack renders top 3 cards
       │
       ▼
User swipes right → watchlist_provider.add(movie) → Hive watchlist box
User swipes left  → hive_service.addToSwipeHistory(movieId)
       │
       ▼
After 5 swipes → swipe_provider fires swipeGateEvent
       │
       ▼
AuthPromptSheet (bottom sheet, dismissible) → if dismissed, continues as guest
       │
       ▼
User taps card → go_router.push('/movie/:id')
       │
       ▼
MovieDetailScreen → tmdb_service.getMovieVideos(id) → gets YouTube key
       │
       ▼
TrailerButton tapped → url_launcher.launchUrl(youtubeUrl)
```

---

## API Layer

### TMDB Service (`tmdb_service.dart`)

| Method | Endpoint | Usage |
|---|---|---|
| `searchMovies(query)` | `/search/movie` | Taste profile movie search |
| `getMovie(id)` | `/movie/{id}` | Full movie detail |
| `getRecommendations(id)` | `/movie/{id}/recommendations` | Seed-based recommendations |
| `getSimilar(id)` | `/movie/{id}/similar` | Similar movies to taste seeds |
| `discoverMovies(params)` | `/discover/movie` | Mood/genre filtered discovery |
| `getMovieVideos(id)` | `/movie/{id}/videos` | YouTube trailer keys |
| `getGenres()` | `/genre/movie/list` | Genre list (cached) |

### HTTP Client
- Package: `dio`
- Base URL: `https://api.themoviedb.org/3`
- Auth: `Authorization: Bearer {TMDB_READ_ACCESS_TOKEN}` header
- Interceptors: logging (debug only), retry (max 2), cache headers

### YouTube Integration
- **No YouTube Data API v3 calls in MVP**
- TMDB `/videos` endpoint returns the YouTube video key for free
- Open via: `url_launcher` → `https://www.youtube.com/watch?v={key}`
- V2 option: embed using `youtube_player_flutter` package for in-app playback

---

## Local Storage (Hive)

| Box Name | Type | Contents |
|---|---|---|
| `userProfile` | `UserProfileModel` | Taste profile movie IDs, selected moods, swipe count |
| `watchlist` | `List<MovieModel>` | All right-swiped movies |
| `swipeHistory` | `Set<int>` | Movie IDs already seen (prevent repeats) |
| `preferences` | `Map<String, dynamic>` | Gems mode toggle, onboarding complete flag |

### Hive Adapters Needed
- `MovieModel` → `TypeAdapter` registered at typeId: 0
- `UserProfileModel` → `TypeAdapter` registered at typeId: 1

---

## State Management (Riverpod)

| Provider | Type | Responsibility |
|---|---|---|
| `onboardingProvider` | `StateNotifier` | Selected mood, taste movies, onboarding step |
| `swipeDeckProvider` | `AsyncNotifier` | Current deck of movies, loading state |
| `swipeSessionProvider` | `StateNotifier` | Swipe count, swipe gate trigger |
| `watchlistProvider` | `StateNotifier` | Watchlist CRUD, synced to Hive |
| `gemsModeProvider` | `StateProvider<bool>` | Hidden gems toggle |
| `userProfileProvider` | `StateNotifier` | Local profile read/write |

---

## Flutter Package Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.0.0

  # HTTP
  dio: ^5.4.3+1

  # Local Storage
  hive_flutter: ^1.1.0

  # UI / Animations
  flutter_card_swiper: ^7.0.1   # Tinder swipe gestures
  cached_network_image: ^3.3.1  # Poster image caching
  shimmer: ^3.0.0               # Loading skeletons
  google_fonts: ^6.2.1          # Syne + Inter fonts

  # Platform
  url_launcher: ^6.2.6          # Open YouTube links

  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
```

---

## Environment & Secrets

- TMDB API key stored as compile-time `--dart-define=TMDB_TOKEN=xxx`
- Never hardcode keys in source
- `.env` file in project root (git-ignored)
- `env.dart` reads via `String.fromEnvironment()`

---

## Navigation Routes (go_router)

```
/                        → SplashScreen
/onboarding/mood         → MoodSelectionScreen
/onboarding/taste        → TasteProfileScreen
/swipe                   → SwipeScreen
/movie/:id               → MovieDetailScreen
/watchlist               → WatchlistScreen
/gems                    → GemsScreen
```

---

## MVP Constraints & Guardrails

| Constraint | Reason |
|---|---|
| No backend | Keeps MVP fast to ship, no infra cost |
| No auth in MVP | Removes friction, focus on core experience |
| TMDB only (no YouTube API) | Avoids quota costs, tap-to-play via url_launcher is sufficient |
| Max 30 movies per deck | Prevents over-fetching, good UX balance |
| Hive over SQLite | Simpler, no schema migrations for MVP |
| flutter_card_swiper over custom | Battle-tested physics, saves 2-3 weeks of work |
