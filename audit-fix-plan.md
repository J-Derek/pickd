# Pickd Audit Fix Plan — 2026-07-22

Companion to the graphify audit (graph built from `e432a80`). One section per finding,
in fix-priority order within each severity band. Each section: **Fix**, **Touch** (files/lines),
**Careful** (what breaks if you edit carelessly).

Branch discipline per CLAUDE.md: branch off `dev` (`fix/<name>`), never commit to `main`.
Suggested batching is at the bottom.

---

## CRITICAL

### 1. Movie/TV ID collision in dedup

**Problem.** TMDB movie and TV IDs are separate, overlapping namespaces. Dedup by bare `id`
drops legit cards whenever a movie and a show share an ID.

**Fix.** Dedup by `mediaKey` (`movie_123` / `tv_456`) everywhere a deck is merged or extended.

**Touch.**
- `lib/core/services/discovery_service.dart:88-92` — change `final seen = <int>{}` /
  `seen.add(item.id)` to `<String>{}` / `seen.add(item.mediaKey)`.
- `lib/features/swipe/providers/swipe_provider.dart:110-111` — `existingIds` becomes
  `state.deck.map((e) => e.mediaKey).toSet()`; filter with `!existingIds.contains(m.mediaKey)`.

**Careful.**
- Within a single pipeline (`collected` maps keyed by `int` at `discovery_service.dart:108, 240`)
  bare `id` is fine — those maps are movie-only or TV-only. Don't "fix" them; you'd churn code
  for nothing.
- Add a regression test first: a `MovieModel(id: 100)` and `TvModel(id: 100)` must both survive
  `buildDeck`-style merging. This is currently untestable end-to-end (see #8), so test the
  dedup loop extracted as a pure function, or land #8 first.

---

### 2. "Change Vibe" wipes the taste profile on tap

**Problem.** `swipe_screen.dart:226-231` clears moods/seeds and sets `onboardingComplete = false`
*before* the user has completed re-onboarding. Backing out destroys their profile.

**Fix.** Delete the wipe from the tap handler. Only clear/replace profile fields at onboarding
*completion* (where the taste-profile flow already saves). Onboarding should start from a clean
in-memory draft (`ref.invalidate(onboardingProvider)` already does this) and commit to Hive only
at the end.

**Touch.**
- `lib/features/swipe/screens/swipe_screen.dart:222-236` — reduce handler to
  `ref.invalidate(onboardingProvider); context.push('/onboarding/mood');`.
- `lib/features/onboarding/providers/onboarding_provider.dart` + the completion point (likely
  in `taste_profile_screen.dart`'s finish handler) — verify the final "done" step overwrites
  `selectedMoodIds`, `tasteSeedMovieIds`, `tasteSeedTvIds`, and sets `onboardingComplete = true`
  via `HiveService.saveProfile`. If it currently *appends* seeds to the old profile, switch it
  to replace.

**Careful.**
- Check how `SplashScreen` / router redirects use `onboardingComplete`. Today the wipe sets it
  `false`, so a mid-onboarding app kill re-routes to onboarding. After the fix, a user who backs
  out keeps `onboardingComplete = true` and their old vibe — that's the *desired* behavior, but
  confirm no route guard assumed the old flow.
- The onboarding provider may seed its state from the Hive profile. If so, re-entering "Change
  Vibe" should show a *blank* draft, not the old selections — invalidate must be enough; verify
  the provider's initial state doesn't read the profile lazily after invalidation.
- If the user signs in later, `migrateGuestDataToSupabase` syncs seeds (`migration_service.dart:29-35`);
  no change needed there, but don't move the wipe into migration by accident.

---

### 3. Filter pill / deck state split-brain

**Problem.** `_activeFilter` (UI, starts `moviesOnly`, `swipe_screen.dart:36`) duplicates
`SwipeDeckState.filter` (starts `both`, `swipe_provider.dart:52`). They disagree on first frame.

**Fix.** Delete `_activeFilter` entirely. The pill row reads
`ref.watch(swipeDeckProvider.select((s) => s.filter))`; taps call
`ref.read(swipeDeckProvider.notifier).setFilter(...)` only.

**Touch.**
- `lib/features/swipe/screens/swipe_screen.dart:36` — remove field.
- `swipe_screen.dart:103-108` (`_onFilterTap`) — drop the `setState`, keep the haptic and the
  early-return guard (`if (ref.read(swipeDeckProvider).filter == filter) return;`).
- `swipe_screen.dart:256-281` (`_buildFilterToggle`) — take the current filter as a parameter
  from `build`'s `deckState` (already watched at line 112), compare against it.

**Careful.**
- Decide the real default in ONE place: `SwipeDeckState.filter` default is `moviesOnly`
  (`swipe_provider.dart:27`) but the notifier constructor overrides to `both` (line 52).
  Pick one (product call — CLAUDE.md's V1.1 spec implies the 3-segment pill defaults to Movies)
  and delete the other.
- `loadDeck` resets `deck: const []` and `isLoading: true` on every `setFilter` — that's correct
  UX (shimmer on switch); don't "optimize" it away while here.

---

### 4. Watchlist reconstructs hollow models

**Problem.** `watchlist_provider.dart:36-57` (guest) and `:76-97` (Supabase) rebuild
`MovieModel`/`TvModel` with empty overview/date/rating/genres. Detail views and stats fed from
the watchlist get garbage.

**Fix (pragmatic, no schema change).** Treat watchlist rows as thin references and hydrate on
demand: the detail screen already fetches full details by ID
(`TmdbService.getMovieDetails/getTvDetails`), so the *card grid* only needs id/title/poster —
which the rows have. Audit consumers: anywhere the watchlist item's `overview`, `year`,
`voteAverage`, or `genreIds` is displayed, either (a) hide it for hydrated-later items, or
(b) fetch details.

**Fix (better, more work).** Persist the full model: for guests, store the full JSON in the
swipe-history payload (`hive_service.dart:45-52` — add overview/date/vote/genres to the map);
for Supabase, add columns or a `payload jsonb` column and write it in
`supabase_db_service.dart:116-135` / `migration_service.dart:56-76`.

**Touch.**
- `lib/features/watchlist/providers/watchlist_provider.dart:36-57, 76-97`
- `lib/core/services/hive_service.dart:40-58` (payload shape)
- `lib/core/services/supabase_db_service.dart:55-74, 116-135`
- `lib/features/auth/services/migration_service.dart:56-76, 113-132`
- `lib/features/watchlist/screens/watchlist_screen.dart` — check what fields it renders.

**Careful.**
- **Hive payload versioning:** existing installs have the old JSON shape. `getSwipeHistoryList`
  already tolerates missing keys (`jsonDecode` + map access), but any new reader must use
  `row['overview'] ?? ''`-style defaults. Never assume new keys exist.
- **Supabase schema:** adding columns needs a migration on the hosted DB *and* tolerant reads
  during rollout (old rows lack the column → `null`). If you add `payload jsonb`, keep
  `title`/`poster_path` columns as-is — `recordSwipe`'s upsert conflict target
  (`user_id,media_id,media_type`) must not change.
- The detail screen receives `extra: deck[index]` from swipe (`swipe_screen.dart:407-408`) but
  from watchlist it may only get an ID — confirm `/movie/:id` works with `extra == null`
  (it fetches by ID) before leaning on hydration.

---

### 5. Signed-in deck load dies offline

**Problem.** `swipe_provider.dart:64-68` and `:95-99` await the Supabase seen-keys fetch inside
the same `try` as deck building. Network blip + signed-in → entire load fails.

**Fix.** Isolate the remote fetch:

```dart
Set<String> seenKeys = HiveService.getSwipedKeys();
if (user != null) {
  try {
    seenKeys = {...seenKeys, ...await ref.read(supabaseDbServiceProvider).getSwipedMediaKeys(user.id)};
  } catch (e) {
    debugPrint('seen-keys fetch failed, using local only: $e');
  }
}
```

**Touch.**
- `lib/features/swipe/providers/swipe_provider.dart:61-68` (`loadDeck`) and `:92-99` (`loadMore`).
  Extract a private `Future<Set<String>> _resolveSeenKeys()` so the logic exists once.

**Careful.**
- Degraded mode can re-show cards the user swiped *on another device*. Acceptable; do not "fix"
  by caching Supabase keys in Hive here — that's a sync feature, not an error-handling patch.
- Keep the outer catch (`loadDeck`'s `error: 'Something went wrong…'`) for genuine TMDB/build
  failures. Only the Supabase call moves inside its own try.

---

### 6. Swipe gate `== 5` and dual-purpose `swipeCount`

**Problem.** `hasReachedSwipeGate => swipeCount == 5` (`swipe_provider.dart:46`) misses if the
transition is skipped/raced. Worse: `resetSwipeGate()` (line 193-195) zeroes `swipeCount`, but
`isDeckEmpty` (line 47) uses the same counter as a *deck cursor* — after a gate reset the
empty-deck detection is off by five.

**Fix.** Split the concerns:
- `swipedThisDeck` — cursor into the current deck; incremented per swipe, decremented on undo,
  reset ONLY by `loadDeck`. `isDeckEmpty` uses this.
- `gateEligible` — derived `totalSwipes >= 5 && !gateDismissed`; `gateDismissed` is a bool set
  by `resetSwipeGate()` (rename to `dismissGate()`), never touching the cursor.

**Touch.**
- `lib/features/swipe/providers/swipe_provider.dart:15-48` (state class), `:141-142` (increment),
  `:158-191` (`onUndo` decrement), `:193-195` (reset), `:56-59` (`loadDeck` must zero the cursor).
- `lib/features/swipe/screens/swipe_screen.dart:115-119` — the `ref.listen` transition check
  still works with a level-triggered `gateEligible` + `gateDismissed`; keep `_gateShown` as
  re-entrancy guard.
- `test/swipe_provider_test.dart` — rewrite; lines 54-63 currently *assert the bug*
  (gate false at 6).

**Careful.**
- `suppressAuthGate` profile flag (`swipe_screen.dart:85-88`) must keep working — it currently
  calls `resetSwipeGate()`; under the new model it sets `gateDismissed = true` permanently
  for the session instead of zeroing the counter.
- The undo path decrements both the profile's `totalSwipeCount` and state; make sure undo
  decrements the *cursor*, and only decrements the gate counter if the gate hasn't fired.
- This is the one place with existing tests — run `flutter test` after every step here.

---

## SEVERE

### 7. `TmdbService` swallows all errors

**Problem.** Every method returns `[]`/`null` on any exception (`tmdb_service.dart:49, 66, 83,
125, 148, 164, 180, 208, 225, 248, 267, 284, 320, 347, 364, 400`). 401, 429, and airplane mode
are indistinguishable from "no results."

**Fix.** Introduce `class TmdbException implements Exception { final int? statusCode; ... }`.
Remove the blanket try/catch from each method; add ONE dio `InterceptorsWrapper.onError` (or a
thin `_get()` helper) that wraps `DioException` into `TmdbException`. Callers decide:
- `DiscoveryService.buildDeck` — let seed-recommendation failures degrade (per-seed catch) but
  propagate total failure.
- `swipe_provider.loadDeck` — map `statusCode == 401` to "Check your TMDB token",
  connection errors to "You're offline", else generic retry.
- `searchMulti` / trailer / watch-provider callers — catching and returning empty is *fine
  there*, but do it at the call site so the decision is visible.

**Touch.**
- `lib/core/services/tmdb_service.dart` — whole file; mostly deleting try/catch blocks.
- `lib/core/services/discovery_service.dart` — every `TmdbService.` call site (lines 123, 142-144,
  164, 179, 202, 266, 285-288, 307, 322, 333).
- `lib/features/swipe/providers/swipe_provider.dart:80-86` — error mapping.
- Search screen, detail screen, taste profile screen — anywhere calling TmdbService directly.

**Careful.**
- **This changes the failure behavior of every screen.** Do it as its own PR; grep for every
  `TmdbService.` call (`grep -rn "TmdbService\." lib/`) and decide each one explicitly.
  A missed call site turns a silent empty-state into an unhandled exception in release.
- `getTrailerKey`'s nested `firstWhere(..., orElse: () => null)` (lines 194-206) relies on the
  catch to handle the `results` cast — when you remove the blanket catch, `results` being
  non-List or the `?[]` access will throw for real. Parse defensively (`as List? ?? []`).
- Keep the retry story: CLAUDE.md claims "retry max 2" but there is NO retry interceptor in the
  file. Either add `dio_smart_retry`-style retry for idempotent GETs while you're here, or fix
  the doc.

### 8. All-static services are untestable

**Problem.** `TmdbService`, `DiscoveryService`, `HiveService` are static classes
(`tmdb_service.dart:9`, `discovery_service.dart:18`, `hive_service.dart:8`); nothing that touches
them can be unit tested. Inconsistent with `supabaseDbServiceProvider` which already uses DI.

**Fix.** Make them instance classes exposed via Riverpod providers, mirroring
`supabase_db_service.dart:5-7`:

```dart
final tmdbServiceProvider = Provider<TmdbService>((ref) => TmdbService());
final discoveryServiceProvider = Provider<DiscoveryService>(
  (ref) => DiscoveryService(ref.watch(tmdbServiceProvider), ref.watch(hiveServiceProvider)));
```

Consumers use `ref.read(...)`; tests override with fakes via `ProviderContainer(overrides: [...])`.

**Touch.**
- The three service files (drop `static`, add constructor deps).
- Call sites: `discovery_service.dart` (TmdbService, HiveService), `swipe_provider.dart:61-64,
  92-95, 124, 133, 137-139, 164-170`, `swipe_screen.dart:45, 84, 139, 226`, `migration_service.dart:23,
  40, 94, 142`, watchlist/watched-vault providers, onboarding, search, gems, profile screens.
  This touches ~15 files — it's mechanical but wide.

**Careful.**
- **Widgets calling `HiveService.getProfile()` synchronously in `initState`/`build`**
  (`swipe_screen.dart:45, 84`) — keep a synchronous path. `Provider<HiveService>` is fine
  (construction is cheap); do NOT make profile access async as part of this refactor or you'll
  cascade `FutureBuilder`s through the UI. One refactor at a time.
- `TmdbService._dio` is static-final with header auth baked at class load (`tmdb_service.dart:10-23`).
  Moving it to an instance field changes when `Env.tmdbReadAccessToken` is read — it's
  compile-time const, so no behavior change, but keep the `_CacheInterceptor` a single shared
  instance (put dio construction in the provider, not per-call).
- Do this refactor BEFORE writing the tests in #16, and after #7 (fewer signatures churn twice).

### 9. Gems `popularity.lte` is (likely) a dead API param

**Problem.** `tmdb_service.dart:106-108, 307` sends `popularity.lte` to `/discover` —
not a documented TMDB filter. Combined with `sort_by: popularity.desc` (line 100/301), gems mode
fetches blockbusters and client-filters them to near-nothing, hence the hardcoded rescue at
`discovery_service.dart:201-213`.

**Fix.**
1. Verify empirically: hit `/discover/movie?popularity.lte=30` and compare with/without.
2. Assuming it's dead: in gems mode, request `sort_by: 'vote_average.desc'` (with the existing
   `vote_count.gte`) or `sort_by: 'popularity.asc'`, plus `vote_count.lte` as a popularity proxy
   if needed. Keep the client-side `popularity < Env.hiddenGemMaxPopularity` as the actual gate.
3. Delete the page-2 hardcoded-genre rescue block (`discovery_service.dart:201-213`) once decks
   fill naturally; it ignores the user's mood entirely.

**Touch.**
- `lib/core/services/tmdb_service.dart:89-128` (`discoverMovies`), `:290-323` (`discoverTv`) —
  add a `sortBy` param or a `gems: bool` that picks the sort.
- `lib/core/services/discovery_service.dart:164-170, 194-213, 307-313, 345-351`.

**Careful.**
- `popularity.asc` surfaces genuine junk (0-vote obscurities); the `vote_count.gte: 100` floor
  (line 101) is what keeps gems watchable — don't lower it while chasing deck size.
- Manual QA required: gems quality is a product feel, not a unit test. Compare 3 moods
  before/after on device.
- TV gems has no rescue block — after the fix confirm TV gems decks aren't empty (TV pipeline
  differences, see #11).

### 10. Three sources of truth for "hidden gem" (and image URLs)

**Fix.** `Env` is the single source.
- `lib/core/models/movie_model.dart:104` — `isHiddenGem => popularity < Env.hiddenGemMaxPopularity && releaseYear < Env.hiddenGemMaxYear;`
  (same in `tv_model.dart`, ~line 105).
- `movie_model.dart:82-90` — build `posterUrl`/`backdropUrl` from `Env.tmdbImageBaseW500` /
  `Env.tmdbImageBaseOriginal` (same in `tv_model.dart`).

**Touch.** `movie_model.dart`, `tv_model.dart`, add `import '../config/env.dart';`.

**Careful.**
- `isHiddenGem` still won't respect the "Allow Classics" runtime toggle — it's a *const-threshold*
  badge, and the toggle lives in the profile. If the badge should follow the setting, the check
  can't live on the model at all (models shouldn't read Hive); move it to a helper that takes
  `allowOldMovies`. Decide before editing — don't half-move it.
- These models are `@HiveType`; you're only touching getters, NOT `@HiveField`s — no adapter
  regen needed, no build_runner. If you touch any field annotations by accident, you must run
  `dart run build_runner build --delete-conflicting-outputs` and worry about stored-data compat.

### 11. Movie/TV pipeline + model + migration-loop duplication

**Problem.** `_buildMoviePipeline` (`discovery_service.dart:100-228`) ≅ `_buildTvPipeline`
(`:232-359`); `MovieModel` ≅ `TvModel`; `migration_service.dart:44-77` ≅ `:89-133`. Twins already
drift (TV has a force-fill rescue at 332-337 and skips mood-filter on discover results at 314-316;
movies re-sort by year at 218-222, TV doesn't).

**Fix (staged — do NOT attempt a grand unification in one PR).**
1. **Migration loop first (easy):** extract
   `({List<Map> swipeRows, List<Map> watchlistRows}) _buildSyncRows(List<Map> source, String userId)`
   and call it from both `migrateGuestDataToSupabase` and `flushPendingSync`.
2. **Pipeline second:** extract a generic private pipeline parameterized by a small strategy
   object (fetch recs / fetch similar / discover / trending / `isRecent` / `keyPrefix`), each
   returning `List<MediaItem>`. Intentional divergences (TV genre mapping at 254-262, TV
   force-fill) become explicit strategy fields, not accidents.
3. **Models last (optional):** don't merge `MovieModel`/`TvModel` — they're Hive types with
   registered typeIds; merging is a data migration. Instead extract shared getters into a mixin
   (`MediaFields`) if the duplication bothers you. The `MediaItem` sealed wrapper already gives
   you a unified API.

**Touch.**
- `lib/features/auth/services/migration_service.dart` (step 1)
- `lib/core/services/discovery_service.dart` (step 2)
- `lib/core/models/movie_model.dart`, `tv_model.dart` (step 3, optional)

**Careful.**
- **Never change `typeId: 0` / `typeId: 1` or existing `@HiveField` indices** — that corrupts
  every install's stored watch history. Model unification behind Hive is a trap; that's why
  step 3 says mixin, not merge.
- Behavior parity: before extracting the pipeline, write down the current intentional diffs
  (movie: year re-sort, gems rescue; TV: genre mapping, force-fill, no mood filter on discover,
  no gems rescue) and encode each deliberately. The refactor is only safe if the output decks
  are statistically indistinguishable — spot-check on device.
- Do #1 (mediaKey dedup) and #9 (gems sort) BEFORE this refactor so you're not porting bugs
  into the new shape.

### 12. Watchlist N+1 and full-refetch on every mutation

**Problem.** `addMedia`/`remove` → full network `_load()` (`watchlist_provider.dart:116-121,
137, 148`); `clear()` deletes rows one-by-one (`:166-169`). Shipped thinking-out-loud comment
at `:114-115`.

**Fix.**
- Optimistic updates: `addMedia` appends to `state` immediately, then fires the Supabase call;
  on failure, roll back and surface a snackbar (needs an error channel — a simple
  `StateProvider<String?>` is enough).
- `remove`: drop from `state` first, then remote delete; restore on failure.
- `clear`: single query — add `Future<void> clearWatchlist(String userId)` to
  `SupabaseDbService` using `.delete().eq('user_id', userId).eq('is_watched', false)`.
- Delete the comment at `:114-115` and make the guest/signed-in split explicit: guest adds ARE
  handled here too (append to state; Hive write already happened in `onSwiped`) so the two
  paths converge.

**Touch.**
- `lib/features/watchlist/providers/watchlist_provider.dart:110-174`
- `lib/core/services/supabase_db_service.dart` (new `clearWatchlist`)
- `lib/features/watchlist/screens/watchlist_screen.dart` — if it has pull-to-refresh, keep
  `_load()` public for that path.

**Careful.**
- `clear()`'s `.eq('is_watched', false)` filter matters: the `watchlists` table doubles as the
  watched vault (`is_watched` flag, `supabase_db_service.dart:127-128`). A naive
  `delete().eq('user_id', ...)` nukes the user's watched vault too. Test with a user who has both.
- The `watchlistProvider` rebuilds on user change (`:184`) — optimistic state must not leak
  across sign-in/out; the rebuild already handles it, don't add manual resets.
- Rollback-on-failure changes UX subtly (item appears then vanishes). Fine — but pair with the
  snackbar or it looks like a glitch.

---

## MODERATE

### 13. Style rules are dead letter (101 hardcoded fonts, 37 raw Colors, setState)

**Fix.** Enforce mechanically, migrate incrementally:
1. Add to `app_theme.dart` a complete `TextTheme` (Syne display sizes, Inter body sizes) and
   named colors for the strays (`Colors.pinkAccent` → `AppTheme.accentLove`, etc.).
2. Turn on lints in `analysis_options.yaml`: there's no built-in "no hardcoded color" lint, so
   add a short grep-based CI/pre-commit check
   (`grep -rn "fontFamily: '" lib/features && exit 1`) or adopt a custom_lint rule.
3. Migrate screen-by-screen, one PR per screen, using `Theme.of(context).textTheme.*`.
   Start with `swipe_screen.dart` (worst offender: `Colors.pinkAccent` at 724/735, inline
   TextStyles throughout).

**Careful.**
- Font *weights* differ per usage (Syne w700 vs w800); when mapping to `textTheme`, use
  `.copyWith(fontWeight: ...)` rather than inventing 12 theme slots.
- Visual regression risk is real: `google_fonts` vs raw `fontFamily: 'Syne'` string resolve
  differently — the inline strings only work because the fonts are bundled/loaded elsewhere.
  Compare screenshots before/after per screen.
- `setState` for press-animations (`_LargeActionButtonState`, `gems_screen.dart:500-505`) is
  the "trivial local widget state" CLAUDE.md permits — LEAVE those. The violations to kill are
  data/derived-state ones (`_activeFilter` #3, `_displayName`/`_avatarUrl` — move those into a
  `userProfileDetailsProvider` so profile edits propagate to the swipe header).

### 14. Unbounded `_CacheInterceptor`

**Fix.** Bound it: on insert (`tmdb_service.dart:455-461`), evict expired entries and cap size
(e.g. 100 entries, LRU by dropping oldest timestamp). ~10 lines.

**Touch.** `lib/core/services/tmdb_service.dart:426-462`.

**Careful.**
- Key is the full URI including query params — search queries make it churn fastest. Cap by
  count, not by "smart" per-endpoint TTLs; keep it dumb.
- Cache stores `response.data` by reference; model `fromJson` doesn't mutate it today. If anyone
  later mutates parsed maps, cached entries corrupt. A note in the class doc is enough.

### 15. Pending-sync flags: double-write + flush only on cold start

**Fix.**
- `swipe_provider.dart:122-135` — write Hive ONCE: attempt Supabase first when signed in, then
  a single `addToSwipeHistory(item, action.name, rating: ..., pendingSync: <supabaseFailed>)`.
  (Also: the current success path drops `rating` from local history — only the failure path
  writes it. Unify.)
- Trigger `flushPendingSync` on connectivity/auth resume, not just splash: call it from
  `authStateProvider` changes (sign-in) and app-resume (`AppLifecycleListener` in `MainShell`).
  Keep it idempotent — it already is (upserts + `markSynced`).

**Touch.**
- `lib/features/swipe/providers/swipe_provider.dart:122-135`
- `lib/features/shell/main_shell.dart` (lifecycle hook)
- `lib/features/auth/services/migration_service.dart` — no logic change; it becomes the single
  flush path (and after #11 step 1, single row-builder).

**Careful.**
- `recordSwipe` is two sequential remote writes (`supabase_db_service.dart:61-73`); if the
  second (`addToWatchlist`) fails after the first succeeded, marking pendingSync and later
  re-upserting is safe *because everything is an upsert with the same conflict key* — preserve
  that property in any edit. No inserts, ever, in the sync path.
- Don't flush on every app-resume unconditionally — guard with `getPendingSyncSwipes().isEmpty`
  early-return (already exists, `migration_service.dart:95`) to avoid a Supabase query per resume.
  Wait: it queries Hive, not Supabase — that guard is cheap and correct. Keep it.

### 16. Test coverage

**Fix.** After #8 lands, add in priority order:
1. `discovery_service_test.dart` — fake TmdbService: dedup by mediaKey (regression for #1),
   gems filter thresholds, movie/TV interleave (every-3rd-card rule, `discovery_service.dart:68-81`),
   seen-keys exclusion, deck cap at 30.
2. `migration_service_test.dart` — fake db + seeded Hive (`hive_test` package or in-memory Hive):
   heart→save mapping, rating passthrough, watchlist row derivation, flush marks synced only
   on success.
3. `watchlist_provider_test.dart` — guest vs signed-in load, optimistic add/remove rollback.
4. Rewrite `swipe_provider_test.dart` for the #6 model (delete the `== 5` assertions).

**Careful.**
- Do NOT write these against the static services "temporarily" with real Hive/network — that's
  how flaky suites are born. #8 is the prerequisite; sequence it.
- `MediaFilter` lives in `discovery_service.dart:10-14`; when faking DiscoveryService you'll
  still import the real file for the enum — fine, but it's a smell (enum belongs in
  `core/models`). Move it opportunistically.

### 17. Scope drift: `web/`, undocumented search, dead box constants

**Fix.**
- `web/` directory: CLAUDE.md says web is out of scope. Either delete it (it's untracked) or —
  if it was created for dev convenience — add it to `.gitignore` and note the exception in
  CLAUDE.md. Decide; don't leave it ambiguous. **Ask before deleting** — it's uncommitted work
  someone made deliberately.
- Search feature: add `/search` to the routes table in CLAUDE.md and to the V1.x section;
  confirm `app.dart` registers the route; commit the feature (it's untracked — it can be lost).
- `hive_service.dart:11-12` — delete `_watchlistBoxName` / `_watchedBoxName` (never opened,
  never used), and fix CLAUDE.md's Local Storage table, which describes a `watchlist` box that
  doesn't exist (reality: watchlist is derived from `swipeHistoryV2` for guests, Supabase for
  signed-in).

**Careful.**
- Before deleting the dead constants, `grep -rn "watchlist\b" lib/ --include=*.dart` for any
  `Hive.openBox('watchlist')` stragglers — an old install may still have the box file on disk;
  that's harmless, but code must not half-reference it.
- CLAUDE.md edits: update the State Management table too (`gemsModeProvider`,
  `swipeSessionProvider` — verify these still exist; the audit saw gems state handled
  differently). Stale primer docs cost every future session.

### 18. Graphify corpus pollution

**Fix.** Create `.graphifyignore` at repo root:

```
windows/flutter/ephemeral/
windows/runner/
graphify-out/
.claude/
**/skills/**
*.g.dart
```

Then re-run a full build (`/graphify .`) — note the shrink-guard will refuse a smaller
graph; that shrink is intentional here, so use the documented `--force` path when prompted.

**Careful.**
- Don't ignore `android/`/`ios/` config wholesale — `build.gradle.kts` edges have caught real
  config drift before. Only the generated/vendored trees.
- Ignoring `*.g.dart` removes Hive adapter nodes (`MovieModelAdapter` etc.) from the graph —
  acceptable; they're generated. If you want adapter visibility, keep them and ignore only the
  Windows C++ and skill-doc trees (they were ~40% of the noise).

---

## Suggested batching (branches off `dev`)

| Branch | Findings | Risk |
|---|---|---|
| `fix/dedup-and-offline` | #1, #5 | Low — surgical, ship first |
| `fix/change-vibe-wipe` | #2 | Medium — touches onboarding flow, manual QA |
| `fix/swipe-state` | #3, #6 | Medium — has tests, rewrite them |
| `refactor/services-di` | #8, then #7 | Wide but mechanical; blocks #16 |
| `fix/gems-discovery` | #9, #10 | Medium — needs on-device feel check |
| `refactor/pipeline-dedup` | #11 | High — do last among refactors, after tests exist |
| `fix/watchlist-sync` | #4, #12, #15 | High — touches Supabase schema decisions |
| `chore/style-and-docs` | #13, #14, #17, #18 | Low, incremental |
| `test/core-coverage` | #16 | After `refactor/services-di` |

Golden rules while executing:
- Never touch `@HiveField` indices or `typeId`s. If you must, that's a data migration project.
- Every Supabase write stays an **upsert** on `user_id,media_id,media_type` — inserts break
  the idempotent sync story.
- Run `flutter analyze && flutter test` per branch; run the app with
  `flutter run --dart-define=TMDB_TOKEN=...` and swipe through all three filters + gems mode
  before merging anything that touches discovery.
