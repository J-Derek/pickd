import {
  motion,
  useScroll,
  useTransform,
} from "framer-motion"
import { useRef } from "react"
import { useTrendingMovies } from "../hooks/useTrendingMovies"

export default function PhoneRevealV2() {
  const containerRef = useRef<HTMLElement>(null)

  // Single Master scrollYProgress
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end end"],
  })

  // -------------------------------------------------------------
  // MASTER TIMELINE DERIVATIONS (Clamped Keyframes)
  // -------------------------------------------------------------

  // 0.00 – 0.20: Phone Emergence
  const phoneOpacity = useTransform(scrollYProgress, [0.0, 0.2, 1.0], [0, 1, 1])
  const phoneY = useTransform(scrollYProgress, [0.0, 0.2, 1.0], [120, 0, 0])
  const phoneScale = useTransform(scrollYProgress, [0.0, 0.2, 1.0], [0.93, 1.0, 1.0])
  const phoneRotateX = useTransform(scrollYProgress, [0.0, 0.2, 1.0], [10, 0, 0])

  // 0.20 – 0.40: Phone settles in complete stillness (No changes)

  // 0.40 – 0.65: Display wakes naturally & ambient lighting turns on
  const ambientGlowOpacity = useTransform(
    scrollYProgress,
    [0.4, 0.65, 1.0],
    [0, 0.65, 0.65],
  )
  const phoneBacklightOpacity = useTransform(
    scrollYProgress,
    [0.4, 0.65, 1.0],
    [0, 0.8, 0.8],
  )
  const screenBacklightOpacity = useTransform(
    scrollYProgress,
    [0.40, 0.55, 1.0],
    [0, 0.35, 0.35],
  )
  const displayWakeOpacity = useTransform(
    scrollYProgress,
    [0.45, 0.65, 1.0],
    [0, 1, 1],
  )
  const displayWakeScale = useTransform(
    scrollYProgress,
    [0.45, 0.65, 1.0],
    [0.97, 1.0, 1.0],
  )

  // 0.65 – 0.85: One deliberate, satisfying card swipe
  const swipeX = useTransform(scrollYProgress, [0.65, 0.85, 1.0], [0, 340, 340])
  const swipeY = useTransform(scrollYProgress, [0.65, 0.85, 1.0], [0, 24, 24])
  const swipeRotate = useTransform(scrollYProgress, [0.65, 0.85, 1.0], [0, 22, 22])
  const swipeOpacity = useTransform(scrollYProgress, [0.75, 0.85, 1.0], [1, 0, 0])

  const backCardScale = useTransform(scrollYProgress, [0.65, 0.85, 1.0], [0.88, 1.0, 1.0])
  const backCardOpacity = useTransform(scrollYProgress, [0.65, 0.85, 1.0], [0.4, 1.0, 1.0])

  // 0.85 – 1.00: Everything stops.

  const { movies, loading, error } = useTrendingMovies()

  if (error || (!loading && movies.length === 0)) return null

  const topCardMovie = movies[0]
  const backCardMovie = movies[1]

  return (
    <section ref={containerRef} className="relative w-full h-[250vh] bg-ink">
      <div className="sticky top-0 w-full h-screen overflow-hidden flex items-center justify-center">
        {/* Environmental Warm Glow */}
        <motion.div
          className="absolute inset-0 z-10 pointer-events-none mix-blend-screen"
          style={{ opacity: ambientGlowOpacity }}
        >
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[80vw] h-[80vw] bg-[#FFC107] rounded-full blur-[200px]" />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[45vw] h-[45vw] bg-[#6B4EFF] rounded-full blur-[160px] opacity-50" />
        </motion.div>

        {/* Dedicated Phone Backlight Aura (Anchored behind device) */}
        <motion.div
          className="absolute z-20 pointer-events-none mix-blend-screen"
          style={{ opacity: phoneBacklightOpacity }}
        >
          <div className="w-[440px] h-[740px] rounded-[80px] bg-gradient-to-b from-[#00F0FF]/30 via-[#6B4EFF]/35 to-[#FFC107]/20 blur-[80px]" />
        </motion.div>

        {/* HERO DEVICE CONTAINER */}
        <motion.div
          className="relative z-40 flex items-center justify-center w-full h-full pointer-events-none"
          style={{
            opacity: phoneOpacity,
            y: phoneY,
            scale: phoneScale,
            rotateX: phoneRotateX,
            perspective: 1200,
          }}
        >
          {/* SUBTLE IDLE MICRO-MOTION FLOAT */}
          <motion.div
            className="relative"
            animate={{ y: [0, -6, 0], rotate: [0, 0.3, 0] }}
            transition={{ repeat: Infinity, duration: 5, ease: "easeInOut" }}
          >
            {/* Left Side: Volume Buttons */}
            <div className="absolute left-[-5px] top-28 w-[5px] h-12 bg-[#2a2a2d] rounded-l-md border-y border-l border-white/10" />
            <div className="absolute left-[-5px] top-44 w-[5px] h-12 bg-[#2a2a2d] rounded-l-md border-y border-l border-white/10" />

            {/* Right Side: Power Button */}
            <div className="absolute right-[-5px] top-36 w-[5px] h-16 bg-[#2a2a2d] rounded-r-md border-y border-r border-white/10" />

            {/* Phone Hardware Chassis */}
            <div
              className="relative w-[310px] h-[620px] rounded-[48px] border-[5px] border-[#38383e] bg-[#09090b] overflow-hidden flex flex-col items-center justify-center"
              style={{
                boxShadow:
                  "0 45px 100px rgba(0,0,0,0.95), inset 0 1px 2px rgba(255,255,255,0.25), inset 0 -2px 4px rgba(0,0,0,0.9)",
              }}
            >
              {/* Metallic Bezel Specular Highlight Rim */}
              <div className="absolute inset-0 rounded-[43px] border border-white/15 pointer-events-none z-50" />

              {/* DYNAMIC ISLAND / NOTCH & LENSES */}
              <div className="absolute top-4 z-50 w-24 h-5 bg-black rounded-full border border-white/15 flex items-center justify-end px-2 gap-1.5 shadow-md">
                <div className="w-2 h-2 rounded-full bg-[#00F0FF]/50 animate-pulse" />
                <div className="w-1.5 h-1.5 rounded-full bg-white/20" />
              </div>

              {/* Speaker Bezel Notch Line */}
              <div className="absolute top-1.5 z-50 w-12 h-1 bg-[#1a1a1c] rounded-full border-t border-white/5" />

              {/* BLACK GLASS SCREEN CONTAINER (Sleeping Display) */}
              <div className="absolute inset-0 bg-[#0c0c0e] rounded-[43px] overflow-hidden z-20 pointer-events-none">
                {/* Screen Backlight Glow Layer */}
                <motion.div
                  className="absolute inset-0 bg-gradient-to-b from-[#6B4EFF]/20 via-[#00F0FF]/10 to-transparent z-10"
                  style={{ opacity: screenBacklightOpacity }}
                />

                {/* Display UI Chrome Interface */}
                <motion.div
                  className="absolute inset-0 z-20 flex flex-col items-center justify-between pt-18 pb-4 px-4 bg-gradient-to-tr from-[#0a0a0f] via-[#120f26] to-[#0c0c0e]"
                  style={{
                    opacity: displayWakeOpacity,
                    scale: displayWakeScale,
                  }}
                >
                  {/* Wallpaper ambient colored background */}
                  <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(107,78,255,0.15)_0%,transparent_70%)]" />

                  {/* UI Status Header Mock */}
                  <div className="absolute top-12 w-full px-6 flex justify-between items-center opacity-40 z-30">
                    <span className="text-[10px] font-mono text-white tracking-widest uppercase">
                      9:41
                    </span>
                    <div className="flex gap-1">
                      <div className="w-2 h-2 rounded-full bg-white/40" />
                      <div className="w-2 h-2 rounded-full bg-white/40" />
                    </div>
                  </div>

                  {/* CARD STACK CONTAINER */}
                  <div className="relative w-[265px] h-[375px] flex items-center justify-center">
                    {/* Layer E: Second Card */}
                    <motion.div
                      className="absolute w-[265px] h-[375px] rounded-2xl overflow-hidden border border-white/10 shadow-lg"
                      style={{
                        scale: backCardScale,
                        opacity: backCardOpacity,
                      }}
                    >
                      {backCardMovie && (
                        <>
                          <img
                            src={backCardMovie.posterPath}
                            className="w-full h-full object-cover"
                          />
                          <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent flex flex-col justify-end p-5">
                            <span className="text-white font-bold text-lg leading-tight">
                              {backCardMovie.title}
                            </span>
                            <span className="text-[#6B4EFF] font-semibold text-xs mt-1 tracking-wide">
                              98% Match
                            </span>
                          </div>
                        </>
                      )}
                    </motion.div>

                    {/* Layer D: Top Card */}
                    <motion.div
                      className="absolute w-[265px] h-[375px] rounded-2xl overflow-hidden border border-white/20 shadow-[0_20px_40px_rgba(0,0,0,0.8)] bg-black"
                      style={{
                        x: swipeX,
                        y: swipeY,
                        rotate: swipeRotate,
                        opacity: swipeOpacity,
                        transformOrigin: "bottom center",
                      }}
                    >
                      {topCardMovie && (
                        <>
                          <img
                            src={topCardMovie.posterPath}
                            className="w-full h-full object-cover opacity-95"
                          />
                          <div className="absolute inset-0 bg-gradient-to-t from-black/95 via-black/30 to-transparent flex flex-col justify-end p-5">
                            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/10 backdrop-blur-md border border-white/15 w-max mb-2">
                              <span className="w-1.5 h-1.5 rounded-full bg-[#00F0FF]" />
                              <span className="text-[10px] font-semibold text-white/90 tracking-wide">
                                Pickd Deck
                              </span>
                            </div>
                            <span className="text-white font-bold text-xl leading-tight">
                              {topCardMovie.title}
                            </span>
                            <span className="text-[#00F0FF] font-semibold text-xs mt-1 tracking-wide">
                              94% Match
                            </span>
                          </div>
                        </>
                      )}
                    </motion.div>
                  </div>

                  {/* UI Action Control Bar */}
                  <div className="absolute bottom-6 flex gap-7 items-center opacity-85 z-30">
                    <div className="w-13 h-13 rounded-full border border-white/10 flex items-center justify-center bg-white/5 shadow-md">
                      <span className="text-white/60 text-lg font-light">
                        ✕
                      </span>
                    </div>
                    <div className="w-14 h-14 rounded-full bg-gradient-to-tr from-[#6B4EFF] to-[#00F0FF] flex items-center justify-center shadow-[0_0_25px_rgba(107,78,255,0.5)] border border-white/20">
                      <svg
                        width="22"
                        height="22"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="white"
                        strokeWidth="2.8"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="M20 6L9 17l-5-5" />
                      </svg>
                    </div>
                  </div>
                </motion.div>

                {/* Display sheen reflection */}
                <div
                  className="absolute inset-0 z-30 opacity-[0.06] bg-gradient-to-tr from-white via-transparent to-transparent"
                  style={{ mixBlendMode: "overlay" }}
                />

                {/* Inner bezel safety ring */}
                <div className="absolute inset-[3px] rounded-[40px] border border-white/5 opacity-40 z-30" />
              </div>

              {/* Outer Specular Glaze Reflection */}
              <div
                className="absolute inset-0 z-40 pointer-events-none opacity-10"
                style={{
                  background:
                    "linear-gradient(135deg, rgba(255,255,255,0.4) 0%, rgba(255,255,255,0) 50%, rgba(255,255,255,0) 100%)",
                }}
              />
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}
