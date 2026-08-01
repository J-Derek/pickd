# Pickd - UI & UX Description
This document provides a comprehensive breakdown of the Pickd app's User Interface (UI) and User Experience (UX) flow. It is designed to be fed into a UI/UX analysis tool (like Stitch) to evaluate the design system, user journeys, and identify areas for improvement.

## 1. Global Design System & Aesthetics
*   **Theme:** Dark mode by default, built to feel premium, cinematic, and immersive. 
*   **Colors:** 
    *   `bgPrimary` & `bgSurface`: Deep, rich blacks/dark grays to make movie posters pop.
    *   `accentPrimary`: A vibrant accent color (likely a neon or glowing hue) used for active states, primary buttons, and highlight accents.
*   **Typography:** 
    *   **Headers & Logo:** `Syne` font (modern, bold, geometric) to give it a trendy, editorial vibe.
    *   **Body & UI Text:** `Inter` font (clean, highly readable sans-serif) for utility text.
*   **Visual Elements:** Heavy use of high-quality movie/TV posters, subtle glassmorphism (frosted glass effects), glowing drop-shadows on active elements, and smooth micro-animations.

---

## 2. Onboarding Flow
The goal of onboarding is to instantly understand the user's taste with minimal friction.

### A. Mood Selection Screen (`MoodSelectionScreen`)
*   **Header:** Dynamic greeting based on the time of day (e.g., "What's the vibe this morning?", "What's the vibe tonight?").
*   **Content:** A grid or list of mood cards (e.g., "Chill", "Thrilling", "Mind-Bending") accompanied by relevant emojis or subtle background gradients. 
*   **UX:** Tapping a mood immediately registers the user's intent and moves them to the next step.

### B. Taste Profile Screen (`TasteProfileScreen`)
*   **Header:** "Favorites you already love. Add at least 3 movies or TV shows."
*   **Content:** A search bar at the top ("Search for titles you love"). Below is a visual grid of search results.
*   **Interaction:** Users tap posters to select their "seeds".
*   **Smart UX:** Movies/Shows the user has already watched (synced from Supabase) are dimmed out with a green "Watched" badge overlay so they cannot be accidentally selected.

---

## 3. Core Experience: The Swipe Deck
### A. Main Swipe Screen (`SwipeScreen`)
*   **Header Bar:** 
    *   Left: "pickd" logo (Syne font).
    *   Middle/Right: A "Change Vibe" (Tune icon) button to edit the mood, and a Watchlist icon.
*   **Filter Toggle:** A sleek, 3-segment pill toggle placed just below the header (`Movies | Both | TV Shows`). The active segment uses an `AnimatedContainer` to smoothly slide the `accentPrimary` background behind the selected text.
*   **Card Deck (Tinder-style interaction):**
    *   The main viewport is dominated by a large, edge-to-edge movie/TV poster card.
    *   **Card Overlays:** A dark gradient shadow at the bottom ensures text readability. Displays Title, Release Year, TMDB Rating, and Genre Chips. If it's a TV show, a small, pill-shaped "TV" badge sits in the top right.
    *   **Gestures:**
        *   **Swipe Right:** Save to Watchlist.
        *   **Swipe Left:** Skip/Pass.
        *   **Swipe Up (Intercepted):** Marks as "Watched". *Triggers a fluid 5-star rating pop-up dialog before completing the action.*
*   **Walkthrough Overlay:** On the very first launch, a semi-transparent dark overlay appears with visual arrows teaching the swipe gestures. Dismissed on tap.
*   **Empty State:** If the discovery engine runs out of recommendations, it shows a premium "Deck Empty" state rather than a blank screen.
*   **Auth Gate:** After 5 swipes, an invisible trigger pops up an Auth Gate bottom sheet prompting guest users to save their progress.

---

## 4. Discovery & Detail
### A. Media Detail Screen (`MovieDetailScreen`)
*   **Header:** Hero-style poster image that bleeds into the top of the screen with a translucent back button.
*   **Content:** 
    *   Title, Year, Runtime, Vote Average.
    *   **"Where to Watch":** Displays a row of streaming provider logos (Netflix, Hulu, Max, etc.) fetched from TMDB.
    *   Synopsis text.
    *   Genre chips and horizontal scrolling Cast list.

---

## 5. Profile & Vaults
### A. Watchlist Screen (`WatchlistScreen`)
*   **Layout:** A clean GridView of saved movie/TV posters.
*   **Actions:** "Clear All" button with an AppTheme-styled confirmation `AlertDialog`.
*   **Empty State:** Premium graphic with a "Start Swiping" Call-To-Action.

### B. Profile Screen (`ProfileScreen`)
*   **AppBar:** Contains a Settings (Gear) icon that opens a `SettingsSheet` (includes a toggle for "Allow Classics 1990 & Older").
*   **Stats Section:** Quick metrics (e.g., Total Watched, Total Saved).
*   **Primary CTA:** A large, appealing gradient button/card leading to the "Watched Vault".
*   **Auth CTA:** "Connect Account" for guests, or "Sign Out" for authenticated users.

### C. Watched History Vault (`WatchedVaultScreen`)
*   **Layout:** A GridView of all movies and TV shows the user has swiped UP on.
*   **Card Details:** Each poster in the grid features a small star-rating badge in the top-right corner, displaying the 1-5 star rating they gave it during the swipe-up action.

---

## 6. Authentication
### A. Auth Screen (`AuthScreen`)
*   **Layout:** Accessible via the Profile screen or the 5-swipe Auth Gate.
*   **UI:** Dark-themed, minimalist form with standard Email/Password fields.
*   **Interaction:** Smooth toggle between "Sign In" and "Sign Up". Utilizes native `ScaffoldMessenger` snackbars for error handling and a circular progress indicator during Supabase network calls.
