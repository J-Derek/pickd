<div align="center">
  <img src="assets/images/pickd_logo_enhanced.jpg" alt="Pickd Logo" width="200"/>

  <h1>Pickd</h1>
  <p><strong>Stop scrolling. Start watching.</strong></p>

  <p>
    A premium, mood-based movie discovery app built with Flutter and Supabase. <br>
    Swipe your way through personalized recommendations tailored precisely to your current vibe.
  </p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  </p>
</div>

<br />

## ?? App Preview

| Swipe | Detail | Watchlist |
|:---:|:---:|:---:|
| <img src="assets/screenshots/03_swipe_deck.png" width="250" /> | <img src="assets/screenshots/04_movie_detail.png" width="250" /> | <img src="assets/screenshots/05_watchlist.png" width="250" /> |

| Mood | Search | Profile |
|:---:|:---:|:---:|
| <img src="assets/screenshots/02_mood_selection.png" width="250" /> | <img src="assets/screenshots/06_search.png" width="250" /> | <img src="assets/screenshots/07_profile.png" width="250" /> |

<br />

## ?? The Vision

Endless scrolling on streaming platforms is broken. **Pickd** fixes this by instantly curating movies and TV shows based entirely on your **current mood** and **vibe**. Using a fluid, Tinder-style swipe interface, you make split-second decisions without overthinking.

---

## ? Features

| Feature | Description |
| :--- | :--- |
| ?? **Mood-Based Engine** | Select your current vibe (e.g., *Chill, Hyped, Spooky*) and let Pickd instantly generate the perfect deck of films. |
| ? **Tinder-Style Swiping** | Fluid gesture controls. **Swipe Right** to save to Watchlist, **Swipe Left** to pass, **Swipe Up** to mark as watched. |
| ?? **Premium Cinematic UI** | A stunning, edge-to-edge dark mode interface designed using modern HCI principles. |
| ?? **Cross-Device Sync** | Powered by **Supabase**. Your watchlist, history, and profile sync instantly across all your devices. |
| ?? **Offline Caching** | Powered by **Hive**. Blazing fast local storage ensures your app loads instantly, even on terrible networks. |

---

## ??? Architecture

\\mermaid
graph TB
    subgraph Frontend [?? Flutter App]
        UI[UI Layer]
        State[State Management - Riverpod]
        Local[Local Cache - Hive]
    end
    
    subgraph Backend [?? Backend Services]
        Supa[Supabase]
        TMDB[TMDB API]
    end
    
    UI --> State
    State --> Local
    State --> Supa
    State --> TMDB
\
---

<div align="center">
  <i>Designed and engineered with passion. Let's make movie nights fun again.</i>
</div>
