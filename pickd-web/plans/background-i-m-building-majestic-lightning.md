# Implementation Plan — Pickd landing page fixes

## Context

All six sections are built and the TypeScript build is clean, but four runtime/convention issues were
identified in the prior assessment plan. This plan executes those fixes in the recommended order.

## Fix 1 — Sticky header (behavioral)

**Problem:** `<header class="glass sticky top-0 z-50">` is a child of `<section class="overflow-hidden">` in
`Hero.tsx:8`. A containing block with `overflow` set becomes the scroll container, so `sticky` never pins.

**Fix:** Move the `<header>` block (lines 53–76 of Hero.tsx) out of Hero and render it as the first child of
the root `<div>` in `App.tsx`. The inner glow wrapper (`<div class="absolute inset-0 pointer-events-none
overflow-hidden">`) already confines the radial glows, so `overflow-hidden` can be removed from the `<section>`
tag itself. Hero becomes a plain flex column with no overflow restriction.

Files: `src/App.tsx`, `src/components/Hero.tsx`

## Fix 2 — Remove unlayered universal selector (behavioral)

**Problem:** `index.css:41–48` has an unlayered `* { scrollbar-width: none; box-sizing: border-box }` and
`*::-webkit-scrollbar { display: none }`. This hides the scrollbar site-wide and overrides Tailwind's layered
preflight for box-sizing.

**Fix:** Delete those two rule blocks entirely. Tailwind's preflight already handles `box-sizing`. If
horizontal scroll containment on a specific element is needed later, scope it there.

File: `src/index.css`

## Fix 3 — Dead footer links (content)

**Problem:** Privacy Policy and Terms of Use point to `#`. The social icons point to bare `twitter.com` /
`linkedin.com` (no real profile).

**Fix:** Replace the legal placeholder links with a short "Coming soon" `<span>` styled identically to the
muted link color (no `href`, `cursor-default`). Replace the Twitter/X and LinkedIn `<FooterLink>` entries with
the real GitHub link only (since no real social profiles exist). This is cleaner than dead destinations.

File: `src/components/Footer.tsx`

## Fix 4 — Inline styles → Tailwind utilities (convention sweep)

**Problem:** ~90% of styling is inline `style` objects with hardcoded hex literals. The `@theme` tokens in
`index.css` are declared but never consumed. A token change won't propagate.

**Approach:** Convert each component file, keeping inline styles only for values that cannot be expressed as
utilities: dynamic 3D transforms, radial gradient backgrounds with percentage stops, and `filter: blur()` with
pixel values not in the spacing scale.

Pattern to apply across all six components + App.tsx:

| Inline value | Tailwind utility |
|---|---|
| `background: "#0A0A0F"` | `bg-ink` |
| `background: "#13131A"` | `bg-surface` |
| `background: "#1C1C26"` | `bg-elevated` |
| `color: "#FFFFFF"` | `text-foreground` |
| `color: "#B0B0C0"` | `text-secondary` |
| `color: "#6B6B80"` | `text-muted` |
| `color: "#6B4EFF"` | `text-indigo` |
| `border: "1px solid #252530"` | `border border-border` |
| `fontSize: "22px", fontWeight: 900` | `text-[22px] font-black` |
| `maxWidth: "1152px", margin: "0 auto"` | `max-w-[1152px] mx-auto` |
| `padding: "80px 24px"` | `py-20 px-6` |
| `display: "flex", alignItems: "center"` | `flex items-center` |
| JS hover handlers in Footer/Hero | `hover:text-foreground hover:bg-indigo/10` etc. |

The `App.tsx` root wrapper `style={{ minHeight: "100vh", background: "#0A0A0F", color: "#FFFFFF" }}` becomes
`className="min-h-screen bg-ink text-foreground"`.

Files: `src/App.tsx`, all six components, `src/index.css` (update `.glass`, `.btn-indigo`, `.gradient-text`
to reference `var(--color-*)` tokens instead of bare hex).

## Fix 5 — Hero grid breakpoint (minor)

**Problem:** `gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))"` keeps two columns until ~600px,
where the copy column gets cramped before it wraps.

**Fix:** Replace with `grid-cols-1 md:grid-cols-2` Tailwind classes (switches at 768px, which is the standard
tailwind `md` breakpoint). Remove the inline `gridTemplateColumns` property.

File: `src/components/Hero.tsx`

## Execution order

1. Fix 1 — App.tsx + Hero.tsx header lift
2. Fix 2 — index.css universal selector removal
3. Fix 3 — Footer dead links
4. Fix 4 — inline→Tailwind sweep (Hero → HowItWorks → FeatureBento → Waitlist → Feedback → Footer → App)
5. Fix 5 — Hero grid breakpoint

## Verification

- Scroll the full page in preview: header must stay pinned at the top past the hero fold
- Verify the browser scrollbar is visible on the right edge
- Confirm all three phone screenshots render (raw.githubusercontent.com URLs)
- Submit Waitlist form: invalid email shows error; valid email shows success state
- Submit Feedback form: missing fields show per-field errors; full submit shows success state
- Narrow viewport to 375px: hero stacks to one column, bento grid stacks vertically
- Toggle OS "reduce motion": sections appear immediately, no float animation
