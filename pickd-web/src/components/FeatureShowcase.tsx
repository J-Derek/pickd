import { useRef, useState, useEffect, useCallback } from "react"

import { motion, useScroll, useTransform } from "framer-motion"

import { useReducedMotion } from "../hooks/useReducedMotion"

import InteractiveGrid from "./InteractiveGrid"

const FEATURES = [
  {
    number: "01",

    accent: "#6B4EFF",

    icon: (
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M4 4c0 4 16 12 16 16" />
        <path d="M20 4c0 4-16 12-16 16" />
        <line x1="8" y1="8" x2="16" y2="8" opacity="0.6" />
        <line x1="6" y1="12" x2="18" y2="12" opacity="0.6" />
        <line x1="8" y1="16" x2="16" y2="16" opacity="0.6" />
      </svg>
    ),

    headline: "Skip the genre quiz.",

    body: "Three movies. That's it. Pickd builds an emotional fingerprint of your taste instead of sorting you into a checkbox.",

    tag: "Taste DNA",
  },

  {
    number: "02",

    accent: "#00F0FF",

    icon: (
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <rect x="4" y="6" width="12" height="14" rx="2" opacity="0.5" />
        <rect x="8" y="2" width="12" height="14" rx="2" />
        <path d="M12 22 A 8 8 0 0 0 22 12" opacity="0.6" />
        <polyline points="18 22 22 22 22 18" opacity="0.6" />
      </svg>
    ),

    headline: "Decide in half a second.",

    body: "Right to watch, left to pass. Every swipe trains your deck to know you better than your group chat does.",

    tag: "Swipe Deck",
  },

  {
    number: "03",

    accent: "#FFC107",

    icon: (
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <polygon points="12 4 17 10 12 20 7 10 12 4" />
        <polygon points="12 4 12 20" opacity="0.5" />
        <polygon points="7 10 17 10" opacity="0.5" />
        <circle cx="12" cy="12" r="10" opacity="0.3" strokeDasharray="4 4" />
      </svg>
    ),

    headline: "Deeper than the homepage.",

    body: "Critically loved, barely seen. Hidden Gems surfaces what streaming platforms bury under their own promoted rows.",

    tag: "Hidden Gems",
  },

  {
    number: "04",

    accent: "#6B4EFF",

    icon: (
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <line x1="4" y1="6" x2="20" y2="6" opacity="0.5" />
        <line x1="4" y1="12" x2="14" y2="12" opacity="0.5" />
        <line x1="4" y1="18" x2="20" y2="18" opacity="0.5" />
        <polygon points="16 10 22 14 16 18 16 10" />
      </svg>
    ),

    headline: "Zero latency, zero excuses.",

    body: 'Filter by mood, runtime, or platform, instantly, cached locally. No spinner, no "buffering."',

    tag: "Dynamic Watchlist",
  },
]

const cardVariants = {
  active: {
    y: 0,

    x: 0,

    rotate: 0,

    opacity: 1,

    scaleX: [1, 0.75, 1.1, 1],

    scaleY: [1, 1.25, 0.92, 1],

    filter: ["blur(0px)", "blur(8px)", "blur(0px)"],

    transition: {
      y: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      x: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      rotate: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      opacity: { duration: 0.4 },

      scaleX: {
        duration: 0.65,
        times: [0, 0.4, 0.7, 1],
        ease: "easeInOut" as const,
      },

      scaleY: {
        duration: 0.65,
        times: [0, 0.4, 0.7, 1],
        ease: "easeInOut" as const,
      },

      filter: {
        duration: 0.65,
        times: [0, 0.5, 1],
        ease: "easeInOut" as const,
      },
    },
  },

  inactiveTop: {
    y: -400,

    x: -40,

    rotate: -5,

    opacity: 0,

    scaleX: [1, 0.75, 1.1, 1],

    scaleY: [1, 1.25, 0.92, 1],

    filter: ["blur(0px)", "blur(8px)", "blur(0px)"],

    transition: {
      y: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      x: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      rotate: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      opacity: { duration: 0.4 },

      scaleX: {
        duration: 0.65,
        times: [0, 0.4, 0.7, 1],
        ease: "easeInOut" as const,
      },

      scaleY: {
        duration: 0.65,
        times: [0, 0.4, 0.7, 1],
        ease: "easeInOut" as const,
      },

      filter: {
        duration: 0.65,
        times: [0, 0.5, 1],
        ease: "easeInOut" as const,
      },
    },
  },

  inactiveBottom: {
    y: 400,

    x: 40,

    rotate: 10,

    opacity: 0,

    scaleX: [1, 0.75, 1.1, 1],

    scaleY: [1, 1.25, 0.92, 1],

    filter: ["blur(0px)", "blur(8px)", "blur(0px)"],

    transition: {
      y: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      x: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      rotate: {
        duration: 0.65,
        ease: [0.25, 1, 0.35, 1] as [number, number, number, number],
      },

      opacity: { duration: 0.4 },

      scaleX: {
        duration: 0.65,
        times: [0, 0.4, 0.7, 1],
        ease: "easeInOut" as const,
      },

      scaleY: {
        duration: 0.65,
        times: [0, 0.4, 0.7, 1],
        ease: "easeInOut" as const,
      },

      filter: {
        duration: 0.65,
        times: [0, 0.5, 1],
        ease: "easeInOut" as const,
      },
    },
  },
}

function PhysicalTicketContent({
  feature,
  index,
}: {
  feature: typeof FEATURES[0]
  index: number
}) {
  return (
    <>
      <svg width="0" height="0" className="absolute pointer-events-none">
        <defs>
          <mask
            id={`ticket-mask-${index}`}
            maskContentUnits="objectBoundingBox"
          >
            <path
              d="M 0.08,0 L 0.92,0 A 0.08 0.064 0 0 1 1 0.064 L 1 0.45 A 0.06 0.048 0 0 0 1 0.55 L 1 0.936 A 0.08 0.064 0 0 1 0.92 1 L 0.08 1 A 0.08 0.064 0 0 1 0 0.936 L 0 0.55 A 0.06 0.048 0 0 0 0 0.45 L 0 0.064 A 0.08 0.064 0 0 1 0.08 0 Z"
              fill="white"
            />

            {/* Film Sprocket Holes along the left edge */}
            {Array.from({ length: 8 }).map((_, i) => (
              <rect
                key={`sprocket-top-${i}`}
                x="0.04"
                y={0.12 + i * 0.035}
                width="0.02"
                height="0.015"
                rx="0.005"
                fill="black"
              />
            ))}
            {Array.from({ length: 8 }).map((_, i) => (
              <rect
                key={`sprocket-bot-${i}`}
                x="0.04"
                y={0.6 + i * 0.035}
                width="0.02"
                height="0.015"
                rx="0.005"
                fill="black"
              />
            ))}
          </mask>

          <filter id={`noiseFilter-${index}`}>
            <feTurbulence
              type="fractalNoise"
              baseFrequency="0.9"
              numOctaves="3"
              stitchTiles="stitch"
            />
            <feColorMatrix
              type="matrix"
              values="1 0 0 0 0, 0 1 0 0 0, 0 0 1 0 0, 0 0 0 0.25 0"
            />
          </filter>

          <linearGradient
            id={`foil-gradient-${index}`}
            x1="0"
            y1="0"
            x2="1"
            y2="1"
          >
            <stop offset="0%" stopColor="white" stopOpacity="0.9" />
            <stop offset="25%" stopColor="transparent" />
            <stop offset="75%" stopColor="transparent" />
            <stop offset="100%" stopColor="white" stopOpacity="0.7" />
          </linearGradient>
        </defs>
      </svg>

      {/* Physical Matte Card Body */}
      <div
        className="absolute inset-0 bg-[#0d0d0f]"
        style={{
          WebkitMaskImage: `url(#ticket-mask-${index})`,
          maskImage: `url(#ticket-mask-${index})`,
        }}
      >
        {/* Noise overlay for tactile paper feel */}
        <div
          className="absolute inset-0 pointer-events-none opacity-40"
          style={{ mixBlendMode: "overlay" }}
        >
          <svg className="w-full h-full">
            <rect
              width="100%"
              height="100%"
              filter={`url(#noiseFilter-${index})`}
            />
          </svg>
        </div>

        {/* Content */}
        <div className="relative z-20 h-full p-8 pl-12 flex flex-col justify-between">
          {/* Subtle debossed structural lines */}
          <div className="absolute top-8 left-12 right-6 h-px bg-white/5" />
          <div className="absolute bottom-8 left-12 right-6 h-px bg-white/5" />

          <div>
            <span
              className="text-xs font-semibold tracking-widest uppercase mb-6 block"
              style={{ color: feature.accent, fontFamily: "var(--font-body)" }}
            >
              {feature.number}
            </span>

            {/* Foil Tag Pill */}
            <div
              className="inline-flex items-center gap-2 rounded-full px-3 py-1.5 mb-6 relative overflow-hidden"
              style={{
                background: `linear-gradient(135deg, ${feature.accent}15, transparent)`,

                border: `1px solid ${feature.accent}50`,

                boxShadow: `inset 0 1px 0 0 rgba(255,255,255,0.15)`,
              }}
            >
              <div style={{ color: feature.accent }}>{feature.icon}</div>
              <span
                className="text-xs font-bold text-white/90"
                style={{ fontFamily: "var(--font-body)" }}
              >
                {feature.tag}
              </span>
            </div>

            <h3
              className="text-2xl md:text-3xl font-bold text-white leading-tight mb-4"
              style={{
                fontFamily: "var(--font-display)",
                textShadow: "0 2px 10px rgba(0,0,0,0.8)",
              }}
            >
              {feature.headline}
            </h3>

            <p
              className="text-white/70 leading-relaxed text-sm md:text-base font-medium"
              style={{ fontFamily: "var(--font-body)" }}
            >
              {feature.body}
            </p>
          </div>

          <div
            className="h-[2px] w-full mt-6 opacity-90"
            style={{
              background: `linear-gradient(to right, ${feature.accent}, transparent)`,
            }}
            aria-hidden="true"
          />
        </div>
      </div>

      {/* Foil Edge Tracing */}
      <svg
        className="absolute inset-0 w-full h-full pointer-events-none z-10"
        viewBox="0 0 1 1"
        preserveAspectRatio="none"
      >
        <path
          d="M 0.08,0 L 0.92,0 A 0.08 0.064 0 0 1 1 0.064 L 1 0.45 A 0.06 0.048 0 0 0 1 0.55 L 1 0.936 A 0.08 0.064 0 0 1 0.92 1 L 0.08 1 A 0.08 0.064 0 0 1 0 0.936 L 0 0.55 A 0.06 0.048 0 0 0 0 0.45 L 0 0.064 A 0.08 0.064 0 0 1 0.08 0 Z"
          fill="none"
          stroke={feature.accent}
          strokeWidth="1.5"
          vectorEffect="non-scaling-stroke"
          className="opacity-70"
        />
        <path
          d="M 0.08,0 L 0.92,0 A 0.08 0.064 0 0 1 1 0.064 L 1 0.45 A 0.06 0.048 0 0 0 1 0.55 L 1 0.936 A 0.08 0.064 0 0 1 0.92 1 L 0.08 1 A 0.08 0.064 0 0 1 0 0.936 L 0 0.55 A 0.06 0.048 0 0 0 0 0.45 L 0 0.064 A 0.08 0.064 0 0 1 0.08 0 Z"
          fill="none"
          stroke={`url(#foil-gradient-${index})`}
          strokeWidth="3"
          vectorEffect="non-scaling-stroke"
          className="opacity-80"
          style={{ mixBlendMode: "screen" }}
        />
      </svg>
    </>
  )
}

function FeatureCard({
  feature,
  index,
  activeIndex,
}: {
  feature: typeof FEATURES[0]
  index: number
  activeIndex: number
}) {
  const reduced = useReducedMotion()

  const isActive = index === activeIndex

  const isPast = index < activeIndex

  const state = isActive ? "active" : isPast ? "inactiveTop" : "inactiveBottom"

  return (
    <motion.div
      className="absolute w-80 md:w-96 h-[480px] flex flex-col justify-between"
      style={{
        transformOrigin: "center center",

        filter: "drop-shadow(0 30px 40px rgba(0,0,0,0.6))",
      }}
      variants={cardVariants}
      initial={false}
      animate={
        reduced
          ? { opacity: isActive ? 1 : 0, y: isActive ? 0 : isPast ? -40 : 40 }
          : state
      }
      transition={reduced ? { duration: 0.4 } : undefined}
    >
      <PhysicalTicketContent feature={feature} index={index} />
    </motion.div>
  )
}

function MobileCarousel() {
  const [active, setActive] = useState(0)

  const trackRef = useRef<HTMLDivElement>(null)

  const reduced = useReducedMotion()

  useEffect(() => {
    const track = trackRef.current

    if (!track) return

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const idx = Number((entry.target as HTMLElement).dataset.index)

            setActive(idx)
          }
        })
      },

      { root: track, threshold: 0.5 },
    )

    Array.from(track.children).forEach((child) => observer.observe(child))

    return () => observer.disconnect()
  }, [])

  return (
    <div className="w-full">
      <div
        ref={trackRef}
        className="flex gap-4 overflow-x-auto pb-4"
        style={{
          scrollSnapType: "x mandatory",

          scrollbarWidth: "none",

          msOverflowStyle: "none",

          paddingLeft: "calc(50vw - 160px)",

          paddingRight: "calc(50vw - 160px)",
        }}
        role="list"
        aria-label="Feature cards"
      >
        {FEATURES.map((feature, i) => (
          <div
            key={feature.tag}
            data-index={i}
            style={{ scrollSnapAlign: "center", flexShrink: 0 }}
            role="listitem"
          >
            <motion.div
              className="w-72 h-[420px] flex flex-col justify-between relative"
              style={{
                transformOrigin: "bottom center",

                filter: "drop-shadow(0 20px 30px rgba(0,0,0,0.5))",
              }}
              {...(reduced
                ? {}
                : {
                    initial: { opacity: 0, y: -40 },

                    whileInView: { opacity: 1, y: 0 },

                    viewport: { once: true, margin: "-50px" },

                    transition: {
                      y: {
                        type: "spring",
                        bounce: 0,
                        duration: 0.6,
                        delay: i * 0.1,
                      },

                      opacity: { duration: 0.4, delay: i * 0.1 },
                    },
                  })}
            >
              <PhysicalTicketContent feature={feature} index={i} />
            </motion.div>
          </div>
        ))}
      </div>

      {/* Dot indicators */}
      <div
        className="flex justify-center gap-2 mt-6"
        role="tablist"
        aria-label="Feature card navigation"
      >
        {FEATURES.map((_, i) => (
          <button
            key={i}
            role="tab"
            aria-selected={i === active}
            aria-label={`Go to feature ${i + 1}`}
            onClick={() => {
              const track = trackRef.current

              if (!track) return

              const child = track.children[i] as HTMLElement

              child.scrollIntoView({
                behavior: "smooth",
                block: "nearest",
                inline: "center",
              })
            }}
            className="transition-all duration-300 rounded-full focus:outline-none focus:ring-2 focus:ring-[#6B4EFF]/50"
            style={{
              width: i === active ? 20 : 6,

              height: 6,

              background: i === active ? "#6B4EFF" : "rgba(255,255,255,0.2)",
            }}
          />
        ))}
      </div>
    </div>
  )
}

function DesktopDeck() {
  const [activeIndex, setActiveIndex] = useState(0)

  const reduced = useReducedMotion()

  useEffect(() => {
    if (reduced) return

    const timer = setInterval(() => {
      setActiveIndex((prev) => (prev + 1) % FEATURES.length)
    }, 3000)

    return () => clearInterval(timer)
  }, [reduced])

  if (reduced) {
    return (
      <div className="flex flex-col gap-12 max-w-2xl mx-auto px-6 py-24">
        {/* Section label */}
        <div className="text-center mb-8">
          <span className="text-xs tracking-widest uppercase text-white/30 font-medium">
            Features
          </span>
        </div>
        {FEATURES.map((feature, i) => (
          <div
            key={feature.tag}
            className="flex flex-col justify-between relative h-[480px]"
            style={{
              filter: "drop-shadow(0 30px 40px rgba(0,0,0,0.6))",
            }}
          >
            <PhysicalTicketContent feature={feature} index={i} />
          </div>
        ))}
      </div>
    )
  }

  return (
    <div className="relative h-screen flex flex-col items-center justify-center overflow-hidden py-24">
      {/* Section label */}
      <div className="absolute top-12 left-1/2 -translate-x-1/2 text-center">
        <span className="text-xs tracking-widest uppercase text-white/30 font-medium">
          Features
        </span>
      </div>

      {/* Progress dots */}
      <div
        className="absolute right-10 top-1/2 -translate-y-1/2 flex flex-col gap-3"
        role="tablist"
        aria-label="Feature navigation"
      >
        {FEATURES.map((_, i) => (
          <button
            key={i}
            role="tab"
            aria-selected={i === activeIndex}
            aria-label={`Feature ${i + 1}`}
            onClick={() => setActiveIndex(i)}
            className="rounded-full transition-all duration-400 focus:outline-none"
            style={{
              width: 6,

              height: i === activeIndex ? 20 : 6,

              background:
                i === activeIndex ? "#6B4EFF" : "rgba(255,255,255,0.2)",
            }}
          />
        ))}
      </div>

      {/* Card deck container */}
      <div
        className="relative flex items-center justify-center w-full max-w-2xl h-[480px]"
        style={{ perspective: "1200px" }}
      >
        {FEATURES.map((feature, i) => (
          <FeatureCard
            key={feature.tag}
            feature={feature}
            index={i}
            activeIndex={activeIndex}
          />
        ))}
      </div>

      {/* Active headline echo */}
      <motion.div
        className="absolute bottom-16 left-1/2 -translate-x-1/2 text-center"
        key={activeIndex}
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.3 }}
      >
        <span
          className="text-xs text-white/25 tracking-wide"
          style={{ fontFamily: "var(--font-body)" }}
        >
          Auto-playing
        </span>
      </motion.div>
    </div>
  )
}

export default function FeatureShowcase() {
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const mq = window.matchMedia("(max-width: 767px)")

    const handle = (e: MediaQueryListEvent) => setIsMobile(e.matches)

    setIsMobile(mq.matches)

    mq.addEventListener("change", handle)

    return () => mq.removeEventListener("change", handle)
  }, [])

  return (
    <section
      id="features"
      aria-label="Features"
      className="relative overflow-hidden z-0"
      style={{ backgroundColor: "var(--ink)" }}
    >
      <InteractiveGrid className="z-0 opacity-80" />
      <div className="relative z-10">
        {isMobile ? (
          <div className="py-20 px-4">
            <div className="text-center mb-12">
              <span className="text-xs tracking-widest uppercase text-white/30 font-medium block mb-3">
                Features
              </span>
              <h2
                className="text-3xl font-bold text-white"
                style={{ fontFamily: "var(--font-display)" }}
              >
                Built around how you actually choose.
              </h2>
            </div>
            <MobileCarousel />
          </div>
        ) : (
          <DesktopDeck />
        )}
      </div>
    </section>
  )
}
