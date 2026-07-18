# Handoff Doc
Generated: 2026-07-17

## What Was Built / Accomplished (Frontend V1.1 Complete)
- **Unified Media Models:** Merged Movie and TV items into a single sealed `MediaItem` class to power dual-mode swiping.
- **Swipe History & Undo:** Upgraded `HiveService` to `swipeHistoryV2` to store detailed JSON metadata for history. Built a new `SwipeHistoryScreen` accessible from the Profile screen to view past actions (Skipped, Saved, Watched) and undo them instantly.
- **Editable Taste Profile:** Made the Profile "Taste Seeds" clickable, routing the user to the Taste Profile screen in edit mode. Saving updates the algorithm and refreshes the deck on the fly.
- **Where to Watch Links:** TMDB streaming provider links now correctly open a general TMDB web hub when a dedicated app deeplink isn't available.
- **Android Back Navigation Fix:** Added `android:enableOnBackInvokedCallback="true"` to `AndroidManifest.xml` to squash the app-closing back-gesture bug.
- **Profile Enhancements:** Added placeholder toggles for Account Details and Push Notifications, and neatly tucked the "Classics Filter" behind a Settings menu.

## Decisions Made
- **Frontend V1.1 is Locked:** The local frontend experience is complete and pushed to GitHub's `dev` branch.
- **Supabase Backend Reset:** The user decided to disconnect and completely rebuild the Supabase backend from scratch rather than trying to untangle the old setup.
- **Anonymous Auth:** We noted that Anonymous Sign-Ins are currently disabled on the Supabase project, which was blocking the initial connection.

## What's Next (Backend Redesign)
- [ ] **Supabase Teardown:** Wipe the current Supabase schema/auth configuration.
- [ ] **Database Schema Design:** Map out the new database schema for Profiles, Watchlists, and Swipe History.
- [ ] **Auth Strategy:** Re-configure Supabase Auth (likely starting with Anonymous sessions that can be upgraded).
- [ ] **Backend Migration:** Swap the local `HiveService` methods over to the newly designed Supabase backend endpoints.

## Blockers
- None. Next session starts fresh with the Backend/Auth redesign!
