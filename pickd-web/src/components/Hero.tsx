import { motion, useScroll, useTransform } from "framer-motion"

import { useRef } from "react"

import { useReducedMotion } from "../hooks/useReducedMotion"

import GlassButton from "./GlassButton"

import TrendingMarquee from "./TrendingMarquee"

export default function Hero({
  showMarquee = true,
}: {
  showMarquee?: boolean
}) {
  const reduced = useReducedMotion()

  const containerRef = useRef<HTMLDivElement>(null)

  const { scrollYProgress } = useScroll({
    target: containerRef,

    offset: ["start start", "end start"],
  })

  // Hand-off scroll transitions for the hero text

  const yParallax = useTransform(scrollYProgress, [0, 1], ["0%", "50%"])

  const opacityFade = useTransform(scrollYProgress, [0, 0.6], [1, 0])

  return (
    <div
      ref={containerRef}
      className="relative flex flex-col items-center justify-center min-h-screen pt-24 pb-16 overflow-hidden"
      style={{ backgroundColor: "var(--ink)" }}
    >
      {/* Background Trending Marquee (Cinematic Reveal) */}
      {showMarquee && <TrendingMarquee variant="hero" />}

      {/* Content */}
      <motion.div
        className="relative z-10 flex flex-col items-center text-center px-6 max-w-5xl mx-auto w-full"
        style={{
          y: reduced ? "0%" : yParallax,

          opacity: reduced ? 1 : opacityFade,
        }}
        initial="hidden"
        animate="visible"
        variants={{
          hidden: { opacity: 0 },

          visible: {
            opacity: 1,

            transition: {
              staggerChildren: 0.15,
            },
          },
        }}
      >
        {/* Badge */}
        <motion.div
          variants={{
            hidden: { opacity: 0, y: 16, filter: "blur(4px)" },

            visible: {
              opacity: 1,

              y: 0,

              filter: "blur(0px)",

              transition: {
                duration: 0.8,

                type: "spring",

                bounce: 0,

                damping: 20,
              },
            },
          }}
          className="mb-8 inline-flex items-center gap-2.5 rounded-full px-4 py-1.5 text-xs font-semibold uppercase tracking-widest shadow-xl"
          style={{
            background: "rgba(255,255,255,0.03)",

            border: "1px solid rgba(255,255,255,0.1)",

            color: "rgba(255,255,255,0.6)",

            fontFamily: "var(--font-body)",

            backdropFilter: "blur(12px)",
          }}
        >
          <span
            className="w-1.5 h-1.5 rounded-full bg-[#6B4EFF] animate-pulse shadow-[0_0_8px_#6B4EFF]"
            aria-hidden="true"
          />
          Android live · iOS coming soon
        </motion.div>

        {/* Headline */}
        <motion.h1
          variants={{
            hidden: { opacity: 0, y: 24, filter: "blur(8px)" },

            visible: {
              opacity: 1,

              y: 0,

              filter: "blur(0px)",

              transition: {
                duration: 1.2,

                type: "spring",

                bounce: 0,

                damping: 25,
              },
            },
          }}
          className="text-[4rem] sm:text-7xl md:text-8xl lg:text-[9rem] font-bold leading-[0.95] tracking-tighter text-white mb-8"
          style={{
            fontFamily: "var(--font-display)",

            textShadow: "0 20px 40px rgba(0,0,0,0.5)",
          }}
        >
          Stop scrolling.
          <br />
          <span className="text-white">Start watching.</span>
        </motion.h1>

        {/* Subhead */}
        <motion.p
          variants={{
            hidden: { opacity: 0, y: 16, filter: "blur(4px)" },

            visible: {
              opacity: 1,

              y: 0,

              filter: "blur(0px)",

              transition: {
                duration: 1,

                type: "spring",

                bounce: 0,

                damping: 20,
              },
            },
          }}
          className="text-lg md:text-xl lg:text-2xl text-white/50 max-w-2xl mb-14 leading-relaxed font-medium"
          style={{ fontFamily: "var(--font-body)" }}
        >
          Pick three movies you love. We build your Taste DNA and deal a
          personalized deck. Decisions in seconds, not hours.
        </motion.p>

        {/* CTA row */}
        <motion.div
          className="flex flex-col sm:flex-row items-center gap-6"
          variants={{
            hidden: { opacity: 0, y: 16 },

            visible: {
              opacity: 1,

              y: 0,

              transition: {
                duration: 1,

                type: "spring",

                bounce: 0,

                damping: 20,
              },
            },
          }}
        >
          <a
            href="https://github.com/J-Derek/Pickd/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="group relative inline-flex items-center gap-3 rounded-full px-8 py-4 text-base font-semibold text-white transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-[#6B4EFF]/50 focus:ring-offset-2 focus:ring-offset-[#0A0A0F]"
            style={{
              background: "rgba(255,255,255,0.05)",

              border: "1px solid rgba(255,255,255,0.1)",

              backdropFilter: "blur(20px)",

              boxShadow:
                "0 10px 30px -10px rgba(107,78,255,0.3), inset 0 1px 0 0 rgba(255,255,255,0.1)",
            }}
          >
            <div className="absolute inset-0 rounded-full bg-gradient-to-r from-[#6B4EFF]/20 to-[#00F0FF]/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="relative z-10 transition-transform duration-300 group-hover:-translate-y-0.5 group-hover:scale-105 text-[#6B4EFF]"
              aria-hidden="true"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            <span className="relative z-10">Download APK</span>
          </a>

          <a
            href="#how-it-works"
            className="text-sm font-medium text-white/40 hover:text-white/80 transition-colors duration-300 flex items-center gap-2 group"
          >
            See how it works
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="transition-transform duration-300 group-hover:translate-x-1"
              aria-hidden="true"
            >
              <polyline points="9 18 15 12 9 6" />
            </svg>
          </a>
        </motion.div>
      </motion.div>

      {/* Scroll nudge - Handoff indicator */}
      <motion.div
        className="absolute bottom-0 left-1/2 -translate-x-1/2 h-24"
        initial={reduced ? false : { opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.5, duration: 1 }}
        aria-hidden="true"
      >
        <div
          className="w-px h-full mx-auto"
          style={{
            background:
              "linear-gradient(to bottom, transparent, rgba(255,255,255,0.2), transparent)",
          }}
        />
      </motion.div>
    </div>
  )
}
