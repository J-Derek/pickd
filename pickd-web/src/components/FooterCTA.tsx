import { useRef } from "react"

import { motion, useInView, useReducedMotion } from "framer-motion"

import GlassButton from "./GlassButton"

export default function FooterCTA() {
  const ref = useRef<HTMLDivElement>(null)

  const inView = useInView(ref, { once: true, margin: "-80px" })

  const reduced = useReducedMotion()

  return (
    <section
      id="download"
      aria-label="Download and footer"
      className="relative overflow-hidden"
      style={{ backgroundColor: "var(--ink)" }}
    >
      {/* Rising indigo glow from bottom */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse 80% 60% at 50% 110%, rgba(107,78,255,0.28) 0%, transparent 70%)",
        }}
      />
      {/* Faint cyan edge top */}
      <div
        aria-hidden="true"
        className="absolute top-0 left-0 right-0 h-px"
        style={{
          background:
            "linear-gradient(to right, transparent, rgba(107,78,255,0.2), transparent)",
        }}
      />

      {/* CTA content */}
      <div
        ref={ref}
        className="relative z-10 flex flex-col items-center text-center px-6 pt-32 pb-24 max-w-3xl mx-auto"
      >
        <motion.div
          initial={reduced ? false : { opacity: 0, y: 32 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        >
          <h2
            className="text-5xl md:text-7xl font-bold text-white leading-[1.05] tracking-tight mb-6"
            style={{ fontFamily: "var(--font-display)" }}
          >
            Stop scrolling.
            <br />
            <span style={{ color: "#6B4EFF" }}>Start watching.</span>
          </h2>

          <p
            className="text-white/40 text-base md:text-lg mb-10 max-w-sm mx-auto"
            style={{ fontFamily: "var(--font-body)" }}
          >
            Android live. Free. No account required to try.
          </p>

          <GlassButton
            href="https://github.com/J-Derek/Pickd/releases"
            size="lg"
            target="_blank"
            rel="noopener noreferrer"
          >
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download APK
          </GlassButton>
        </motion.div>
      </div>

      {/* Footer links */}
      <div
        className="relative z-10 border-t flex flex-col sm:flex-row items-center justify-between gap-4 px-8 md:px-12 py-6"
        style={{ borderColor: "rgba(255,255,255,0.06)" }}
      >
        <span
          className="text-xs font-semibold tracking-tight"
          style={{
            color: "rgba(255,255,255,0.2)",

            fontFamily: "var(--font-display)",
          }}
        >
          Pickd
        </span>

        <div className="flex items-center gap-6">
          <a
            href="https://github.com/J-Derek/Pickd"
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs transition-colors duration-150 hover:text-white/40 focus:outline-none focus:underline"
            style={{
              color: "rgba(255,255,255,0.2)",

              fontFamily: "var(--font-body)",
            }}
            aria-label="Pickd GitHub repository"
          >
            GitHub
          </a>
          <a
            href="https://github.com/J-Derek/Pickd/issues"
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs transition-colors duration-150 hover:text-white/40 focus:outline-none focus:underline"
            style={{
              color: "rgba(255,255,255,0.2)",

              fontFamily: "var(--font-body)",
            }}
            aria-label="Report a bug"
          >
            Report a bug
          </a>
        </div>

        <div className="flex flex-col sm:flex-row items-center gap-4">
          <span
            className="text-xs text-white/30"
            style={{ fontFamily: "var(--font-body)" }}
          >
            This product uses the TMDB API but is not endorsed or certified by
            TMDB.
          </span>
          <span
            className="text-xs"
            style={{
              color: "rgba(255,255,255,0.12)",

              fontFamily: "var(--font-body)",
            }}
          >
            © {new Date().getFullYear()} Pickd
          </span>
        </div>
      </div>
    </section>
  )
}
