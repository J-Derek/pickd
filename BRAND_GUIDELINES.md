# Pickd - Brand Guidelines

## 1. Brand Essence
**Pickd in one sentence:** Pickd is a premium, cinematic discovery engine that eliminates streaming decision fatigue by mapping movies to your current emotional state in half a second.

* **Why Pickd exists:** To cure the "endless scroll" epidemic. Streaming platforms offer infinite choice but no curation, leaving users paralyzed. Pickd exists to get people watching instead of searching.
* **What it believes:** We believe cinema is inherently emotional, not categorical. "Sci-Fi" is a category; "Hyped" is a feeling. Discovery should be driven by how you want to feel right now.
* **What makes it different:** It replaces grid-based browsing with a hyper-fast, binary, Tinder-style swipe interface, forcing gut-reaction decisions and building a deeply accurate "Taste DNA."
* **What emotions it should create:** Relief, excitement, trust, and premium exclusivity.

## 2. Mission
Our mission is to instantly connect viewers with the perfect movie for their current mood, removing friction from discovery and returning the joy to watching.

## 3. Vision
Our long-term vision is to become the definitive emotional curation layer for all entertainment, seamlessly syncing across all streaming platforms so that a user never has to ask "what should we watch?" ever again.

## 4. Core Values
1. **Speed Over Depth (Initially):** 
   * *Meaning:* Friction is the enemy. The user must be able to make a choice in seconds.
   * *Design:* Large tap targets, swipeable interfaces, zero loading spinners.
   * *Writing:* Punchy, short sentences. No essays.
   * *Product:* Cache everything locally so the app responds instantly.
2. **Emotion Over Categorization:**
   * *Meaning:* We care about *vibes*, not just genres.
   * *Design:* Use color and imagery to convey mood. Avoid sterile database tables.
   * *Writing:* Speak to feelings ("Spooky," "Chill") rather than metadata ("Horror," "Indie").
   * *Product:* The recommendation engine must prioritize emotional resonance.
3. **Cinematic Tactility:**
   * *Meaning:* The digital experience should feel as premium and physical as a high-end theater ticket.
   * *Design:* Matte cardstock textures, foil edge tracing, deep drop shadows, glass.
   * *Writing:* Use theater and film terminology naturally.
   * *Product:* Animations must have weight and physics.
4. **Ruthless Curation:**
   * *Meaning:* Less is more. Don't overwhelm the user with 50 options.
   * *Design:* Show one thing at a time (Swipe Deck).
   * *Writing:* Confident recommendations. "Watch this," not "You might like these."
   * *Product:* Focus on Hidden Gems over promoting standard blockbusters.
5. **Quiet Confidence:**
   * *Meaning:* The brand knows it's good. It doesn't need to shout.
   * *Design:* Heavy use of negative space, dark mode, high contrast.
   * *Writing:* Understated, witty, never desperate.
   * *Product:* Seamless onboarding without begging for notifications or reviews right away.

## 5. Brand Personality
If Pickd were a person:
* **Personality:** The cinephile friend who knows exactly what you'll love without being a snob about it.
* **Confidence:** High, but understated.
* **Energy:** Focused and deliberate. Never chaotic.
* **Style:** Monochromatic streetwear with a single, vivid pop of color.
* **Humor:** Dry, subtle, relatable.
* **Intelligence:** Highly analytical, but hides the math behind a beautiful interface.
* **Conversation style:** Direct, engaging, and brief.

**5 Adjectives that describe Pickd:**
Cinematic, Premium, Intuitive, Tactile, Fast.

**5 Adjectives that should NEVER describe Pickd:**
Cluttered, Generic, Overwhelming, Corporate, Cheap.

## 6. Emotional Journey
How a first-time visitor should feel throughout the website:

* **Arrival → Awe:** They see the edge-to-edge trending marquee and immediately recognize this isn't a standard tech app; it feels like entertainment.
* **Curiosity:** "Stop scrolling. Start watching." hooks them. They want to know how it achieves this.
* **Recognition:** They see the "Swipe Deck" feature and realize, "Ah, it's Tinder for movies." The mental model clicks.
* **Relief:** They read about "Taste DNA" and realize they no longer have to debate what to watch.
* **Trust:** The premium execution (tactile tickets, smooth motion) signals that the underlying engineering is equally high-quality.
* **Excitement:** They realize they can fix their movie night tonight.
* **Download:** They click the CTA feeling confident in their choice.

## 7. Design Philosophy
* **Simplicity:** One core action per screen. Remove extraneous UI. Let the content breathe.
* **Cinematic Storytelling:** Use real movie posters as structural design elements, not just data. Treat the UI as a frame for the art.
* **Premium Feeling:** Deep dark modes (`#0d0d0f`) with pure, highly saturated accent glows (`#6B4EFF`). Avoid standard SaaS grays.
* **Tactile Interfaces:** UI shouldn't feel like flat pixels. Use SVG noise filters for matte cardstock, overlapping elements for depth, and foil screen-blends for premium edges.
* **Depth & Lighting:** Utilize multiple Z-layers. Cast deep, soft drop shadows (e.g., `rgba(0,0,0,0.6)`) to lift cards off the background. Simulate physical lighting (gradients).
* **Negative Space:** Essential. If an interface feels cramped, it causes the very anxiety we are trying to cure.

## 8. Motion Philosophy
* **Style:** Elegant, fluid, and physics-driven (liquid springs). Never linear or mechanical.
* **Speed:** Fast and snappy for actions (swipes, taps), slow and ambient for backgrounds (marquees, floating elements).
* **Weight:** Cards should feel like physical objects with mass. They shouldn't just disappear; they should be thrown, dropped, or snapped into place.
* **Purpose:** Motion is expressive but always invisible in its utility. It directs the eye to the next logical action.
* **Never use:** Jittery bounces, long fade-ins that block interaction, or complex multi-stage loading spinners.

## 9. Photography & Imagery
* **Posters:** High-resolution movie posters are the lifeblood of the brand. They must always be masked cleanly (rounded corners) or integrated into physical cards.
* **Phone Mockups:** Must be bezel-less, high-fidelity, and blend seamlessly into the dark background, often overlapping with UI elements to break the frame.
* **Textures:** Use subtle digital noise to simulate physical paper/cardstock. 
* **Gradients:** Use them to simulate lighting (e.g., a glowing edge) or to create a legible mask over imagery. Never use them as loud, rainbow backgrounds.
* **Icons:** Bespoke, ultra-thin (1.5px stroke), line-art SVGs. Avoid chunky, generic icon libraries.

## 10. Color Philosophy
* **Ink (`#030305` & `#0d0d0f`):** The foundational background. It simulates a dark movie theater. It exists to make the posters pop. NEVER use pure black (`#000000`).
* **Indigo (`#6B4EFF`):** The primary accent. Represents the core brand (Taste DNA). Used for primary buttons, active states, and foil borders.
* **Cyan (`#00F0FF`) & Amber (`#FFC107`):** Secondary accents used for categorization (e.g., Swipe Deck vs. Hidden Gems).
* **White (`#FFFFFF`):** Reserved exclusively for high-emphasis typography and icons. Usually knocked back to `80%` or `50%` opacity to reduce eye strain.

## 11. Typography Philosophy
* **Headline Style:** Modern Display sans-serif (e.g., `Outfit`). Tightly tracked, bold, and high-impact. It should look like a movie title card.
* **Body Style:** Highly readable sans-serif (e.g., `Inter`). Looser tracking, generous line height (`1.6`).
* **Hierarchy:** Extreme contrast between headlines (huge, white) and body copy (small, 50% opacity). Skip intermediate sizes to maintain dramatic tension.

## 12. Voice & Copywriting
Pickd speaks directly. It is confident, slightly playful, and deeply empathetic to the modern viewer's fatigue.
* **Rules:** Short sentences. Active verbs. Zero corporate jargon.
* **Hero Headline:** "Stop scrolling. Start watching."
* **Feature Description:** "Three movies. That's it. Pickd builds an emotional fingerprint of your taste instead of sorting you into a generic checkbox."
* **Empty State:** "Your deck is empty. Start swiping to fill it up."
* **Button Label:** "Get Pickd" (Not "Click here to download").
* **Never use:** "Welcome to our platform," "Optimize your viewing experience," or "Click here."

## 13. Website Principles
1. Show, don't tell. Let the UI speak for itself.
2. Every scroll must reveal a new layer of the story.
3. Motion should explain the app's physics (e.g., card stacks).
4. Never overload the user with walls of text.
5. Every section must have one clear, singular purpose.
6. The background should feel alive (ambient marquees, subtle glows).
7. Respect user preferences (always support `prefers-reduced-motion`).
8. The download CTA must always be within one scroll or fixed in the nav.
9. Avoid generic stock photos of people watching TV.
10. Treat UI mockups as art pieces, not just screenshots.
11. Content must be hyper-legible over complex backgrounds (use gradient masks).
12. Use physical metaphors (tickets, stacks, lenses).
13. Load instantly. The site must reflect the app's zero-latency promise.
14. Ensure deep contrast. If it's not dark mode, it's not Pickd.
15. End with a strong, undeniable call to action.

## 14. Inspiration
* **Tinder (UI/UX):** Learn the absolute frictionlessness of a binary swipe. Do not copy the dating context; copy the mechanical speed.
* **Apple (Landing Pages):** Learn the dramatic scale, scroll-linked animations, and extreme typographic hierarchy. Do not copy the hardware focus; apply the premium feel to software.
* **A24 (Brand Vibe):** Learn the curation, the indie-cool aesthetic, and the trust they build with their audience. Do not copy specific films; copy the feeling of being a tastemaker.

## 15. Things to Avoid
* **Generic SaaS Layouts:** Two-column text-left-image-right with a blue button. It kills the cinematic vibe.
* **Stock Photography:** Cheesy images of families eating popcorn destroy trust instantly.
* **Excessive Neon:** Don't turn the app into a cyberpunk rave. Accents should be surgical, not overwhelming.
* **Cluttered Interfaces:** If the user has to think about where to look, we've failed.
* **Overused Gradients:** Avoid "Instagram-style" rainbow gradients. Use gradients only for lighting/shadows.
* **Corporate Language:** Words like "synergy," "optimize," or "platform" immediately alienate consumers.
* **Clickbait:** "You won't believe what movie you should watch next!" Be confident, not cheap.

## 16. Creative North Star
Imagine someone visits the Pickd website for the first time.

They are exhausted after a long day. They know they'll probably spend 40 minutes on Netflix tonight before giving up and going to sleep. 

They open the site. Instantly, they are hit with a massive, dark, cinematic marquee of today's best movies scrolling smoothly in the background. In stark, bold white text, the screen demands: **"Stop scrolling. Start watching."** 

There's no fluff. There are no corporate explainer videos. As they scroll, physical, tactile "movie tickets" float up, explaining how the app learns their taste in seconds. The animations feel heavy, expensive, and liquid. They see the swipe interface and the mental model clicks instantly—*it's Tinder for movies*. 

They don't feel like they are reading a software pitch; they feel like they are already inside a premium theater experience. They feel relief that the problem of "what to watch" has a simple, beautiful solution. 

They click "Download APK." They don't just remember the app; they remember how the brand made them feel: understood, curated, and ready for movie night. This is the Pickd standard.
