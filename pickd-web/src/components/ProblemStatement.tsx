import {
  motion,
  useScroll,
  useTransform,
  useSpring,
  useMotionValueEvent,
} from "framer-motion"
import { useRef, useState } from "react"
import { useTrendingMovies } from "../hooks/useTrendingMovies"
import { useReducedMotion } from "../hooks/useReducedMotion"

export default function ProblemStatement() {
  const containerRef = useRef<HTMLDivElement>(null)

  // Track scroll over the entire container
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  })

  // Exact 1:1 mapping with scroll position
  const progress = scrollYProgress

  const [debugVal, setDebugVal] = useState(0)
  useMotionValueEvent(scrollYProgress, "change", (val) => setDebugVal(val))

  // Background marquee uses a light spring so it continues moving slightly when scrolling stops
  const marqueeProgress = useSpring(scrollYProgress, {
    damping: 40,
    stiffness: 200,
  })

  const { movies, loading, error } = useTrendingMovies()
  const reduced = useReducedMotion()

  // -------------------------------------------------------------
  // NARRATIVE TYPOGRAPHY (Ends exactly as the section ends)
  // -------------------------------------------------------------
  const op1 = useTransform(progress, [0.0, 0.05, 0.12, 0.15], [0, 1, 1, 0]) // Another Friday night.
  const op2 = useTransform(progress, [0.15, 0.2, 0.25, 0.28], [0, 1, 1, 0]) // Netflix.
  const op3 = useTransform(progress, [0.28, 0.33, 0.38, 0.41], [0, 1, 1, 0]) // Prime Video.
  const op4 = useTransform(progress, [0.41, 0.46, 0.51, 0.54], [0, 1, 1, 0]) // Disney+.
  const op5 = useTransform(progress, [0.54, 0.59, 0.64, 0.67], [0, 1, 1, 0]) // Max.
  const op6 = useTransform(progress, [0.67, 0.72, 0.77, 0.8], [0, 1, 1, 0]) // Thousands of movies.
  const op8 = useTransform(progress, [0.8, 0.85, 0.9, 0.93], [0, 1, 1, 0]) // Still nothing to watch.
  const op9 = useTransform(progress, [0.93, 0.96, 0.99, 1.0], [0, 1, 1, 0]) // Sound familiar?

  // -------------------------------------------------------------
  // BACKGROUND ATMOSPHERE (Chaotic to dark silence)
  // -------------------------------------------------------------
  // Cold anxiety lighting fades out at the very end
  const coldGlow = useTransform(progress, [0, 0.6, 1.0], [0, 0.6, 0])

  // Poster density fades out entirely into blackness by the end
  const bgOpacity = useTransform(progress, [0, 0.2, 0.8, 1.0], [0, 0.6, 0.8, 0])
  const blurAmount = useTransform(progress, [0, 0.4, 0.9, 1.0], [
    "blur(12px)",
    "blur(3px)",
    "blur(12px)",
    "blur(40px)",
  ])
  const scaleAmount = useTransform(progress, [0, 0.5, 1], [1.1, 1, 1.3])

  // Endless scrolling effect mapping
  const xOffset1 = useTransform(marqueeProgress, [0, 1], ["0%", "-40%"])
  const xOffset2 = useTransform(marqueeProgress, [0, 1], ["-40%", "0%"])
  const xOffset3 = useTransform(marqueeProgress, [0, 1], ["0%", "-50%"])
  const xOffset4 = useTransform(marqueeProgress, [0, 1], ["-50%", "0%"])

  if (error || (!loading && movies.length === 0)) return null

  const items = [...movies, ...movies, ...movies, ...movies]

  const textStyle = {
    fontFamily: "var(--font-display)",
    position: "absolute" as const,
    top: "50%",
    left: "50%",
    transform: "translate(-50%, -50%)",
    width: "100%",
  }

  return (
    <section ref={containerRef} className="relative w-full h-[300vh] bg-ink">
      {/* On-Screen Debug HUD */}
      <div className="fixed top-20 right-4 z-50 bg-black/90 text-green-400 font-mono text-xs p-2 rounded border border-green-500/40 pointer-events-none shadow-lg">
        ProblemStatement scrollYProgress: {debugVal.toFixed(3)}
      </div>

      <div className="sticky top-0 w-full h-screen overflow-hidden flex items-center justify-center">
        {/* Cold Ambient Lighting */}
        <motion.div
          className="absolute inset-0 z-10 pointer-events-none mix-blend-screen"
          style={{ opacity: coldGlow }}
        >
          <div className="absolute top-1/4 left-1/4 w-[60vw] h-[60vw] bg-[#6B4EFF] rounded-full blur-[180px]" />
          <div className="absolute bottom-1/4 right-1/4 w-[60vw] h-[60vw] bg-[#00F0FF] rounded-full blur-[180px]" />
        </motion.div>

        {/* Dense Poster Ecosystem */}
        {reduced ? null : (
          <motion.div
            className="absolute inset-0 z-0 flex flex-col justify-center gap-4 md:gap-6 transform -rotate-12"
            style={{
              opacity: bgOpacity,
              filter: blurAmount,
              scale: scaleAmount,
            }}
          >
            <motion.div
              className="flex gap-4 md:gap-6 pr-6 w-max opacity-30"
              style={{ x: xOffset1 }}
            >
              {items.map((m, i) => (
                <div
                  key={`r1-${i}`}
                  className="w-24 md:w-36 h-36 md:h-52 rounded-xl overflow-hidden border border-white/5 bg-white/5 shadow-lg"
                >
                  <img
                    src={m.posterPath}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </motion.div>
            <motion.div
              className="flex gap-4 md:gap-6 pr-6 w-max opacity-50"
              style={{ x: xOffset2 }}
            >
              {items.map((m, i) => (
                <div
                  key={`r2-${i}`}
                  className="w-32 md:w-48 h-48 md:h-72 rounded-2xl overflow-hidden border border-white/5 bg-white/5 shadow-xl"
                >
                  <img
                    src={m.posterPath}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </motion.div>
            <motion.div
              className="flex gap-4 md:gap-6 pr-6 w-max opacity-80"
              style={{ x: xOffset3 }}
            >
              {items.map((m, i) => (
                <div
                  key={`r3-${i}`}
                  className="w-40 md:w-56 h-60 md:h-80 rounded-2xl overflow-hidden border border-white/10 bg-white/5 shadow-2xl"
                >
                  <img
                    src={m.posterPath}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </motion.div>
            <motion.div
              className="flex gap-4 md:gap-6 pr-6 w-max opacity-50"
              style={{ x: xOffset4 }}
            >
              {items.map((m, i) => (
                <div
                  key={`r4-${i}`}
                  className="w-32 md:w-48 h-48 md:h-72 rounded-2xl overflow-hidden border border-white/5 bg-white/5 shadow-xl"
                >
                  <img
                    src={m.posterPath}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </motion.div>
            <motion.div
              className="flex gap-4 md:gap-6 pr-6 w-max opacity-30"
              style={{ x: xOffset1 }}
            >
              {items.map((m, i) => (
                <div
                  key={`r5-${i}`}
                  className="w-24 md:w-36 h-36 md:h-52 rounded-xl overflow-hidden border border-white/5 bg-white/5 shadow-lg"
                >
                  <img
                    src={m.posterPath}
                    className="w-full h-full object-cover"
                  />
                </div>
              ))}
            </motion.div>
          </motion.div>
        )}

        {/* Depth Masks */}
        <div className="absolute inset-0 z-20 bg-[radial-gradient(ellipse_at_center,transparent_0%,var(--ink)_100%)] pointer-events-none" />
        <div className="absolute inset-0 z-20 bg-gradient-to-b from-transparent via-ink/40 to-ink pointer-events-none" />

        {/* Narrative Typography */}
        <div className="relative z-30 w-full max-w-5xl mx-auto px-6 h-full pointer-events-none">
          <motion.div className="absolute inset-0 flex items-center justify-center text-center">
            <motion.h2
              className="text-4xl md:text-6xl lg:text-[5rem] font-medium tracking-tight text-white/90"
              style={{ ...textStyle, opacity: op1 }}
            >
              Another Friday night.
            </motion.h2>

            <motion.h2
              className="text-5xl md:text-7xl lg:text-[7rem] font-bold tracking-tighter text-white"
              style={{ ...textStyle, opacity: op2 }}
            >
              Netflix.
            </motion.h2>
            <motion.h2
              className="text-5xl md:text-7xl lg:text-[7rem] font-bold tracking-tighter text-white"
              style={{ ...textStyle, opacity: op3 }}
            >
              Prime Video.
            </motion.h2>
            <motion.h2
              className="text-5xl md:text-7xl lg:text-[7rem] font-bold tracking-tighter text-white"
              style={{ ...textStyle, opacity: op4 }}
            >
              Disney+.
            </motion.h2>
            <motion.h2
              className="text-5xl md:text-7xl lg:text-[7rem] font-bold tracking-tighter text-white"
              style={{ ...textStyle, opacity: op5 }}
            >
              Max.
            </motion.h2>

            <motion.h2
              className="text-4xl md:text-6xl lg:text-[5rem] font-medium tracking-tight text-white/90"
              style={{ ...textStyle, opacity: op6 }}
            >
              Thousands of movies.
            </motion.h2>

            <motion.h2
              className="text-5xl md:text-7xl lg:text-[6rem] font-bold tracking-tighter text-white"
              style={{ ...textStyle, opacity: op8 }}
            >
              Still nothing to watch.
            </motion.h2>

            <motion.h2
              className="text-4xl md:text-6xl lg:text-[5rem] font-medium tracking-tight text-white"
              style={{
                ...textStyle,
                opacity: op9,
                textShadow: "0 0 60px rgba(255,255,255,0.3)",
              }}
            >
              Sound familiar?
            </motion.h2>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
