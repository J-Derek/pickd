<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
<div align="center">

[![React][React-shield]][React-url]
[![Vite][Vite-shield]][Vite-url]
[![TypeScript][TypeScript-shield]][TypeScript-url]
[![Tailwind CSS][Tailwind-shield]][Tailwind-url]
[![Framer Motion][Framer-shield]][Framer-url]
[![MIT License][License-shield]][License-url]

</div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/J-Derek/pickd">
    <img src="public/logo.jpg" alt="Pickd Logo" width="80" height="80" style="border-radius: 18px;" />
  </a>

  <h1 align="center">Pickd Web</h1>

  <p align="center">
    The cinematic marketing and showcase landing page for <strong>Pickd</strong> — a mood-first movie discovery app.
    <br />
    <br />
    <a href="https://github.com/J-Derek/pickd"><strong>Explore the Main App Repo »</strong></a>
    <br />
    <br />
    <a href="https://github.com/J-Derek/pickd/releases">Download APK</a>
    ·
    <a href="https://github.com/J-Derek/pickd/issues">Report Bug</a>
    ·
    <a href="https://github.com/J-Derek/pickd/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage & Scene Architecture</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

**Pickd Web** is the official promotional and landing experience for **[Pickd](https://github.com/J-Derek/pickd)**, an indie, mood-based movie and series discovery mobile app.

Instead of presenting a typical generic SaaS landing page, Pickd Web is built as a continuous cinematic narrative designed to tackle streaming fatigue:
* **The Conflict**: Thousands of titles across streaming services, but still nothing to watch.
* **The Solution**: Direct taste-based movie recommendations with zero algorithmic noise or ratings bias.
* **The Delivery**: High-fidelity scroll choreography and lightweight client-side rendering.

> [!NOTE]
> This repository contains the **web landing site** built with React, Vite, and Framer Motion. The native mobile application itself (built with Flutter) is located in the primary repository: **[J-Derek/pickd](https://github.com/J-Derek/pickd)**.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![React][React-shield]][React-url]
* [![Vite][Vite-shield]][Vite-url]
* [![TypeScript][TypeScript-shield]][TypeScript-url]
* [![Tailwind CSS][Tailwind-shield]][Tailwind-url]
* [![Framer Motion][Framer-shield]][Framer-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get a local development copy up and running, follow these simple steps.

### Prerequisites

* **Node.js**: v18.0.0 or higher
* **npm** or **pnpm**

### Installation

1. Clone the repository
   ```sh
   git clone https://github.com/J-Derek/pickd.git
   cd pickd/pickd-web
   ```
2. Install dependencies
   ```sh
   npm install
   ```
3. Start the local Vite development server
   ```sh
   npm run dev
   ```
4. Open `http://localhost:8443` (or your configured port) in your browser.

> [!TIP]
> **No API Keys Required**: All movie posters and media in this landing page resolve through a curated, in-memory static cache (`STATIC_POSTERS`). First paint does not block on unbatched third-party API calls.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage & Scene Architecture

The web application is structured as five progressive scenes connected through directional scroll choreography:

### 1. The Hero Scene
* **Component**: `src/components/Hero.tsx` & `TrendingMarquee.tsx`
* **Experience**: Ambient dual-layer marquee of curated films with atmospheric depth blur, high-contrast typography, and an immediate APK download action.

### 2. The Problem Statement ("Another movie night.")
* **Component**: `src/components/ProblemStatement.tsx`
* **Experience**: Scroll-scrubbed typography that walks the visitor through modern streaming decision paralysis across major platforms.

### 3. The Manifesto Bridge ("YOUR TASTE. YOUR RULES.")
* **Component**: `src/components/Scene3.tsx`
* **Experience**: Converging typography sliding into alignment, presenting Pickd's anti-algorithm philosophy.

### 4. The Recommendation Journey
* **Component**: `src/components/Scene4.tsx`
* **Experience**: An interactive walkthrough of the app's three core onboarding steps: genre curation, movie seeding, and swipe deck generation.

### 5. Final Download & TMDB Colophon
* **Component**: `src/components/Scene5.tsx`
* **Experience**: Concluding download section with direct GitHub release link and compliant TMDB attribution.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

Current development status for `pickd-web`:

- [x] Full responsive desktop and mobile layouts (1366x768, 1440x900, iPhone/Android viewports)
- [x] Zero-latency static poster CDN caching (`TMDBPoster.tsx`)
- [x] TMDB Attribution and Terms of Service compliance
- [x] Custom cinematic 404 page (`/404`)
- [x] OpenGraph, Twitter Card, and SEO metadata
- [x] Clean multi-resolution Favicon support (`/favicon.ico`, `/favicon.png`)
- [ ] FAQ accordion section
- [ ] Interactive in-browser swipe demo widget
- [ ] Device carousel showcasing live in-app screenshots
- [ ] Version release notes & changelog modal

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions make the open source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

For questions, issues, or suggestions regarding Pickd, please open an issue on the primary repository:

* **Issue Tracker**: [https://github.com/J-Derek/pickd/issues](https://github.com/J-Derek/pickd/issues)
* **Main Project Link**: [https://github.com/J-Derek/pickd](https://github.com/J-Derek/pickd)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[React-shield]: https://img.shields.io/badge/React_19-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://react.dev/
[Vite-shield]: https://img.shields.io/badge/Vite_8-646CFF?style=for-the-badge&logo=vite&logoColor=white
[Vite-url]: https://vitejs.dev/
[TypeScript-shield]: https://img.shields.io/badge/TypeScript_5.7-3178C6?style=for-the-badge&logo=typescript&logoColor=white
[TypeScript-url]: https://www.typescriptlang.org/
[Tailwind-shield]: https://img.shields.io/badge/Tailwind_CSS_v4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white
[Tailwind-url]: https://tailwindcss.com/
[Framer-shield]: https://img.shields.io/badge/Framer_Motion-0055FF?style=for-the-badge&logo=framer&logoColor=white
[Framer-url]: https://www.framer.com/motion/
[License-shield]: https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge
[License-url]: https://opensource.org/licenses/MIT
