# Pickd - Mobile App Reference

## 1. Product Summary
* **What Pickd is:** Pickd is a premium, mood-based movie and TV discovery mobile application. 
* **The problem it solves:** It eliminates "endless scrolling" and decision fatigue caused by overwhelming streaming library interfaces that categorize by rigid genres rather than human emotion.
* **The ideal user:** Movie enthusiasts, casual binge-watchers, and couples who spend more time debating what to watch than actually watching it.
* **What makes it different from other movie discovery apps:** Instead of complex filters and grids, Pickd uses a hyper-fast, Tinder-style swipe interface mapped to the user's current mood. It builds an emotional "Taste DNA" profile that learns what you like intuitively.

## 2. Core Philosophy
* **Why was Pickd created?** To bring joy, speed, and tactility back to discovering cinema.
* **What user frustration is it solving?** The "analysis paralysis" of opening Netflix or Prime Video, scrolling for 45 minutes, and giving up because nothing feels quite right for the current vibe.
* **What experience should users have while using it?** Fast, fluid, cinematic, and deeply personal. Decision-making should feel instantaneous and engaging.
* **Personality:** Confident, sleek, cinephile, intuitive, and premium. Like a highly curated indie cinema mixed with a high-end tech product.

## 3. Complete User Journey
1. **Installation & Launch:** The user downloads the APK and opens the app to a dark, cinematic splash screen.
2. **Onboarding (Taste DNA):** The app asks the user to pick three foundational movies they love from a visual grid to establish their initial emotional baseline.
3. **Authentication (Optional but Encouraged):** The user connects via Supabase auth to ensure their watchlist syncs across devices.
4. **Mood Selection:** The user lands on a screen asking "What's the vibe?" with options like Chill, Hyped, Spooky, or Deep.
5. **The Swipe Deck:** The app generates a customized deck of movie posters. The user swipes right to save to their Watchlist, left to pass, or up to mark as already watched.
6. **Movie Deep Dive:** Tapping a card opens a rich detail view with trailers, cast, and platform availability.
7. **Watchlist Execution:** When ready to watch, the user opens their zero-latency Watchlist, instantly filters by "available on Netflix," and hits play.

## 4. Screen Reference
* **Onboarding (Pick 3)**
  * *Purpose:* Establish baseline taste.
  * *Layout:* Dense masonry grid of movie posters.
  * *Main components:* Selectable image cards, floating "Continue" FAB.
  * *User actions:* Tap to select/deselect.
* **Mood Selection**
  * *Purpose:* Set the context for the current swipe session.
  * *Layout:* Clean, minimalist list or grid of bold typographic buttons.
  * *Main components:* Mood toggles.
  * *User actions:* Tap a mood.
* **Swipe Deck**
  * *Purpose:* Rapid movie curation.
  * *Layout:* Edge-to-edge central card stack with a blurred background.
  * *Main components:* Tinder-style swipeable card, movie title overlay, quick stats (runtime, rating).
  * *User actions:* Swipe Left (Pass), Swipe Right (Save), Swipe Up (Watched), Tap (Details).
  * *Animations:* Fluid, physics-based card dragging and spring-release off-screen.
* **Movie Detail**
  * *Purpose:* Deep context for a single movie.
  * *Layout:* Parallax hero header (movie backdrop) transitioning into scrollable content.
  * *Main components:* Hero image, synopsis, cast horizontal scroll, where-to-watch badges.
  * *User actions:* Scroll, add to watchlist, play trailer.
* **Watchlist**
  * *Purpose:* The repository of saved content.
  * *Layout:* Clean grid or list view.
  * *Main components:* Movie posters, instant filter chips (mood, runtime, platform).
  * *Empty states:* "Your deck is empty. Start swiping to fill it up."
  * *Loading states:* Instant (Hive offline cache).
* **Search**
  * *Purpose:* Direct lookup.
  * *Layout:* Search bar with immediate list results.
  * *Main components:* Text input, debounced list view.

## 5. Feature Reference
* **Taste DNA**
  * *What it does:* Builds a hidden profile of preferences based on the "Pick 3" onboarding.
  * *Why it exists:* Cold-start problem solver.
  * *When interacted with:* Initial launch.
  * *What problem it solves:* Prevents new users from seeing generic, irrelevant recommendations.
* **Swipe Deck (Decision Engine)**
  * *What it does:* Presents one movie at a time for binary decision making.
  * *Why it exists:* Grids cause choice paralysis; single cards force a gut reaction.
  * *When interacted with:* Core daily usage loop.
* **Hidden Gems**
  * *What it does:* Surfaces highly-rated but obscure content.
  * *Why it exists:* To break users out of blockbuster echo chambers.
* **Zero-Latency Watchlist**
  * *What it does:* Caches saved movies locally.
  * *Why it exists:* To ensure looking up a saved movie is instantaneous, even on bad cellular networks.

## 6. Visual Language
* **Color palette:** Dark mode native. Deep charcoal backgrounds (`--ink`), with high-contrast, electric accents like Indigo (`#6B4EFF`), Cyan (`#00F0FF`), and Amber (`#FFC107`).
* **Typography:** Modern, structured sans-serif. Highly legible body text with bold, tightly-tracked display headers for movie titles.
* **Icon style:** Minimalist, thin-stroke line-art.
* **Card design:** Immersive, edge-to-edge imagery with subtle bottom gradient masks to ensure text legibility.
* **Shadows:** Deep, diffuse drop shadows mimicking physical depth and stage lighting.
* **Corners:** Smooth, rounded corners (e.g., 16px to 24px radii).
* **Spacing:** Generous padding. Breathing room around all interactive elements to prevent mis-taps.
* **Motion style:** Liquid, responsive, physics-driven springs. No rigid linear transitions.
* **Overall aesthetic:** Premium, tactile, cinematic.

## 7. Motion & Animation
* **Card Swipe (Swipe Deck):**
  * *Where it appears:* Main interaction loop.
  * *What triggers it:* User dragging the central movie card.
  * *What it communicates:* Physical manipulation. Rotation tied to drag distance communicates commitment to the swipe.
  * *Feeling:* Satisfying, snappy, tactile.
* **Hero Parallax (Movie Detail):**
  * *Where it appears:* Transitioning from a poster to the detail view.
  * *What triggers it:* Scrolling down the detail page.
  * *What it communicates:* Depth and spatial continuity.
* **Filter Chip Snap (Watchlist):**
  * *Where it appears:* Selecting a filter like "Netflix".
  * *What triggers it:* Tap.
  * *What it communicates:* Instant reactivity (zero latency).

## 8. Brand Voice
* **Tone:** Playful, confident, cinematic, minimalist, energetic.
* **Writing Style:** Punchy and direct. Never bureaucratic. 
* **Examples:**
  * *Instead of:* "Please select your preferred genres." -> *Pickd says:* "What's the vibe?"
  * *Instead of:* "No results found in your saved list." -> *Pickd says:* "Your deck is empty. Start swiping."
  * *Instead of:* "Application loading." -> *Pickd says:* "Building your deck..."

## 9. Marketing Assets Already Available
* `assets/logo.jpg`
* `assets/images/pickd_logo_enhanced.jpg`
* `assets/screenshots/02_mood_selection.png`
* `assets/screenshots/03_pick3.png`
* `assets/screenshots/04_swipe_deck.png`
* `assets/screenshots/05_movie_detail.png`
* `assets/screenshots/06_search.png`
* `assets/screenshots/07_watchlist.png`

## 10. Website Opportunities
* **Interactive Swipe Demo:** A mini, web-based version of the Swipe Deck in the hero section would perfectly communicate the app's core value prop instantly.
* **Parallax Movie Posters:** Using the auto-scrolling trending posters as a cinematic background effectively sells the visual richness of the app.
* **Matte Cardstock Feature Showcase:** Presenting the app's features (Taste DNA, Hidden Gems) as physical ticket stubs leverages the app's tactile, premium aesthetic.

## 11. Three Reasons Someone Should Download Pickd
1. **Speed:** You will decide what to watch in 30 seconds instead of 30 minutes.
2. **Quality:** You will discover critically acclaimed "Hidden Gems" you didn't know existed.
3. **Convenience:** A zero-latency, cross-device synced watchlist means your curation is always instantly available.

## 12. Elevator Pitch
"Stop scrolling. Start watching. Pickd is a premium, mood-based movie discovery app that learns your cinematic DNA and serves up the perfect film for your exact vibe in half a second."

## 13. Complete Product Summary
Pickd is a highly polished, Flutter-based mobile application designed to cure streaming decision fatigue. It replaces endless grid scrolling with an intuitive, Tinder-style swipe interface that curates movie and TV recommendations based on a user's current mood and foundational "Taste DNA." The app features a premium dark-mode aesthetic, utilizing edge-to-edge imagery and physics-driven liquid animations to create a highly tactile, cinematic user experience. With Supabase handling seamless cross-device cloud syncing and Hive powering a zero-latency offline watchlist, Pickd prioritizes speed, elegance, and quality discovery over bloated catalog browsing.
