# DESIGN.md — Pickd Design System

> The visual source of truth for Pickd. Every UI component, color, font, and animation
> must be derived from this document. Never override it without updating it first.

---

## Brand Identity

**App Name:** pickd  
**Tagline:** Stop scrolling. Start watching.  
**Personality:** Cinematic, confident, dark, tactile, fast.  
**Not:** Sterile, generic, corporate, cluttered.

---

## Design Philosophy

Pickd lives in the dark. It's a cinema in your pocket.
Every screen should feel like the moment the lights go down in a theatre.
Cards feel physical — you can grab them, flip them, toss them.
Typography is bold and editorial. Color is used sparingly but decisively.

---

## Color Palette

### Base (Dark Cinematic)

| Token | Hex | Usage |
|---|---|---|
| `--color-bg-primary` | `#0A0A0F` | Main app background — near black with blue undertone |
| `--color-bg-surface` | `#131318` | Cards, bottom sheets, modals |
| `--color-bg-elevated` | `#1C1C24` | Elevated surfaces, nav bar |
| `--color-bg-muted` | `#252530` | Inactive states, dividers |

### Accent (Amber Cinema)

| Token | Hex | Usage |
|---|---|---|
| `--color-accent-primary` | `#F5A623` | Primary CTA, active states, "WATCH" swipe indicator |
| `--color-accent-glow` | `#F5A62340` | Glow effects, shimmer underlays |
| `--color-accent-secondary` | `#FF6B6B` | "SKIP" swipe indicator, destructive actions |
| `--color-accent-green` | `#4CAF88` | Watchlist confirmed, success states |

### Text

| Token | Hex | Usage |
|---|---|---|
| `--color-text-primary` | `#F2F2F5` | Headings, primary content |
| `--color-text-secondary` | `#9999AA` | Subtext, metadata, timestamps |
| `--color-text-muted` | `#55556A` | Placeholders, disabled states |
| `--color-text-inverse` | `#0A0A0F` | Text on amber accent backgrounds |

### Overlays & Gradients

```
Card bottom gradient:   linear-gradient(transparent → #0A0A0F 85%)
Poster overlay:         linear-gradient(transparent 40% → #0A0A0F)
Swipe WATCH overlay:    rgba(245, 166, 35, 0.15) border left-edge glow
Swipe SKIP overlay:     rgba(255, 107, 107, 0.15) border right-edge glow
Gems badge:             linear-gradient(135deg, #7B2FBE → #F5A623)
```

---

## Typography

### Fonts

| Role | Font Family | Source |
|---|---|---|
| Display / Headings | `Syne` | Google Fonts |
| Body / UI | `Inter` | Google Fonts |
| Monospace / Meta | `JetBrains Mono` | Google Fonts |

### Scale

| Token | Font | Size | Weight | Line Height | Usage |
|---|---|---|---|---|---|
| `text-display` | Syne | 32sp | 800 | 1.15 | Screen titles, hero text |
| `text-heading` | Syne | 24sp | 700 | 1.2 | Section headers |
| `text-title` | Syne | 18sp | 700 | 1.3 | Card titles, movie names |
| `text-body-lg` | Inter | 16sp | 400 | 1.6 | Synopses, descriptions |
| `text-body` | Inter | 14sp | 400 | 1.5 | UI labels, body copy |
| `text-caption` | Inter | 12sp | 400 | 1.4 | Metadata, timestamps |
| `text-overline` | Inter | 11sp | 600 | 1.3 | Tags, labels (uppercase) |
| `text-mono` | JetBrains Mono | 12sp | 400 | 1.4 | Scores, ratings |

---

## Spacing System

Base unit: `4dp`

| Token | Value | Usage |
|---|---|---|
| `space-1` | 4dp | Tight gaps |
| `space-2` | 8dp | Inner padding small |
| `space-3` | 12dp | Standard inner spacing |
| `space-4` | 16dp | Section spacing, card padding |
| `space-5` | 20dp | Component gaps |
| `space-6` | 24dp | Screen horizontal padding |
| `space-8` | 32dp | Between major sections |
| `space-10` | 40dp | Screen top padding |
| `space-12` | 48dp | Hero spacing |

---

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 8dp | Chips, badges, small buttons |
| `radius-md` | 16dp | Cards, bottom sheets |
| `radius-lg` | 24dp | Modal containers |
| `radius-xl` | 32dp | Movie swipe cards |
| `radius-full` | 999dp | Circular avatars, FABs |

---

## Elevation & Shadows

```dart
// Card default
BoxShadow(
  color: Color(0xFF000000).withOpacity(0.4),
  blurRadius: 24,
  offset: Offset(0, 8),
)

// Card dragging
BoxShadow(
  color: Color(0xFFF5A623).withOpacity(0.15),
  blurRadius: 32,
  spreadRadius: 2,
  offset: Offset(0, 12),
)

// Amber glow (active CTA)
BoxShadow(
  color: Color(0xFFF5A623).withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 1,
)
```

---

## Iconography

- **Library:** `lucide_icons` (Flutter package)
- **Size:** 24dp standard, 20dp in compact contexts, 32dp in hero contexts
- **Color:** `--color-text-secondary` by default, `--color-accent-primary` when active
- **Style:** Outline/stroke icons only. No filled icons unless indicating active state.

---

## Motion & Animation

### Principles
- Every interaction must have a physical, tactile feel
- Cards respond to touch immediately — zero lag
- Transitions are fast and purposeful, never decorative for its own sake

### Durations

| Token | Duration | Easing | Usage |
|---|---|---|---|
| `motion-fast` | 150ms | easeOut | Tap feedback, chip select |
| `motion-standard` | 250ms | easeInOut | Screen transitions, card snap |
| `motion-slow` | 400ms | easeInOut | Modal enter, card fly-off |
| `motion-spring` | 350ms | spring(1.0, 100, 10) | Card drag release |

### Specific Animations

**Swipe Card Drag:**
- Card rotates slightly as dragged (max ±15°)
- WATCH/SKIP overlay fades in proportionally to drag distance
- Haptic feedback at 50% drag threshold (light impact)

**Card Fly-Off:**
- Duration: 400ms
- Eases out to off-screen with slight rotation continuation
- Next card scales up from 0.92 → 1.0 simultaneously

**Mood Selection:**
- Selected mood card scales to 1.05, unselected scale to 0.95
- Amber border appears with 150ms fade

**Screen Transitions (go_router):**
- Push: slide up from bottom (300ms)
- Pop: slide down to bottom (250ms)
- Modal: fade + scale from 0.95 (250ms)

**Hidden Gems Badge:**
- Gradient shimmer animation on the badge (3s loop)
- Subtle pulse on entry (scale 0.9 → 1.0 → 1.03 → 1.0)

---

## Component Specifications

### Movie Swipe Card

```
Width:           100% - 32dp margin
Height:          72% of screen height
Border Radius:   radius-xl (32dp)
Background:      Poster image fill + bottom gradient overlay
Padding:         space-6 (24dp) on all sides

Content (bottom overlay):
  - Genre chips (text-overline, space-sm gap)
  - Movie title (text-title, Syne Bold)
  - Year + Runtime + Rating row (text-caption, mono font for rating)
  - Vibe tags row
  - Tap hint: "Tap for trailer" (text-caption, muted)

Card Stack:
  - Card 2 (behind): scale 0.94, translateY +16dp, opacity 0.7
  - Card 3 (behind): scale 0.88, translateY +32dp, opacity 0.4
```

### Mood Selection Card

```
Width:           (screen - 48dp) / 2  (2-column grid)
Height:          140dp
Border Radius:   radius-md (16dp)
Background:      bg-surface
Border:          1dp solid bg-muted (default), 1dp solid accent-primary (selected)

Content:
  - Emoji (40sp, centered top)
  - Mood label (text-title, Syne)
  - Genre hint (text-caption, muted)

Selected state:
  - Amber border
  - Subtle amber background tint (accent-glow)
  - Scale 1.03
```

### Genre/Vibe Chip

```
Height:          28dp
Padding:         8dp horizontal, 4dp vertical
Border Radius:   radius-sm (8dp)
Background:      rgba(255,255,255,0.08)
Text:            text-overline, uppercase, text-secondary
```

### Bottom Navigation

```
Background:      bg-elevated with top border 1dp bg-muted
Height:          72dp + safe area
Icons:           24dp, lucide_icons
Active:          accent-primary color
Inactive:        text-muted color
No labels:       icon-only navigation
```

### CTA Button (Primary)

```
Height:          52dp
Width:           Full width
Border Radius:   radius-md (16dp)
Background:      accent-primary (#F5A623)
Text:            text-body, 600 weight, text-inverse
Shadow:          amber glow shadow
```

### Swipe Action Buttons (FAB row)

```
Skip button:    56dp circle, bg-elevated, border 1dp accent-secondary, skip icon
Watch button:   64dp circle, accent-primary background, heart/check icon, amber glow
```

---

## Screen Inventory

| Screen | Route | Description |
|---|---|---|
| Splash | `/` | Logo animation, then routes to onboarding or home |
| Onboarding - Mood | `/onboarding/mood` | Mood grid selection |
| Onboarding - Taste | `/onboarding/taste` | Favourite movies search (min 3) |
| Home / Swipe | `/swipe` | Card stack, main experience |
| Cinematic Detail | `/movie/:id` | Full detail, synopsis, trailer button |
| Watchlist | `/watchlist` | Saved right-swipe movies |
| Hidden Gems | `/gems` | Gems-only swipe mode |
| Auth Prompt (Sheet) | — | Bottom sheet shown after 5 swipes. Non-blocking. |

---

## Assets & Images

- **Movie Posters:** TMDB image CDN `https://image.tmdb.org/t/p/w500{poster_path}`
- **Backdrop:** TMDB `https://image.tmdb.org/t/p/original{backdrop_path}` (cinematic detail)
- **App Icon:** Dark background, amber "P" lettermark with film grain texture
- **No local image assets** except app icon and onboarding illustrations

---

## Accessibility

- Minimum contrast ratio: 4.5:1 for all body text
- Tap targets minimum: 48dp × 48dp
- All swipe actions must also be triggerable by button tap (accessibility users)
- Semantic labels on all icon buttons
- Support system font scaling up to 1.3x
