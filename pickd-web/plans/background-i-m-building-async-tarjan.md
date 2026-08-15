# Assessment & Cleanup Plan — Pickd landing page

## Context

All six sections are built (`src/components/{Hero,HowItWorks,FeatureBento,Waitlist,Feedback,Footer}.tsx`), plus
`src/components/Phone.tsx` and `src/hooks/useReveal.ts`, wired through `src/App.tsx`. The build is clean. This
pass is an assessment of what's actually correct versus what will misbehave at runtime or drift from the
project's documented conventions, followed by a short remediation list.

## What checks out

- **Screenshot URLs are real.** Verified against the GitHub API: `J-Derek/Pickd` is public, and all three
  referenced files exist at `assets/screenshots/` on `main` (`02_mood_selection.png`, `04_swipe_deck.png`,
  `07_watchlist.png`). `/releases` also resolves, so the download CTAs are live. No broken images.
- **Design tokens match the brief** — `@theme` in `src/index.css` carries ink `#0A0A0F`, indigo `#6B4EFF`,
  cyan `#00F0FF`, gold `#FFC107`, pink `#FF4081`; Inter is loaded via a CSS2 `@import` placed before
  `@import 'tailwindcss'`, which is the correct ordering.
- **Reveal system is sound.** `useReveal` disconnects on first intersect, bails to visible under
  `prefers-reduced-motion`, and the CSS mirrors that with a reduce block.
- **Forms are correct as front-end-only.** Validation, error clearing on edit, loading state, `role="alert"` /
  `aria-live`, `sr-only` labels, and terminal success states are all present.

## Issues to fix

1. **Sticky header never sticks** (`src/components/Hero.tsx:8`, `:53`). The header is
   `sticky top-0` but its ancestor `<section>` has `overflow-hidden`, which makes that section the scroll
   container — the header just scrolls away with the hero. Fix: lift the `<header>` out of `Hero` into
   `App.tsx` as a sibling above the sections (or move `overflow-hidden` onto the inner glow wrapper only,
   which already has its own `overflow-hidden` div at `:10`).

2. **Unlayered universal selector** (`src/index.css:41`). `* { box-sizing; scrollbar-width: none }` sits
   outside any cascade layer and overrides Tailwind's layered preflight. `box-sizing` is redundant (preflight
   already sets it) — drop it. The site-wide scrollbar hiding is also a usability regression: it removes the
   only scroll affordance on a long page. Remove both, or scope the scrollbar rule to a specific element.

3. **Inline styles instead of Tailwind.** `AGENTS.md` specifies Tailwind utilities in JSX, but the components
   are ~90% inline `style` objects with hardcoded hex literals, so the `@theme` tokens are declared and never
   used — a token change won't propagate. Convert to utilities (`bg-ink`, `text-secondary`, `border-border`,
   `text-indigo`) and keep inline styles only for genuinely dynamic values (3D transforms, radial glows).
   Same for the JS hover handlers in `Footer.tsx:82` and `Hero.tsx:83` — those should be `hover:` classes.

4. **Dead footer links** (`src/components/Footer.tsx:42`). Privacy Policy and Terms point at `#`, and the
   social links point at bare `twitter.com` / `linkedin.com` rather than real profiles. Either supply real
   URLs or drop the placeholders — dead links read worse than absence on a launch page.

5. **Minor:** the hero's `repeat(auto-fit, minmax(300px, 1fr))` grid keeps two columns down to ~700px, where
   the copy column gets cramped before it wraps. A `md:grid-cols-2` breakpoint gives a cleaner handoff.

## Suggested order

Fix 1 and 2 first (behavioral), then 4 (content), then 3 as a sweep across all six components, then 5.
Item 3 is the largest and is a refactor with no visual delta — it can be deferred if you'd rather ship.

## Verification

- Preview the running dev server: scroll the full page and confirm the header stays pinned past the hero,
  the scrollbar is visible, and all three phone screenshots render.
- Submit both forms with an invalid then a valid email; confirm the error and success states.
- Toggle OS "reduce motion" and reload; sections should appear immediately with no float/tilt animation.
- Narrow to ~375px and confirm the bento grid stacks and the hero collapses to one column.
