<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

## PICKD Landing Page — Complete Scene Specification (v2, Tokens Corrected)


***

## A. Scene 4 (Recommendation Journey) — Corrected Tokens + Fixes

### Updated Design Tokens (Applied Throughout)

**Colors**

- Ink: `#0A0A0F` (was `#0A0A0A`)
- Indigo: `#6B4EFF` ✓
- Cyan: `#00F0FF` ✓
- Gold: `#FFC107` ✓

**Typography**

- Display: `Sora` (`var(--font-display)`)
- Body: `Inter` (`var(--font-body)`)
- Hero headline scale: `text-[4rem]` → `lg:text-[9rem]`, `leading-[0.95]`, `tracking-tighter`
- Scene 4 headlines updated to match: `text-[3.5rem]` → `lg:text-[7rem]`

**Spacing**

- Base: `8px`
- Section padding: `120px` desktop / `80px` mobile
- Max-width: `1200px`

***

### Chapter-by-Chapter Spec (With Responsive + Reduced Motion)

#### Chapter 1: "WHAT'S THE VIBE?"

**Desktop Layout**

- Headline: `text-[3.5rem] lg:text-[7rem] font-semibold leading-[0.95] tracking-tighter text-white`, centered, `mb-32`
- Phone: `w-[390px] h-[844px]` at `60vh` from top, centered
- Screenshot: `/screenshots/02_mood_selection.png` (full bleed inside phone)
- Background: `bg-[#0A0A0F]` with static radial gradient (pre-rendered PNG, `opacity-5`, `w-[800px]`)

**Responsive Breakpoints**

- `lg` (1024px+): Phone `390x844px`
- `md` (768-1023px): Phone `320x693px` (scale 0.82)
- `sm` (<768px): Phone `280x605px` (scale 0.72), headline `text-[2.5rem] lg:text-[5rem]`

**Motion (Normal)**

- Enter: `opacity: 0→1`, `scale: 0.98→1` over `800ms` ease-out
- Hold: Static for 40% scroll distance
- Exit: `opacity: 1→0.8`, `scale: 1→0.95`

**Reduced Motion**

- Enter: `opacity: 0→1` only (no scale), `400ms`
- Hold: Static
- Exit: `opacity: 1→0` only (no scale), `300ms`

***

#### Chapter 2: "PICK 3 MOVIES YOU LOVE"

**Desktop Layout**

- Headline: Same scale as Chapter 1, crossfade transition
- Phone: Same dimensions, fixed position
- Screenshot: `/screenshots/03_pick3.png` (3 selected cards visible)

**Responsive**

- Same scaling as Chapter 1

**Motion (Normal)**

- Transition: Phone fixed, screenshot crossfade `300ms`
- Cards: Subtle parallax `translateY: 0→20px` over scroll
- Hold: 50% scroll distance

**Reduced Motion**

- Crossfade only, no parallax
- Hold duration unchanged

***

#### Chapter 3: "Taste, established."

**Desktop Layout**

- Headline: `text-[1.5rem] lg:text-[2rem] font-medium text-white/60`, centered, `mt-48`
- Cards: 3 cards from screenshot, now floating (no phone)
    - Dimensions: `280x420px` each
    - Gap: `24px` → converges to `8px`
    - Shadow: `shadow-2xl` (blur `40px`, `opacity-30`, `y-5`)

**Responsive**

- `md`: Cards `240x360px`, gap `16px` → `6px`
- `sm`: Cards `200x300px`, gap `12px` → `4px`, headline `text-[1.25rem]`

**Motion (Normal)**

- Phone fade: `opacity: 1→0` over `600ms`
- Card convergence: `gap: 24px→8px`, `translateX` to center
- Hold: 400ms pause after convergence

**Reduced Motion**

- Phone fade: `opacity: 1→0` over `300ms`
- Cards: Instant position (no convergence animation)
- Hold: Unchanged

***

#### Chapter 4: Deck Creation

**Desktop Layout**

- Cards stacked: `translateY: 0, 2px, 4px` per card
- Rotation: `rotateZ: 0°, 1°, 2°`
- Deck edge: `2px` indigo right border (`opacity-20`)

**Responsive**

- Same proportions, scaled to card size

**Motion (Normal)**

- Stack: `spring` (stiffness `200`, damping `25`)
- Breath: `scale: 1.0→1.02→1.0` over `3s` infinite

**Reduced Motion**

- Stack: Instant position (no spring)
- Breath: Disabled (static at `scale: 1.0`)

***

#### Chapter 5: Real Swipe Product

**Desktop Layout**

- Screenshot: `/screenshots/04_swipe_deck.png` (full product UI)
- Gesture hint: Arrow icon, `opacity-40`, `translateX: 0→20px` loop

**Responsive**

- Screenshot scales with card size

**Motion (Normal)**

- Reveal: Deck `scale: 1.0→0.9`, screenshot `opacity: 0→1` over `600ms`
- Gesture: `translateX: 0→20px→0` over `2s` infinite

**Reduced Motion**

- Reveal: Opacity crossfade only (no scale)
- Gesture: Disabled

***

#### Chapter 6: Phone Dissolve

**Desktop Layout**

- Layers: Bezel → Status bar → Notch → Shadow → Border (each `opacity: 1→0`)

**Responsive**

- Same sequence, scaled

**Motion (Normal)**

- Dissolve: Each layer `200ms` fade, staggered `100ms` (total `1.2s`)
- Hold: 300ms stillness

**Reduced Motion**

- All layers: Instant fade (no stagger), total `300ms`
- Hold: Unchanged

***

#### Chapter 7: Deck in Web Space

**Desktop Layout**

- Background: Static pre-rendered noise texture (PNG, `opacity-[0.02]`)
- Deck: Native web element, hover states active
- Hover: `scale: 1.03`, `shadow-2xl` intensifies

**Responsive**

- Texture: Same opacity, scaled
- Hover: Reduced scale `1.02` on mobile

**Motion (Normal)**

- Background parallax: `translateY: 0→10%` of scroll (10% speed)
- Hover: `transition: transform 200ms, box-shadow 200ms`

**Reduced Motion**

- Parallax: Disabled
- Hover: Opacity change only (no scale/shadow interpolation)

***

#### Chapter 8: Recommendation Growth

**Desktop Layout**

- New cards: 3 additional (TMDB sourced, see original spec)
- Entry: `fade + translateY: 40px→0 + scale: 0.95→1.0`

**Responsive**

- Card size scales with deck

**Motion (Normal)**

- Each card: `400ms` enter, `200ms` stagger
- Settle: `spring` (stiffness `300`, damping `30`)
- Pause: 400ms between cards

**Reduced Motion**

- Each card: `opacity: 0→1` only (no transform), `200ms`
- Settle: Instant position
- Pause: Unchanged

***

#### Chapter 9: "READY."

**Desktop Layout**

- Headline: `text-[4rem] lg:text-[9rem] font-semibold leading-[0.95] tracking-tighter text-white`, centered
- Subtext: `text-[1.125rem] lg:text-[1.25rem] text-white/60`, `mt-6`
- CTA: `h-12 px-10 bg-[#6B4EFF] text-white rounded-full font-medium hover:bg-[#7B5EFF] transition-colors`
- Deck: `blur-sm opacity-40` (static blur, not animated)

**Responsive**

- `md`: Headline `text-[3rem] lg:text-[7rem]`
- `sm`: Headline `text-[2.5rem] lg:text-[5rem]`, subtext `text-[1rem]`

**Motion (Normal)**

- Headline: `opacity: 0→1`, `scale: 0.9→1.0` over `800ms`
- CTA: `translateY: 20px→0`, `opacity: 0→1` over `600ms`, delay `200ms`
- Deck fade: `opacity: 1→0.4` over `800ms`

**Reduced Motion**

- Headline: `opacity: 0→1` only, `400ms`
- CTA: `opacity: 0→1` only (no translateY), `300ms`
- Deck fade: `opacity: 1→0.4` over `300ms`

***

## B. Scene 3: "Establish Pickd's Different Approach"

**Purpose**: Bridge from "Sounds familiar?" (problem statement) into Scene 4's "WHAT'S THE VIBE?" (solution opener). Resolves tension, hands off cleanly.

### Story Beat

- Problem (from Scene 2): "Endless scrolling. Generic recommendations. Algorithms that don't know you."
- Resolution: "Pickd starts with taste, not data."
- Handoff: Phone appears, ready for mood input (Scene 4 Chapter 1)


### Layout

**Desktop**

- Headline: `text-[3.5rem] lg:text-[7rem] font-semibold leading-[0.95] tracking-tighter text-white`, centered
- Subhead: `text-[1.5rem] lg:text-[2rem] text-white/70`, `mt-8`, max-w `600px`, centered
- Visual: 3 movie cards (from Scene 2's problem) → transform into single phone (Scene 4's opener)

**Content**

```
Headline: "NOT ANOTHER ALGORITHM."
Subhead: "Pickd starts with what you love — not what everyone else watches."
```

**Visual Progression**

1. Three cards (Scene 2's "generic recommendations") float, spaced `120px` apart
2. Cards converge to center, `gap: 120px→24px`
3. Cards fade, phone fades in (Scene 4's phone, same position)
4. Phone shows mood selection (pre-loads Scene 4 Chapter 1)

### Responsive

- `md`: Cards `240x360px`, gap `80px→16px`
- `sm`: Cards `200x300px`, gap `60px→12px`, headline `text-[2.5rem] lg:text-[5rem]`


### Motion (Normal)

- Cards converge: `600ms` ease-out
- Cards fade: `opacity: 1→0` over `400ms`
- Phone fade: `opacity: 0→1` over `400ms`, delay `200ms`
- Hold: 400ms before Scene 4 Chapter 1 begins


### Reduced Motion

- Cards: Instant center position (no convergence)
- Crossfade: Cards `opacity: 1→0`, phone `opacity: 0→1` over `300ms`
- Hold: Unchanged


### Performance Notes

- Cards: Pre-rendered static assets (no live TMDB fetch)
- Phone: Same component as Scene 4 (no re-mount, just opacity swap)
- No additional loops or ambient animations

***

## C. Scene 5+: "Close the Film" (CTA + Footer)

**Purpose**: Resolve from Scene 4's "READY." state into download CTA and footer. Quiet, no new metaphors.

### Story Beat

- From "READY." (Scene 4 Chapter 9)
- To: "Download Pickd" + App Store badges
- To: Minimal footer (links, copyright)


### Layout

**Desktop**

- Headline: `text-[4rem] lg:text-[9rem] font-semibold leading-[0.95] tracking-tighter text-white`, centered
- Subhead: `text-[1.5rem] lg:text-[2rem] text-white/70`, `mt-8`, centered
- CTA Group: App Store + Google Play badges, `flex gap-6`, centered, `mt-12`
- Footer: `mt-32`, `text-[0.875rem] text-white/40`, centered
    - Links: "Privacy", "Terms", "Contact" (inline, `gap-8`)
    - Copyright: "© 2026 Pickd. All rights reserved."

**Content**

```
Headline: "START DISCOVERING."
Subhead: "Pickd is free on iOS and Android."
CTA: [App Store badge] [Google Play badge]
Footer: Privacy · Terms · Contact
         © 2026 Pickd. All rights reserved.
```


### Responsive

- `md`: Headline `text-[3rem] lg:text-[7rem]`, badges stacked vertically
- `sm`: Headline `text-[2.5rem] lg:text-[5rem]`, subhead `text-[1.25rem]`, footer links stacked


### Motion (Normal)

- Headline: `opacity: 0→1`, `scale: 0.95→1.0` over `800ms`
- Subhead: `opacity: 0→1`, `translateY: 20px→0` over `600ms`, delay `200ms`
- Badges: `opacity: 0→1`, `translateY: 20px→0` over `600ms`, delay `400ms`
- Footer: `opacity: 0→1` over `800ms`, delay `800ms`


### Reduced Motion

- All: `opacity: 0→1` only (no transform/scale), `400ms` each
- Delays: Unchanged


### Performance Notes

- Badges: Static PNG/SVG assets (no hover effects beyond `opacity`)
- Footer: No scroll-linked animations, no parallax
- One idle loop max: None (all static after enter)

***

## D. Performance Addendum: Hero + "Sounds Familiar?" Section

**Current Issues** (from §3):

1. 3-5 row infinite-scroll marquees running continuously
2. Animated `filter: blur()` interpolation (blur(12px) → blur(40px))
3. `mix-blend-mode: screen` layered on top
4. Real-time `requestAnimationFrame` mouse-tracked spotlight globally
5. Multiple `useSpring` chains driving parallax simultaneously

**Required Changes** (Visual Output Must NOT Change):

### 1. Infinite-Scroll Marquees

**Current**: Likely CSS `animation: scroll` or JS-driven `translateX` on loop
**Fix**:

- Convert to `transform: translateX()` only (no layout properties)
- Pause animation when section is out of viewport (IntersectionObserver)
- Reduce from 3-5 rows to 2 rows on mobile (preserve look, reduce cost)

```css
/* Before */
.marquee {
  animation: scroll 30s linear infinite;
}

/* After */
.marquee {
  transform: translateX(0);
  will-change: transform;
}

.marquee.paused {
  animation-play-state: paused;
}
```

```jsx
// Pause when out of viewport
const { ref } = useInView({
  onChange: (inView) => {
    marqueeRef.current?.style.animationPlayState = inView ? 'running' : 'paused';
  }
});
```


### 2. Animated Blur Filter

**Current**: `filter: blur(12px)` → `blur(40px)` interpolated on scroll
**Fix**:

- Replace with pre-blurred image assets (blur 12px, 24px, 40px versions)
- Crossfade between versions on scroll (opacity only, no filter interpolation)

```jsx
// Before
const blur = useTransform(scrollYProgress, [0, 1], [12, 40]);
<div style={{ filter: `blur(${blur}px)` }} />

// After
const opacity12 = useTransform(scrollYProgress, [0, 0.3], [1, 0]);
const opacity24 = useTransform(scrollYProgress, [0.2, 0.5], [0, 1, 0]);
const opacity40 = useTransform(scrollYProgress, [0.4, 1], [0, 1]);

<img src="/blur-12.png" style={{ opacity: opacity12 }} />
<img src="/blur-24.png" style={{ opacity: opacity24 }} />
<img src="/blur-40.png" style={{ opacity: opacity40 }} />
```


### 3. mix-blend-mode: screen

**Current**: Likely layered on multiple elements
**Fix**:

- Keep `mix-blend-mode` but reduce layer count (max 2 layers with blend)
- Ensure layers are `position: absolute` with `will-change: transform`

```css
.blend-layer {
  mix-blend-mode: screen;
  will-change: transform;
  transform: translateZ(0); /* Force GPU */
}
```


### 4. Mouse-Tracked Spotlight

**Current**: `requestAnimationFrame` updating `x/y` on every mouse move
**Fix**:

- Throttle to `16ms` (60fps cap) using `requestAnimationFrame` properly
- Use `transform: translate()` only (no `top/left`)
- Disable spotlight on mobile (touch devices)

```jsx
// Before
useEffect(() => {
  const handleMove = (e) => {
    spotlightRef.current.style.left = e.clientX + 'px';
    spotlightRef.current.style.top = e.clientY + 'px';
  };
  window.addEventListener('mousemove', handleMove);
}, []);

// After
useEffect(() => {
  if ('ontouchstart' in window) return; // Disable on mobile
  
  let rafId;
  const handleMove = (e) => {
    if (rafId) return;
    rafId = requestAnimationFrame(() => {
      spotlightRef.current.style.transform = `translate(${e.clientX}px, ${e.clientY}px)`;
      rafId = null;
    });
  };
  window.addEventListener('mousemove', handleMove);
  return () => cancelAnimationFrame(rafId);
}, []);
```


### 5. Multiple useSpring Chains

**Current**: Several springs running simultaneously for parallax
**Fix**:

- Consolidate to single `useTransform` chain (no spring physics for scroll-linked)
- Use `useScroll` with `target` ref (not global window scroll)

```jsx
// Before
const y1 = useSpring(useTransform(scrollYProgress, [0, 1], [0, 100]));
const y2 = useSpring(useTransform(scrollYProgress, [0, 1], [0, 50]));
const y3 = useSpring(useTransform(scrollYProgress, [0, 1], [0, 30]));

// After
const { scrollYProgress } = useScroll({ target: sectionRef });
const y1 = useTransform(scrollYProgress, [0, 1], [0, 100]);
const y2 = useTransform(scrollYProgress, [0, 1], [0, 50]);
const y3 = useTransform(scrollYProgress, [0, 1], [0, 30]);
```


### 6. General Performance Checklist

- [ ] All animations use `transform` + `opacity` only
- [ ] No `filter: blur()` animated live
- [ ] Max 1 idle loop per viewport (pause when out of view)
- [ ] Hover effects inert until hovered (no pre-computed states)
- [ ] Noise/texture: static pre-rendered assets only
- [ ] `prefers-reduced-motion`: All animations collapse to opacity crossfade
- [ ] Mobile: Reduce complexity (fewer rows, smaller cards, no spotlight)

***

## Implementation Priority

1. **Scene 4** (corrected tokens + responsive + reduced motion) — Lock first
2. **Performance fixes** on Hero/"Sounds familiar?" — Parallel pass
3. **Scene 3** — Bridge from Scene 2 to Scene 4
4. **Scene 5+** — Close the film (CTA + footer)

All scenes use the same token system, motion vocabulary, and performance constraints. No new metaphors, no decorative effects, no "AI slop" tells.
<span style="display:none">[^1][^10][^11][^12][^13][^14][^15][^16][^17][^18][^19][^2][^20][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://fontalternatives.com/fonts/sora/

[^2]: https://lexingtonthemes.com/blog/inter-stylistic-sets-css-tailwind

[^3]: https://tailwindcss.com/plus/ui-blocks/documentation

[^4]: https://github.com/imsus/tailwind-plugin-font-inter

[^5]: https://fonts.google.com/specimen/Sora

[^6]: https://dev.to/dog_smile_factory/5-reasons-to-give-inter-fonts-a-try-46i2

[^7]: https://github.com/tailwindlabs/tailwindcss/discussions/15415

[^8]: https://typeyeah.com/fonts/sora/

[^9]: https://elixirforum.com/t/help-with-adding-font-inter/50303

[^10]: https://github.com/tailwindlabs/tailwindcss/discussions/10909

[^11]: https://www.framer.com/help/articles/reduced-motion-settings/

[^12]: https://app.unpkg.com/framer-motion@8.2.0/files/dist/es/utils/reduced-motion/use-reduced-motion.mjs

[^13]: https://www.digitizia.com/blog/prefers-reduced-motion-react-nextjs-guide

[^14]: https://elijahmanor.com/blog/prefers-reduced-motion

[^15]: https://www.modern-framework-accessibility.com/core-accessibility-principles-for-modern-frameworks/reduced-motion-and-animation-accessibility/respecting-prefers-reduced-motion-in-react-and-css

[^16]: https://dev.to/childrentime/react-usereducedmotion-hook-respect-prefers-reduced-motion-2026-58i8

[^17]: https://zoer.ai/posts/zoer/best-react-scroll-animation-libraries-2025

[^18]: https://dev.to/shoaibsid/building-scalable-ui-systems-with-tailwind-css-v4-and-shadcnui-59o4

[^19]: https://github.com/vercel-labs/open-agents/blob/main/.agents/skills/web-animation-design/SKILL.md

[^20]: https://react-news.com/a-deep-dive-into-scroll-based-animations-with-framer-motion-and-react

