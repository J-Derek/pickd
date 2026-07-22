# Pickd UI Revamp Plan (Figma Integration)

This plan maps the premium aesthetic from the new Figma screens to our existing app architecture and flow. We are keeping our exact routing and logic, but completely overhauling the visual layer.

## 1. Global Aesthetic & Theming (AppTheme)
- **Background**: Shift from the current dark grey to the rich, deep OLED black (`#0A0A0F`) seen in the designs.
- **Accent Colors**: 
  - Primary: Neon Indigo/Purple (`#6B4EFF`)
  - Gems Accent: Bright Yellow/Gold (`#FFC107`)
  - Tags/Pills: Cyan (`#00F0FF`), Neon Pink (`#FF4081`)
- **Typography**: Move to a clean, geometric sans-serif (like `Plus Jakarta Sans` or `Inter`) with tight tracking (letter-spacing) on headers.
- **Elevation**: Remove default Material soft shadows. Use subtle colored glows (e.g., a yellow glow behind the Gems button) and crisp 1px borders (`#1A1A24`) for definition.

## 2. Bottom Navigation Bar (`MainShell`)
- **Structure**: Keep our 4 tabs (Discover, Watchlist, Gems, Profile).
- **Styling**: 
  - Remove the Material active pill background.
  - Active state: Change icon/text color to the accent color and add a small circular dot (•) directly underneath the label.
  - Inactive state: Dimmed grey, outlined icons.
  - Background: Pure black, slightly translucent with a blur (glassmorphism) or flat black.

## 3. Main Swipe Screen (`/swipe`)
- **Header**: Replace the current header with the sleek profile row from the Figma "Home" screen (e.g., "Good evening 👋 Alex" with the avatar on the right, and the "Change Vibe" pill below it).
- **Swipe Card**:
  - Border radius increased to ~24px.
  - Massive poster taking up 70% of the screen.
  - Deep gradient overlay at the bottom so text pops.
  - "Match %" in gold/yellow, followed by genre pills.
- **Action Buttons**: 
  - Skip: Dark circular button with a red `X` and a 1px border.
  - Info: Dark circular button with an `i`.
  - Like: Large, glowing accent-colored FAB.

## 4. Gems Screen (`/gems`)
- **Header**: "💎 Hidden Gems" with a subtitle ("Films worth your time — before everyone finds them").
- **Filter Pills**: Add decorative or functional pills below the header (e.g., "Cult Classic", "Underrated", "Festival Fav") using the pink, blue, and yellow palette.
- **Action Buttons**: Same as the Swipe screen, but the "Like" button becomes a massive glowing yellow Diamond FAB.

## 5. Details & Watchlist
- Apply the same dark background, neon accents, and pill-shaped tags to the Watchlist grid and Movie Detail sheets to ensure the entire app feels cohesive and non-generic.

### Implementation Order
1. Update `AppTheme` (Colors, Fonts, Bottom Nav styles).
2. Refactor `MainShell` to build the new "dot" active state nav bar.
3. Overhaul `SwipeScreen` and `SwipeCard` to match the new poster and FAB design.
4. Overhaul `GemsScreen` to include the new header, pills, and diamond FAB.
