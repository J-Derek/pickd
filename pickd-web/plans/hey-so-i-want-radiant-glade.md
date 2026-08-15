# Pickd Landing Page

## Context

Derek has a Flutter app, **Pickd** (github.com/J-Derek/Pickd) — a mood-based movie/TV matchmaker with a premium cinematic dark UI. He needs a marketing landing page that is visually consistent with the app: same palette, same typographic feel, same glassmorphic/high-contrast vibe. The page drives one primary action (Download APK) plus an iOS waitlist and a feedback channel.

Rather than wireframing in Figma first, we build directly against the app's **real** design tokens, which I extracted from `lib/core/config/app_theme.dart` in the repo:

| Token | Hex | Role |
|---|---|---|
| `bg-primary` | `#0A0A0F` | OLED black page base |
| `bg-surface` | `#13131A` | Cards (used at 60% alpha for glass) |
| `bg-elevated` | `#1C1C26` | Raised surfaces, inputs |
| `bg-muted` | `#252530` | Borders, dividers |
| `accent-primary` | `#6B4EFF` | Neon indigo — primary CTA, glows |
| `accent-secondary` | `#00F0FF` | Electric cyan — secondary accent |
| `gems` | `#FFC107` | Gold — hidden gems |
| `pink` | `#FF4081` | Neon pink — hearts/saves |
| `text-primary / secondary / muted` | `#FFFFFF` / `#B0B0C0` / `#6B6B80` | Type scale |

The app also uses a **pink → gold gradient** (`#FF4081` → `#FFC107`) — that becomes the page's signature gradient for headline emphasis and the swipe-right motif.

The app's font is SF Pro Display/Text. On web the faithful equivalent is a system stack with **Inter** as the loaded fallback, so the page reads identically on Apple devices and stays on-brand elsewhere.

Forms are **front-end only** per Derek's decision: real validation, real loading + success states, no backend or database.

## Approach

Single-page React app in the existing Vite + Tailwind v4 scaffold. Replace the placeholder `src/App.tsx` entirely.

### Files

- `src/index.css` — Google Fonts `@import` for Inter (must be the first statement, before `@import 'tailwindcss'` — CSS requires all `@import` rules precede other statements), then a Tailwind v4 `@theme` block defining the token table above as `--color-*` custom properties so every section uses `bg-bg-primary`, `text-accent-primary`, etc. rather than hex literals. Also: `font-family` default on `body`, and a couple of keyframes (slow float for the phone mockup, shimmer for the gradient text).
- `src/App.tsx` — page shell: background layers + section composition only.
- `src/components/` — one file per section, default-exported:
  - `Hero.tsx`, `HowItWorks.tsx`, `FeatureBento.tsx`, `Waitlist.tsx`, `Feedback.tsx`, `Footer.tsx`
  - `Phone.tsx` — reusable device frame wrapper (bezel, rounded corners, screen glow) that takes a screenshot `src` and optional tilt; used in both Hero and How It Works.

### Imagery

Screenshots load straight from GitHub raw (verified 200 OK):
`https://raw.githubusercontent.com/J-Derek/Pickd/main/assets/screenshots/{02_mood_selection,04_swipe_deck,07_watchlist}.png`

Note `07_watchlist.png` is ~1.4 MB — add `loading="lazy"` on the below-fold ones. If load speed becomes an issue later, we download them into `public/` and compress.

### Sections

1. **Hero** — sticky glass header (Pickd wordmark left, "Download" ghost button right). Ambient radial indigo/cyan glow behind the fold. Headline "Stop scrolling. Start watching." with "watching" carrying the pink→gold gradient. Subheadline, then a large indigo CTA with an outer glow ring + subtle press physics, and a muted "Free · Android · ~25 MB" line beneath. Right side: `04_swipe_deck.png` in a 3D-tilted phone (`rotateY`/`rotateX` via transform, gentle float animation, pink and gold "like/pass" badge chips floating off the card edges to telegraph the swipe mechanic).
2. **How It Works** — three steps, alternating or staggered so it doesn't read as a plain 3-column row. Big ghosted step numerals (01/02/03) in `text-muted`, phone screenshots for mood selection → swipe deck → watchlist, with the connecting thread drawn as a thin gradient line between them.
3. **Feature Bento** — asymmetric CSS grid (not 4 equal squares): one wide cell for cross-device sync, one tall for Hidden Gems (gold accent), two smaller for offline caching and TV+Movies. Glass surfaces (`bg-surface/60` + `backdrop-blur` + 1px `bg-muted` border), each with a hairline top highlight and a hover lift that brightens its accent glow. Inline SVG icons, one per cell — no icon library.
4. **Waitlist** — "Want Pickd on iOS?" Centered, narrow. Single email input on `bg-elevated` with a focus ring in cyan, inline button. Validates with a regex, shows an error line for bad input, and swaps the whole control for a check-mark success state with the entered address echoed back. Local `useState` only.
5. **Feedback** — "Got a feature idea or found a bug?" Two-column grid on desktop (Name / Email), then a styled native `<select>` (Bug / Feature Request), then a textarea. Required-field validation on submit, brief simulated pending state, then a success panel. CTA reads "Send to Derek".
6. **Footer** — wordmark + "© 2026 Pickd", GitHub repo link, Privacy Policy / Terms links (placeholder `#` hrefs — flagging that these pages don't exist yet), X and LinkedIn as inline SVGs.

### Craft details

- Responsive: mobile-first; hero stacks with the phone below the copy, bento collapses to one column, feedback form to single column.
- Motion: an `IntersectionObserver`-driven `useReveal` hook in `src/hooks/useReveal.ts` for fade-and-rise on section entry; everything wrapped in a `prefers-reduced-motion` guard.
- Accessibility: real `<label>`s (visually hidden where the design wants placeholder-only), `aria-live` on form success/error regions, visible focus rings, and contrast checked for `text-muted` on `bg-primary`.
- I'll invoke the `aesthetic-stance` skill and `create_make_theme` before writing code to lock the art direction, but the palette above is fixed — it comes from the app and is not up for reinterpretation.

## Verification

- Dev server is already running on `$PORT`; open the preview and check the page top to bottom at desktop and mobile widths.
- Confirm all three GitHub-hosted screenshots render (not broken images).
- Exercise both forms: submit empty (expect errors), submit a malformed email (expect error), submit valid input (expect success state).
- Tab through the page to confirm focus order and visible focus rings.
- Only if something looks broken: `figma logs` for runtime errors.
