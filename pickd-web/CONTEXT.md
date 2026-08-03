# Pickd Web Landing Page (pickd-web)

## Context
`pickd-web` is the dedicated web landing page for the core **Pickd** mobile application (built in Flutter). Its primary purpose is to serve as the marketing and conversion funnel for the mobile app, providing users with a clear understanding of the app's value proposition and driving downloads. It is a standalone React + Vite SPA nested within the main repository.

## MVP (Minimum Viable Product)
The initial MVP for the landing page requires:
1. **High-Conversion Hero**: A strong value proposition, tagline, and immediate app download CTAs.
2. **Feature Showcase**: A visual breakdown of the app's core features (e.g., swiping, picking, matching) with premium animations.
3. **How It Works**: A step-by-step visual guide (using phone mockups) explaining the user journey.
4. **App Store Links**: Direct links to the iOS App Store and Google Play Store (currently placeholder anchors `#`).
5. **Brand Alignment**: Must reflect the Pickd brand identity with a high-end, polished aesthetic free of "AI slop" (enforced via `hallmark`).

## UI & Aesthetic Description
The UI is designed to feel **modern, premium, and dynamic**, utilizing Human-Computer Interaction (HCI) best practices:

- **Theme**: Dark-mode biased or highly vibrant, leveraging deep contrast to make UI mockups pop.
- **Glassmorphism**: Extensive use of frosted glass effects (e.g., `GlassButton.tsx`) for floating elements, giving depth and a modern OS feel.
- **Motion & Micro-interactions**: Powered by `framer-motion`. Elements should have smooth entrance animations, hover states, and scroll-triggered reveals, respecting `useReducedMotion` for accessibility.
- **Typography**: Clean, sans-serif, high-legibility fonts with strong visual hierarchy (distinct `h1`, `h2`, and readable body text).
- **Component Breakdown**:
  - `Navbar`: Sticky, glass-effect navigation with a quick-access download button.
  - `Hero`: Centered, high-impact typography with primary CTAs.
  - `FeatureShowcase` / `FeatureCard`: Interactive cards detailing specific app capabilities.
  - `HowItWorks` / `PhoneMockup`: A visual step-by-step guide anchoring the UI to a familiar mobile form factor.
  - `FooterCTA`: A final, bold push for user acquisition before the page ends.

## Pending Work (Current Session)
- Swap out generic vector placeholders for real Flutter app screenshots.
- Integrate the official Pickd logo.
- Conduct a formal `hallmark audit` to ensure anti-slop design compliance.
- Resolve dead-links for download CTAs.
