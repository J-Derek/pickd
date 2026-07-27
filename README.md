<div align="center">
  <img src="assets/images/pickd_logo_enhanced.jpg" alt="Pickd Logo" width="200"/>

  <h1>Pickd</h1>
  <p><strong>Stop scrolling. Start watching.</strong></p>

  <p>
    A premium, mood-based movie discovery app built with Flutter and Supabase. <br>
    Swipe your way through personalized recommendations tailored precisely to your current vibe.
  </p>

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
    <a href="https://github.com/J-Derek/pickd/releases">
      <img src="https://img.shields.io/github/v/release/J-Derek/pickd?style=for-the-badge&color=success" alt="Release" />
    </a>
  </p>
</div>

<br />

## 🌟 The Vision

Endless scrolling on streaming platforms is broken. **Pickd** fixes this by instantly curating movies and TV shows based entirely on your **current mood** and **vibe**. Using a fluid, Tinder-style swipe interface, you make split-second decisions without overthinking.

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 🎭 **Mood-Based Engine** | Select your current vibe (e.g., *Chill, Hyped, Spooky*) and let Pickd instantly generate the perfect deck of films. |
| ⚡ **Tinder-Style Swiping** | Fluid gesture controls. **Swipe Right** to save to Watchlist, **Swipe Left** to pass, **Swipe Up** to mark as watched. |
| 🎬 **Premium Cinematic UI** | A stunning, edge-to-edge dark mode interface designed using modern HCI principles (Fitts's Law, Gestalt). |
| ☁️ **Cross-Device Sync** | Powered by **Supabase**. Your watchlist, history, and profile sync instantly across all your devices. |
| 📱 **Offline Caching** | Powered by **Hive**. Blazing fast local storage ensures your app loads instantly, even on terrible networks. |
| 💎 **Gems & Badges** | Gamified progression system. Earn badges and gems the more movies you watch and discover. |
| 🔍 **Deep Search** | Advanced search with dynamic grid layouts, auto-pagination, and real-time trending updates. |

---

## 🛠️ Tech Stack

### Frontend
- **Framework:** [Flutter](https://flutter.dev/) (Cross-platform UI)
- **State Management:** [Riverpod](https://riverpod.dev/) (v2 with code generation)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage:** [Hive](https://pub.dev/packages/hive) (NoSQL Database)
- **UI/UX Components:** `flutter_card_swiper`, `showcaseview`, `shimmer`

### Backend
- **BaaS:** [Supabase](https://supabase.com/) (PostgreSQL Database, Authentication, Edge Functions)
- **Data Source:** [TMDB API](https://www.themoviedb.org/) (The Movie Database)

---

## 🚀 Getting Started

Want to test it out right now? 

1. Head over to the [Releases Tab](https://github.com/J-Derek/pickd/releases).
2. Download the latest `app-release.apk`.
3. Install it directly on your Android device and start swiping!

### Running Locally (For Developers)

1. **Clone the repository**
   ```bash
   git clone https://github.com/J-Derek/pickd.git
   cd pickd
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   Rename `.env.example` to `.env` and add your API keys:
   ```env
   TMDB_API_KEY=your_tmdb_api_key
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Build and Run**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

Pickd follows a modular, feature-first architecture (`/lib/features/*`) to ensure massive scalability and clean separation of concerns.

- **`core/`**: Shared services (Supabase, Hive), network clients, unified `AppTheme`, and base models.
- **`features/`**: Independent, decoupled domains (`auth`, `swipe`, `watchlist`, `gems`, `search`, `profile`).
- **`providers/`**: Riverpod state controllers handling business logic and API caching.

---

<div align="center">
  <i>Designed and engineered with passion. Let's make movie nights fun again.</i><br><br>
  <a href="https://github.com/J-Derek/pickd/issues">Report Bug</a>
  ·
  <a href="https://github.com/J-Derek/pickd/issues">Request Feature</a>
</div>
