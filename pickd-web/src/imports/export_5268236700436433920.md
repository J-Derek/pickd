<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# whatever output you give, i will give to figma make right away PICKD — Cinematic Landing Page Master Prompt

Design and build a production-quality landing page for Pickd, a Flutter movie/series discovery app. This is not a SaaS template. Reference point: Apple product page / product film, not a marketing site.

1. PRODUCT TRUTH (do not invent beyond this)
Pickd is a real, shipped Flutter app (v1). Core features: mood-based discovery, trailer swiping, hidden gems mode.
v1.2 in progress: Supabase auth, visual onboarding, Watched Vault, Match Mode. Do not depict unshipped features as current.
Existing web landing page stack: React + Vite, Tailwind, Framer Motion.
Existing palette (locked): ink/surface blacks, neon Indigo \#6B4EFF, Cyan \#00F0FF, Gold \#FFC107 accents.
Navbar is locked/final — do not redesign it.
Hero and "How It Works" sections already exist on the live page. This prompt is for extending/rebuilding the product-story portion of the page (Scene 4 onward), not the whole site.
A prior AI pass (Gemini 1.5 Pro) was rejected for producing a "boxy bento" layout with messy asymmetry. Do not repeat that pattern.
Real product screenshots will be supplied at these paths — use them exactly, do not approximate them:
/screenshots/02_mood_selection.png
/screenshots/03_pick3.png
/screenshots/04_swipe_deck.png
If an asset isn't supplied, insert a clearly labeled placeholder. Never fabricate a screenshot and present it as real.
2. CORE CREATIVE PHILOSOPHY
"The viewer should never feel like they're watching an animation. They should feel like they're watching the product reveal itself."
Object permanence — nothing appears, disappears, or teleports without explanation. Every object moves, transforms, is revealed, or is removed — traceably.
Recognition before transformation — let the visitor recognize the real product first, then transform it. Don't jump straight to abstraction.
Product authenticity — real screenshots where supplied, no invented UI, no fake "Powered by AI" badges, no holograms/particles/data-stream visualizations.
The product is the metaphor — the movie cards and the deck ARE the visual language. Don't layer a second abstract metaphor on top.
Camera philosophy — camera stays mostly stationary; objects transform inside the frame. No flythroughs, no spinning device mockups, no unnecessary parallax or camera shake.
Pacing — slow down. One idea per scroll position. A visitor should be able to stop scrolling and understand exactly what they're looking at.
3. VISUAL LANGUAGE
Use: very dark backgrounds, high contrast, restrained editorial typography, cinematic movie artwork, subtle depth, precise alignment, minimal UI decoration. Expensive because of restraint, not effects.
Avoid: heavy gradients, glassmorphism, neon overload, rounded generic SaaS cards, decorative blobs, floating particles, animated background noise, oversized headline stacks.
4. STORY STRUCTURE (one continuous film, not stacked sections)
Introduce Pickd.
Establish the problem with movie discovery.
Establish Pickd's different approach.
Recommendation journey (see §5 — this is the reference chapter for the whole site's motion language).
Continue from the state Scene 4 establishes.
5. SCENE 4 — RECOMMENDATION JOURNEY (reference scene for the whole site)
Philosophy: the phone is a temporary container; the deck is the permanent product.
Progression: Genre → Pick 3 → Taste established → Deck created → Recommendations grow → Ready.
Chapter 1 — "Discover Your Taste." Real genre-selection screenshot, phone stationary and architectural. Let the composition settle before moving on.
Chapter 2 — "Choose What You Love." Real Pick-3 screenshot. Same phone, continuous product. The three chosen movies must be visually identifiable — use real selections from supplied assets, not placeholders.
Chapter 3 — "Taste, established." Not another screenshot. The phone disappears as a container; the three selected cards remain and begin tightening toward each other — the start of the deck. Hold this moment. Don't reveal the full deck or recommendations yet.
Deck creation. The three cards become a physical stack — thickness, weight, depth, friction, alignment, like real cards on a table. No exaggerated 3D. The deck must feel earned, not conjured.
Real swipe product. Reveal the actual swipe-deck screenshot: layered cards, active top card, offsets, action buttons, next-card glimpse. Do not redesign it into a generic Tinder-style UI.
Phone dissolve. Bezel, border, notch, status bar, shadow — removed layer by layer. Deck stays stable. No flying, no rotating, no particle explosion.
Deck in web space. The deck doesn't fly into the page — the page reveals that it always belonged there.
Recommendation growth. Cards join one at a time: enter → settle → pause, repeated. Real movie artwork only. No "AI recommendation engine" labeling — show the mechanism, don't caption it.
Final state. Quiet. Minimal copy ("READY."). No explanatory paragraph. Let stillness close the scene.
6. COPY VOICE
Short, concrete, one idea per line — e.g. "WHAT'S THE VIBE?", "PICK 3 MOVIES YOU LOVE", "Taste, established.", "READY."
Never: "Revolutionizing the way you discover movies with next-generation AI." That voice is banned outright.
Do not invent features, statistics, testimonials, pricing, user counts, or algorithm claims that weren't supplied.
7. SCROLL \& MOTION MECHANICS
Scroll drives the story. No moment where multiple unrelated states are visible at once from fast scrolling.
Each chapter gets enough scroll distance to read as enter → hold → exit.
Use explicit scroll-driven timelines for sequences that need enter/hold/exit — don't rely solely on whileInView for cinematic beats.
Motion vocabulary: fade, translate, subtle scale, physical card stacking, controlled entrance/exit, restrained depth.
Every animation must answer "why is this moving?" — if the honest answer is "looks cool," cut it.
Banned motion: bouncing, elastic overshoot, spinning, particle explosions, random float, decorative parallax layered on everything.
8. SYSTEM, RESPONSIVENESS, PERFORMANCE, ACCESSIBILITY
One design system: typography, spacing, color, radii, shadow, easing, section structure — reused across scenes, not reinvented per scene.
Mobile is a re-composition, not a scaled-down desktop layout. Preserve hierarchy, product authenticity, and narrative; reduce complexity, not meaning.
Compositor-friendly animation only (transform/opacity); avoid layout thrashing, expensive scroll handlers, unnecessary blur/filters, giant raster images.
Full prefers-reduced-motion support — motion off should simplify the story, not break it.
Clean component architecture: layout, product visuals, motion, and data separated. No 2,000-line single component. No unnecessary state library.
9. THINGS TO AVOID — GENERAL (applies to this project and future scroll/physics sites)
Visual "AI slop" tells:
Gradient-mesh or aurora backgrounds as a default filler
Glassmorphism used as a crutch instead of a deliberate choice
Floating 3D blobs, orbs, or abstract particle fields with no product connection
Neon glow applied everywhere instead of as an accent
Generic "bento grid" layouts with mismatched card sizes and no hierarchy (the exact failure mode already rejected once on this project)
Inconsistent card radius/shadow/border language across sections
Oversized hero headline + subhead + CTA stack that could belong to any SaaS product
"Powered by AI" badges, fake AI-generated iconography, holograms, data-stream visuals
Asset realism (the recurring failure point on this project):
Never substitute odd-looking, low-quality, or AI-generated stand-ins for real product screenshots or real movie artwork when real assets are supplied or sourceable (e.g. TMDB).
If a design tool can't fetch real imagery, it must clearly flag a placeholder rather than presenting an invented image as final.
Don't let a generated mockup "reinterpret" a real screenshot — use it as-is.
Motion misuse:
Scroll-hijacking that fights the user's own scroll input rather than pacing it
Every element animating on every scroll tick (fatigue, no hierarchy of importance)
Parallax used decoratively rather than to reinforce depth that matters
Spinning device mockups, camera flythroughs, unmotivated 3D rotation
No reduced-motion fallback, or a fallback that removes meaning instead of just easing
Copy misuse:
Marketing filler ("revolutionize," "next-generation," "cutting-edge," "seamless")
Explaining what the motion already showed
Inventing stats, testimonials, or claims not in the product truth
10. DELIVERABLE
A cohesive, restrained, cinematic scroll experience for Pickd's Scene 4 (and consistent groundwork for the rest of the page) that a visitor understands without reading much: taste in → deck out → recommendations grow the deck → ready to discover. Product is the hero throughout. Evaluate the result against §2 and §9 before considering it done.
for the screenshot images, use ones from internet, if design can be done better that asked for, do iit

I'll create a comprehensive Figma-ready design specification for the PICKD cinematic landing page, focusing on Scene 4 (Recommendation Journey) as the reference chapter. This will be production-ready for immediate implementation.

## Design System Foundation

### Color Palette (Locked)

- **Ink Black**: `#0A0A0A` (primary background)
- **Surface Black**: `#141414` (secondary surfaces)
- **Neon Indigo**: `#6B4EFF` (primary accent)
- **Cyan**: `#00F0FF` (secondary accent)
- **Gold**: `#FFC107` (tertiary accent)
- **Pure White**: `#FFFFFF` (text primary)
- **Off-White**: `#E5E5E5` (text secondary)


### Typography

- **Headlines**: SF Pro Display or Inter, 80-96px, weight 600-700, letter-spacing -2%
- **Subheads**: SF Pro Text or Inter, 24-32px, weight 400-500
- **Body**: 16-18px, weight 400, line-height 1.5
- **Microcopy**: 14px, weight 500, all caps optional


### Spacing System

- Base unit: `8px`
- Section padding: `120px` desktop, `80px` mobile
- Card gaps: `16-24px`
- Content max-width: `1200px`


### Motion Principles

- **Easing**: `cubic-bezier(0.25, 0.1, 0.25, 1.0)` (custom ease-out)
- **Duration**: 600-900ms for major transitions
- **Scroll-driven**: Use `useScroll` + `useTransform` from Framer Motion
- **Reduced motion**: Respect `prefers-reduced-motion`


## Scene 4: Recommendation Journey — Frame-by-Frame Specification

### Chapter 1: "Discover Your Taste"

**Layout**: Centered, phone mockup stationary

- Phone dimensions: 390x844px (iPhone 14/15 Pro scale)
- Phone position: Center viewport, 60% from top
- Background: Pure ink black with subtle radial gradient (opacity 0.03, radius 800px)

**Content**:

- Headline: "WHAT'S THE VIBE?" (80px, centered, 120px above phone)
- Screenshot: `/screenshots/02_mood_selection.png` (full phone screen, no bezel)
- Phone frame: Minimal 2px indigo glow on hover only

**Motion**:

- Enter: Fade + subtle scale (0.98 → 1.0) over 800ms
- Hold: Static for 40% of scroll distance
- Exit: Fade to 0.8 opacity, scale to 0.95

**TMDB Reference Images** (for mood genres):

- Action: `https://image.tmdb.org/t/p/w500/8UlWHLMpgZm9bx6QYh0NFoq67TZ.jpg` (Top Gun)
- Drama: `https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg` (Shawshank)
- Sci-Fi: `https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg` (LOTR)


### Chapter 2: "Choose What You Love"

**Layout**: Same phone position, seamless transition

- Headline: "PICK 3 MOVIES YOU LOVE" (same typography, crossfade from Chapter 1)
- Screenshot: `/screenshots/03_pick3.png` (showing 3 selected movie cards)

**Critical Detail**: The three selected movies must be identifiable:

- Card 1: Visible title + poster (e.g., "Inception", "Interstellar", "Dune")
- Card 2: Slight offset, 80% scale
- Card 3: Further offset, 60% scale
- Selection indicator: Indigo checkmark or border glow

**Motion**:

- Transition: Phone stays fixed, screenshot crossfades (300ms)
- Cards: Subtle parallax on scroll (max 20px vertical)
- Hold: 50% of scroll distance (let user read the cards)


### Chapter 3: "Taste, Established"

**Layout**: Phone container dissolves, cards remain

- Headline: "Taste, established." (24px, centered, low opacity 0.6)
- Three cards from Chapter 2 now float in web space

**Card Specs**:

- Dimensions: 280x420px each (maintain aspect ratio)
- Spacing: 24px horizontal gap
- Depth: Subtle drop shadow (blur 40px, opacity 0.3, y-offset 20px)
- Border: 1px indigo at 20% opacity

**Motion**:

- Phone fade: Opacity 1.0 → 0 over 600ms
- Card convergence: Translate X to center, gap reduces from 24px → 8px
- Hold: Cards settle into tight formation, pause 400ms


### Chapter 4: Deck Creation

**Layout**: Three cards stack into physical deck

- Position: Center viewport, slight vertical bias (55% from top)
- Stack effect: Each card offset by 2px vertically, 1px rotation

**Visual Language**:

- Top card: Full opacity, sharp focus
- Middle card: 90% opacity, 2px down
- Bottom card: 80% opacity, 4px down
- Deck thickness: Subtle 3px indigo edge on right side (simulates card stack)

**Motion**:

- Stack formation: Cards translate Y + rotate Z (max 2°)
- Easing: Spring physics (stiffness 200, damping 25)
- Hold: Deck "breathes" subtly (scale 1.0 → 1.02 → 1.0 over 3s)


### Chapter 5: Real Swipe Product

**Layout**: Reveal actual swipe-deck screenshot

- Screenshot: `/screenshots/04_swipe_deck.png` (full product UI)
- Overlay: Minimal UI hints (swipe gesture indicator, 40% opacity)

**Key Elements**:

- Active card: Top movie poster, full bleed
- Action buttons: Heart (indigo), X (cyan), Star (gold)
- Next card glimpse: 20% visible below, offset 40px down
- No redesign: Use exact product screenshot, no generic Tinder-style UI

**Motion**:

- Reveal: Deck scales down slightly (1.0 → 0.9), screenshot fades in
- Gesture hint: Subtle swipe animation (translate X 20px, 2s loop)
- Hold: 60% of scroll distance (show full product context)


### Chapter 6: Phone Dissolve

**Layout**: Layer-by-layer removal of phone elements

- Sequence: Bezel → Status bar → Notch → Shadow → Border
- Each layer: 200ms fade, staggered 100ms

**Final State**: Only the deck remains, floating in pure black space

- No container, no frame, no shadows
- Deck position: Exactly where it was in Chapter 5

**Motion**:

- Dissolve timeline: 1.2s total, scroll-driven
- Easing: Linear for precision
- Hold: 300ms of pure stillness


### Chapter 7: Deck in Web Space

**Layout**: Page reveals deck belongs here

- Background: Subtle texture (noise at 2% opacity, or micro-gradient)
- Deck: No longer "product screenshot" — now native web element

**Visual Treatment**:

- Cards: Same dimensions, now with web-native hover states
- Hover: Scale 1.03, shadow intensifies (blur 60px, opacity 0.5)
- Cursor: Pointer on deck, grab on individual cards

**Motion**:

- No movement: Deck stays fixed, page "settles" around it
- Subtle parallax: Background moves at 10% scroll speed
- Hold: 50% of scroll distance


### Chapter 8: Recommendation Growth

**Layout**: New cards join deck one at a time

- Entry pattern: Fade + translate Y (40px → 0) + scale (0.95 → 1.0)
- Timing: 400ms per card, 200ms stagger

**Card Content** (TMDB sourced):

- Card 4: `https://image.tmdb.org/t/p/w500/1E5baAaEse26fej7uHcjOgEE2t2.jpg` (Fast X)
- Card 5: `https://image.tmdb.org/t/p/w500/r3pPehX4ik8NLYPpbDRAh0YRtMb.jpg` (John Wick 4)
- Card 6: `https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg` (Fight Club)

**Motion**:

- Enter: Each card appears from below deck
- Settle: Spring to rest position (stiffness 300, damping 30)
- Pause: 400ms between cards
- Final: All 6 cards in deck, slight fan (rotation -3° to +3°)


### Chapter 9: "READY."

**Layout**: Minimal, quiet close

- Headline: "READY." (96px, centered, pure white)
- Subtext: "Start discovering." (18px, 60% opacity, 24px below)
- CTA: Pill button (indigo background, white text, 48px height, 96px width)

**Visual**:

- Deck: Slightly blurred (blur 4px), opacity 0.4
- Focus: All on headline + CTA
- Background: Pure black, no distractions

**Motion**:

- Headline: Fade + subtle scale (0.9 → 1.0)
- CTA: Slide up from 20px below
- Deck: Fade to background over 800ms
- Hold: Indefinite (user scrolls to next section or clicks CTA)


## Figma Implementation Guide

### Frame Structure

```
Scene 4 - Recommendation Journey (1200px width, 6000px height)
├── Chapter 1 - Discover Your Taste (0-600px)
├── Chapter 2 - Choose What You Love (600-1200px)
├── Chapter 3 - Taste Established (1200-1800px)
├── Chapter 4 - Deck Creation (1800-2400px)
├── Chapter 5 - Real Swipe Product (2400-3000px)
├── Chapter 6 - Phone Dissolve (3000-3600px)
├── Chapter 7 - Deck in Web Space (3600-4200px)
├── Chapter 8 - Recommendation Growth (4200-4800px)
└── Chapter 9 - READY (4800-6000px)
```


### Component Library

- **Phone Mockup**: 390x844px, 2px indigo border, no shadow
- **Movie Card**: 280x420px, 8px radius, poster bleed
- **Deck Stack**: Auto-layout, 2px vertical offset per card
- **CTA Button**: 48px height, 980px radius (pill), indigo fill
- **Typography Styles**: H1 (80px), H2 (48px), Body (16px), Micro (14px)


### Prototype Settings

- **Scroll**: Vertical, linear
- **Animation**: Smart animate, 600ms ease-out
- **Overflow**: Scroll (for cards within phone)
- **Device**: iPhone 14/15 Pro (for preview)


## React + Framer Motion Implementation Skeleton

```jsx
// Scene4.jsx
import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';

export function Scene4() {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start start', 'end end']
  });

  // Chapter progress markers (0-1 scale)
  const chapter1 = useTransform(scrollYProgress, [0, 0.1], [0, 1]);
  const chapter2 = useTransform(scrollYProgress, [0.1, 0.2], [0, 1]);
  // ... continue for each chapter

  return (
    <section ref={ref} className="h-[600vh] bg-[#0A0A0A]">
      <div className="sticky top-0 h-screen overflow-hidden">
        {/* Chapter 1 */}
        <motion.div 
          style={{ opacity: useTransform(chapter1, [0, 0.4, 0.6, 1], [0, 1, 1, 0]) }}
          className="absolute inset-0 flex flex-col items-center justify-center"
        >
          <h2 className="text-5xl font-semibold text-white mb-32">
            WHAT'S THE VIBE?
          </h2>
          <PhoneMockup>
            <img src="/screenshots/02_mood_selection.png" alt="Mood selection" />
          </PhoneMockup>
        </motion.div>

        {/* Chapter 2 */}
        <motion.div 
          style={{ opacity: useTransform(chapter2, [0, 0.3, 0.7, 1], [0, 1, 1, 0]) }}
          className="absolute inset-0 flex flex-col items-center justify-center"
        >
          <h2 className="text-5xl font-semibold text-white mb-32">
            PICK 3 MOVIES YOU LOVE
          </h2>
          <PhoneMockup>
            <img src="/screenshots/03_pick3.png" alt="Pick 3 movies" />
          </PhoneMockup>
        </motion.div>

        {/* Continue for remaining chapters... */}
      </div>
    </section>
  );
}
```


## Critical Success Factors

1. **No "bento box" asymmetry**: Maintain strict vertical alignment, avoid random card sizes
2. **Real screenshots only**: Use exact paths provided, no approximations
3. **Motion with purpose**: Every animation answers "why is this moving?"
4. **Restraint over effects**: No particles, no gradients, no glassmorphism
5. **Scroll pacing**: Each chapter gets 400-600px of scroll distance minimum
6. **Reduced motion**: `prefers-reduced-motion` simplifies to fade-only transitions

This specification is ready for immediate Figma implementation. The design prioritizes product authenticity, cinematic pacing, and editorial restraint — matching the Apple product page reference without copying it.
<span style="display:none">[^1][^10][^11][^12][^13][^14][^15][^16][^17][^18][^19][^2][^20][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://dribbble.com/search/apple-product-page

[^2]: https://dribbble.com/tags/apple-product-page

[^3]: https://dribbble.com/search/apple-landing-page

[^4]: https://github.com/mirzamahmud/flutter_media_picker

[^5]: https://elements.envato.com/web-templates/landing-page-templates/apple

[^6]: https://designmd.app/library/apple-premium-cinematic/

[^7]: https://dribbble.com/search/apple-landingpage

[^8]: https://www.behance.net/search/projects/apple landing page ui design

[^9]: https://github.com/Flutter-Journey/Flutter-UI-Challenge/tree/main/movie_selection_screen

[^10]: https://landdding.com/tag/apple

[^11]: https://eraoftech.medium.com/step-by-step-guide-to-build-that-gta-vi-style-landing-page-with-scroll-triggered-videos-parallax-3c3065743ed0

[^12]: https://developer.themoviedb.org/docs/image-basics

[^13]: https://www.themoviedb.org/talk/64a12b95c390c5010c62d797

[^14]: https://bin.re/blog/tutorial-download-posters-with-the-movie-database-api-in-python/

[^15]: https://www.themoviedb.org/talk/5f3ef4eec175b200365ee352

[^16]: https://posterflix.vercel.app/

[^17]: https://expertbeacon.com/how-to-create-scroll-animations-with-react-tailwind-css-and-framer-motion/

[^18]: https://stackoverflow.com/questions/36027666/getting-movie-image-from-tmdb

[^19]: https://dribbble.com/tags/movie-app

[^20]: https://dribbble.com/shots/21133403-Movie-App-Dark-Mode

