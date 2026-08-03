import { useRef } from "react"

import { motion, useInView } from "framer-motion"

import { useReducedMotion } from "../hooks/useReducedMotion"

const STEPS = [
  {
    number: "01",

    headline: "Pick 3 you love",

    body: "Not genres. Not decades. Actual films — the ones that stuck with you. Pickd reverse-engineers why you loved them to map your emotional taste profile.",

    screenColor: "#6B4EFF",

    screenDetail: (
      <img
        src="/screenshots/03_pick3.png"
        alt="Pick 3 you love"
        className="w-full h-full object-cover object-top"
      />
    ),
  },

  {
    number: "02",

    headline: "Swipe your deck",

    body: "Right to watch, left to pass, up when you've already seen it. A half-second decision. Every swipe tunes the next card in your deck.",

    screenColor: "#00F0FF",

    screenDetail: (
      <img
        src="/screenshots/04_swipe_deck.png"
        alt="Swipe your deck"
        className="w-full h-full object-cover object-top"
      />
    ),
  },

  {
    number: "03",

    headline: "Watch what's actually yours",

    body: "Your watchlist. Filtered by mood, runtime, or platform. Cached locally. Ready before you've finished your first scroll.",

    screenColor: "#FFC107",

    screenDetail: (
      <img
        src="/screenshots/07_watchlist.png"
        alt="Watch what's actually yours"
        className="w-full h-full object-cover object-top"
      />
    ),
  },
]

function PhoneMockup({
  color,
  children,
}: {
  color: string
  children: React.ReactNode
}) {
  return (
    <figure
      className="relative w-32 h-56 rounded-[20px] flex flex-col overflow-hidden flex-shrink-0"
      style={{
        background: "rgba(255,255,255,0.03)",

        border: "1.5px solid rgba(255,255,255,0.1)",

        boxShadow: `0 0 40px ${color}20`,
      }}
      aria-hidden="true"
    >
      <div className="flex-1 overflow-hidden">{children}</div>
    </figure>
  )
}

function Step({ step, index }: { step: typeof STEPS[0] index: number }) {
  const ref = useRef<HTMLDivElement>(null)

  const inView = useInView(ref, { once: true, margin: "-100px" })

  const reduced = useReducedMotion()

  return (
    <motion.div
      ref={ref}
      className="grid grid-cols-[1fr_auto_1fr] md:grid-cols-[1fr_120px_1fr] items-center gap-6 md:gap-10"
      initial={reduced ? false : { opacity: 0, y: 40 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{
        duration: 0.7,
        delay: index * 0.15,
        ease: [0.16, 1, 0.3, 1],
      }}
    >
      {/* Left: text always on right of spine — for desktop, push to right column */}
      <div className="text-right hidden md:block" />

      {/* Center: spine node + phone */}
      <div className="flex flex-col items-center">
        {/* Node */}
        <div
          className="w-10 h-10 rounded-full flex items-center justify-center z-10 relative flex-shrink-0"
          style={{
            background: `${step.screenColor}20`,

            border: `1.5px solid ${step.screenColor}50`,

            boxShadow: `0 0 16px ${step.screenColor}30`,
          }}
        >
          <span
            className="text-xs font-bold"
            style={{ color: step.screenColor, fontFamily: "var(--font-body)" }}
          >
            {String(index + 1).padStart(2, "0")}
          </span>
        </div>
        {/* Phone */}
        <div className="mt-4">
          <PhoneMockup color={step.screenColor}>
            {step.screenDetail}
          </PhoneMockup>
        </div>
      </div>

      {/* Right: copy */}
      <div className="pl-2 md:pl-6">
        <p
          className="text-xs tracking-widest uppercase mb-2 font-semibold"
          style={{ color: step.screenColor }}
        >
          Step {index + 1}
        </p>
        <h3
          className="text-2xl md:text-3xl font-bold text-white mb-3 leading-tight"
          style={{ fontFamily: "var(--font-display)" }}
        >
          {step.headline}
        </h3>
        <p
          className="text-white/45 leading-relaxed text-sm md:text-base max-w-xs"
          style={{ fontFamily: "var(--font-body)" }}
        >
          {step.body}
        </p>
      </div>
    </motion.div>
  )
}

export default function HowItWorks() {
  return (
    <section
      id="how-it-works"
      aria-labelledby="how-heading"
      className="relative py-32 overflow-hidden"
      style={{ backgroundColor: "var(--surface)" }}
    >
      {/* Background glow */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse 60% 50% at 50% 100%, rgba(107,78,255,0.08) 0%, transparent 100%)",
        }}
      />

      <div className="max-w-3xl mx-auto px-6">
        {/* Heading */}
        <div className="text-center mb-20">
          <span className="text-xs tracking-widest uppercase text-white/30 font-medium block mb-3">
            How it works
          </span>
          <h2
            id="how-heading"
            className="text-4xl md:text-5xl font-bold text-white leading-tight"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Three steps.
            <br />
            <span style={{ color: "#6B4EFF" }}>No algorithm lecture.</span>
          </h2>
        </div>

        {/* Steps with connecting spine */}
        <div className="relative">
          {/* Vertical spine line */}
          <div
            aria-hidden="true"
            className="absolute left-1/2 top-10 bottom-10 w-px -translate-x-1/2"
            style={{
              background:
                "linear-gradient(to bottom, rgba(107,78,255,0.3), rgba(0,240,255,0.15), rgba(255,193,7,0.1))",
            }}
          />

          <div className="flex flex-col gap-20">
            {STEPS.map((step, i) => (
              <Step key={step.number} step={step} index={i} />
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
