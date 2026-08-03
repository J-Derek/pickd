# Pickd

A premium cinematic landing experience for a movie recommendation application.

---

# Vision

Pickd should feel like the opening sequence of a premium film—not a SaaS website.

The experience should be remembered as a story rather than a collection of landing-page sections.

Every interaction should contribute to a single uninterrupted narrative.

---

# Core Philosophy

We are not designing sections.

We are directing scenes.

Every scene has:

- an introduction
- rising tension
- a payoff
- a transition into the next scene

The user should never feel like one section ends and another begins.

Instead, each scene should naturally evolve into the next.

---

# Narrative Arc

Hope

↓

Frustration

↓

Silence

↓

Discovery

↓

Trust

↓

Understanding

↓

Confidence

↓

Action

Every future scene must support this emotional progression.

---

# Scene Roadmap

## Scene 1

Hero

Purpose:

Introduce Pickd as a premium cinematic experience.

---

## Scene 2

Problem Statement

Purpose:

Create emotional tension.

The user recognizes their own movie decision fatigue.

---

## Scene 3

PhoneRevealV2

Purpose:

Introduce Pickd.

The product comes to life.

The recommendation experience begins.

---

## Scene 4

Recommendation Journey

Purpose:

Build trust.

Show why the recommendation feels intentional rather than random.

This is not a feature list.

It is a cinematic explanation of confidence.

---

## Scene 5

How It Works

Purpose:

Reveal the intelligence behind Pickd.

The user should understand the process without feeling like they are reading documentation.

---

## Scene 6

Final CTA

Purpose:

Deliver the natural conclusion to the story.

The CTA should feel inevitable rather than promotional.

---

# Architectural Rules

Each scene owns its own implementation.

Each scene owns:

- its own layout
- its own timeline
- its own MotionValues
- its own pacing
- its own transitions

Scenes hand off naturally to the next.

Do not build one massive scroll timeline across multiple scenes.

---

# Motion Principles

Motion exists to communicate.

Never animate purely for decoration.

Motion should feel:

- restrained
- physical
- cinematic
- intentional

Prefer:

- direct MotionValue mappings
- simple interpolation
- deterministic timelines

Avoid unnecessary springs.

---

# Visual Principles

Premium over flashy.

Editorial over playful.

Silence over clutter.

Large typography.

Generous spacing.

Carefully controlled lighting.

Meaningful negative space.

Every visual element must have a purpose.

---

# Storytelling Rules

Every scene must strengthen the previous scene.

Removing any scene should make the overall story weaker.

Scenes should answer the emotional question created by the previous one.

Transitions should feel motivated.

Nothing should appear simply because it is common on landing pages.

---

# Development Workflow

For every phase:

Build

↓

Polish

↓

Audit

↓

Remove diagnostics

↓

Commit

↓

Push

Only then begin the next phase.

Never overlap phases.

Never redesign completed scenes unless fixing a genuine issue.

---

# Definition of Done

A scene is complete when:

- visuals are production quality
- motion is polished
- responsive layouts are verified
- accessibility has been checked
- temporary code is removed
- no debug elements remain
- implementation is clean and intentional

Code quality should reflect the same craftsmanship as the visual design.
