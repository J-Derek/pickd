# Pickd Web - Project Overview & Application Documentation

## 1. Project Overview

* **Application Name:** Pickd Web (Promotional Landing Page)
* **Purpose:** A high-conversion, visually premium single-page application (SPA) designed to introduce users to the Pickd mobile app and drive APK downloads.
* **Problem it Solves:** Bridges the gap between potential users and the mobile application by visually demonstrating the app's value, aesthetic, and core mechanics before they commit to downloading.
* **Target Audience:** Potential users of the Pickd mobile app (movie/TV enthusiasts looking for a better discovery tool).
* **Value Proposition:** Delivers a cinematic, highly tactile first impression that mirrors the premium experience of the mobile app.

## 2. Current State

* **What has already been implemented:**
  * Fully responsive React/Vite architecture.
  * Hero section with a dynamic, auto-scrolling movie poster background (Trending Marquee).
  * Interactive Feature Showcase utilizing a bespoke "Matte Cardstock" ticket motif.
  * "How it Works" and Footer CTA sections.
  * Framer Motion scroll and entry animations.
* **What is partially implemented:** N/A (Marketing scope is currently fulfilled).
* **What is still planned:** N/A for the current scope.
* **Current project maturity:** Production-ready static site, ready for deployment.

## 3. Architecture

* **Overall Architecture:** Client-side rendered Single Page Application (SPA).
* **Frontend Stack:** React 19, TypeScript, Vite, Tailwind CSS (v4), Framer Motion.
* **Backend Stack:** None (Static site).
* **Database:** None.
* **Authentication:** None.
* **Storage:** None.
* **External Services:** The Movie Database (TMDB) API.
* **APIs:** TMDB `trending/movie/day` endpoint.
* **Deployment:** Designed for static hosting platforms (e.g., Vercel, Netlify, Cloudflare Pages).

## 4. Features

### Trending Marquee Background
* **Purpose:** Provides a cinematic, ambient background for the Hero section.
* **How it works:** Fetches the top daily trending movies from TMDB and horizontally scrolls their posters in a continuous loop.
* **User interactions:** Passive (ambient motion). Respects system `prefers-reduced-motion` settings.
* **Backend logic:** N/A.
* **Related database entities:** N/A.
* **Dependencies:** TMDB API, custom `useTrendingMovies` hook.
* **Current Status:** Fully implemented.

### Feature Showcase (Matte Ticket Deck)
* **Purpose:** Highlights the core value propositions of the mobile app (Taste DNA, Swipe Deck, Hidden Gems, Dynamic Watchlist).
* **How it works:** Displays an interactive deck of cards. On desktop, they cycle automatically; on mobile, they use a scrollable snap carousel.
* **User interactions:** Scrolling, passive viewing.
* **Backend logic:** N/A.
* **Related database entities:** N/A.
* **Dependencies:** Framer Motion, inline SVG definitions.
* **Current Status:** Fully implemented.

## 5. User Roles

* **Anonymous Visitor:** 
  * **Permissions:** Full read access to the page.
  * **Capabilities:** Can view all content and click external links (Download APK, GitHub).
  * **Restrictions:** Cannot log in or modify state.

## 6. Application Flow

1. **Landing:** Visitor arrives at the root URL.
2. **Hero Engagement:** Visitor is presented with the primary value proposition ("Stop scrolling. Start watching.") layered over the ambient trending marquee.
3. **Exploration:** Visitor scrolls down to the Feature Showcase, viewing the physical ticket motifs.
4. **Comprehension:** Visitor scrolls to "How it Works" to understand the mobile app's flow.
5. **Conversion (CTA):** Visitor clicks the "Download APK" or "Get Started" buttons to download the mobile application.
6. **Registration / Login / Settings / Error States:** N/A (Stateless landing page).

## 7. Pages / Screens

### Index Page (`/`)
* **Purpose:** Single point of entry and conversion.
* **Components:** 
  * `Hero`: Main hook and call-to-action.
  * `TrendingMarquee`: Cinematic background for the Hero.
  * `FeatureShowcase`: Deck of value propositions.
  * `HowItWorks`: Step-by-step app breakdown.
  * `FooterCTA`: Final conversion prompt.
* **Navigation:** Single page scrolling.
* **User Actions:** Scrolling, clicking download links.
* **Data Displayed:** Static marketing copy, dynamic movie posters from TMDB.
* **Connected APIs:** TMDB API.

## 8. Data Model

* **Main entities:** N/A (No database).
* **Relationships:** N/A.
* **CRUD operations:** N/A.
* **Data lifecycle:** The only dynamic data is the TMDB movie list, which is fetched on client mount and held in React memory state for the duration of the session.

## 9. Business Logic

* **Rules:** 
  * The Trending Marquee must filter out posters with low vote counts to maintain a high-quality visual bar.
  * Animations must automatically disable themselves if the user's OS has `prefers-reduced-motion` enabled.
* **Validation:** N/A.
* **Automations:** `DesktopDeck` automatically cycles feature cards every 3 seconds unless reduced motion is active.
* **Permissions / Workflows:** N/A.

## 10. Integrations

* **The Movie Database (TMDB) API:** 
  * *Why it exists:* To provide real, recognizable movie posters for the background rather than generic placeholder art.
  * *How it is used:* A `GET` request to `/trending/movie/day` is made on mount.
  * *Where it is used:* Inside the `TrendingMarquee` component within the `Hero` section.

## 11. Design System

* **Colors:** Deep charcoal backgrounds (`#030305`, `#0d0d0f`) with high-contrast, vibrant accents (Indigo `#6B4EFF`, Cyan `#00F0FF`, Amber `#FFC107`).
* **Typography:** `Outfit` (or similar modern sans) for Display/Headlines, `Inter` (or similar readable sans) for Body text.
* **Components:** 
  * *Glass Buttons:* Translucent, blurred buttons with gradient borders.
  * *Matte Tickets:* Opaque charcoal cards simulating physical cardstock with SVG noise, deep cutouts (sprocket holes), and foil-stamped borders.
* **Layout principles:** Cinematic edge-to-edge designs, deep drop shadows for Z-axis depth, and heavy use of negative space.
* **Branding:** Dark, tactile, and highly premium. Avoids standard SaaS "flat" design in favor of physical, skeuomorphic touches (foil, cardstock).
* **UI patterns:** Scroll-triggered reveals, continuous ambient motion.

## 12. Technical Decisions

* **React + Vite:** Chosen for blazing-fast local development and optimal production bundling.
* **Tailwind CSS v4:** Used for utility-first styling, enabling rapid iteration on complex UI components without leaving the TSX files.
* **Framer Motion:** Chosen over standard CSS transitions to handle the complex, orchestrated spring animations and scroll-linked transforms required for the highly polished feel.
* **SVG Masking (Tickets):** Instead of using PNG/WebP images for the ticket cards, pure CSS `mask-image` with inline SVGs was used. This ensures infinite scaling without pixelation, allows the background to truly shine through the cutouts, and keeps the bundle size negligible.

## 13. Known Limitations

* **Existing issues:** The TMDB API key is currently exposed in the client-side bundle.
* **Technical debt:** The exposed API key should ideally be moved behind a lightweight edge function (e.g., Vercel Edge / Cloudflare Worker) to prevent abuse if the site scales.
* **Missing features:** None for the current landing page scope.
* **Planned improvements:** None currently.

## 14. Future Roadmap

* **Planned features:** N/A for the landing page.
* **Long-term vision:** If the Pickd ecosystem expands to include a web-based swiping client, this repository would serve as the foundation, expanding from a static site into a fully authenticated React application.
* **Expansion ideas:** Integrating a live "Swipe Demo" directly on the landing page before users download the APK.

## 15. Project Summary

Pickd Web is a highly polished, single-page promotional application built with React, Vite, and Tailwind CSS. Its sole purpose is to drive conversions for the Pickd mobile app by offering a premium, cinematic first impression. The site features ambient animations powered by real-time TMDB data and relies heavily on a bespoke "Matte Cardstock" design system using advanced SVG masking and Framer Motion physics. It is completely stateless, requiring no backend or authentication, and is ready for static deployment.
