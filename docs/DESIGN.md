# Pickd Design System

This document outlines the core design tokens and components for the Pickd Media Discovery Platform, extracted directly from the Stitch Pro Max design files.

## 1. Typography

The application uses two primary typefaces to create a modern, cinematic, and premium feel.

- **Headline/Display Font**: `Syne`
  - *Usage*: High-impact headers, movie titles, large numbers.
  - *Weights*: 600 (SemiBold), 700 (Bold), 800 (ExtraBold).
- **Body/Label Font**: `Inter`
  - *Usage*: Paragraphs, small labels, UI controls, metadata.
  - *Weights*: 400 (Regular), 600 (SemiBold).

### Typography Scale
- **Display Large**: Syne, 64px, 800 (ExtraBold), Line Height 1.1, Tracking -2%
- **Headline Large**: Syne, 40px, 700 (Bold), Line Height 1.2
- **Headline Medium**: Syne, 24px, 600 (SemiBold), Line Height 1.3
- **Body Large**: Inter, 18px, 400 (Regular), Line Height 1.6
- **Body Medium**: Inter, 16px, 400 (Regular), Line Height 1.5
- **Label Medium**: Inter, 14px, 600 (SemiBold), Line Height 1.2, Tracking 5%

---

## 2. Color Palette (Dark Theme Default)

The color palette leans heavily into dark mode to make movie posters and media pop, using vibrant cyan as a neon accent.

### Surfaces & Backgrounds
- **Background / Surface / Surface Dim**: `#0e1417` (Deep dark slate/blue-black)
- **Surface Container Lowest**: `#090f12`
- **Surface Container Low**: `#161d1f`
- **Surface Container**: `#1a2123`
- **Surface Container High**: `#242b2e`
- **Surface Container Highest / Surface Variant**: `#2f3639`
- **Surface Bright**: `#333a3d`

### Accents (Cyan/Blue)
- **Primary Container**: `#00d1ff` (Electric Cyan - used for primary calls to action, active toggles)
- **On Primary Container**: `#00566a` (Text/icons sitting on Primary Container)
- **Primary**: `#a4e6ff`
- **On Primary**: `#003543`
- **Inverse Primary**: `#00677f`
- **Surface Tint / Primary Fixed Dim**: `#4cd6ff`

### Text & Icons
- **On Surface / On Background**: `#dde3e7` (Primary text color)
- **On Surface Variant**: `#bbc9cf` (Secondary text, metadata, subtle icons)
- **Outline**: `#859399` (Dividers, unselected states)
- **Outline Variant**: `#3c494e` (Subtle borders)

### Semantic Colors
- **Error**: `#ffb4ab`
- **Error Container**: `#93000a`
- **On Error Container**: `#ffdad6`

---

## 3. Spacing & Layout

- **Unit**: 8px (Base grid)
- **Stack Small (stack-sm)**: 8px
- **Stack Medium (stack-md)**: 16px
- **Gutter**: 24px (Spacing between columns/components)
- **Stack Large (stack-lg)**: 32px
- **Container Margin Mobile**: 20px (Screen padding on mobile)
- **Container Margin Desktop**: 80px (Screen padding on desktop)

---

## 4. Shapes & Roundness

- **Default / Small Elements**: 4px (`rounded`)
- **Medium Elements (Buttons, inputs)**: 8px (`rounded-lg`)
- **Large Elements (Cards, bottom sheets)**: 12px (`rounded-xl`)
- **Pills / Avatars**: 9999px (`rounded-full`)

---

## 5. UI Components & Effects

### Glass Panels
The design relies heavily on "glassmorphism" for overlays, headers, and bento-box cards floating over backgrounds.
- **Background**: `rgba(22, 29, 31, 0.4)`
- **Backdrop Filter**: `blur(32px)`
- **Border**: `1px solid rgba(255, 255, 255, 0.05)`

### Buttons
- **Primary Button**: `bg-primary-container text-black font-label-md` with `rounded-lg` (8px). 
- **Hover/Glow Effect**: Hovering primary interactive elements triggers a neon glow (`box-shadow: 0 0 15px rgba(0, 209, 255, 0.4)`) and border color transition to `#00d1ff`.

### Iconography
- Uses **Material Symbols Outlined**.
- Default icons are `text-on-surface`.
- Hover/Active icons are `text-primary`.

---

## 6. Implementation Notes for Flutter

Since Pickd is built in Flutter, the above tokens will map to the `AppTheme` class (`lib/core/theme/app_theme.dart`). 

1. **Colors**: We need to update `bgSurface`, `bgElevated`, `accentPrimary`, `textPrimary`, and `textSecondary` to match the exact hex codes above.
2. **Typography**: The app needs `Syne` and `Inter` imported via `google_fonts` package. 
3. **Glassmorphism**: We can use `BackdropFilter` combined with `Container` and a semi-transparent `color` with `Border` for glass panels.
