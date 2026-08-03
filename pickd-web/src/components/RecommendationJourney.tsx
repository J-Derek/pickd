import { motion, useScroll, useTransform } from "framer-motion"
import { useRef } from "react"
import { useTrendingMovies } from "../hooks/useTrendingMovies"

export default function RecommendationJourney() {
  const containerRef = useRef<HTMLElement>(null)
  
  // Single master scrollYProgress for Scene 4 (Stretched to 200vh for cinematic pacing)
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end end"],
  })

  // -------------------------------------------------------------
  // CINEMATIC EASING CURVES & MAPPINGS
  // -------------------------------------------------------------

  // Left Title Fade (Fades in slowly at start, holds, and exits cleanly at the end)
  const leftOpacity = useTransform(
    scrollYProgress, 
    [0.0, 0.20, 0.85, 0.95], 
    [0, 1, 1, 0]
  )
  const leftY = useTransform(
    scrollYProgress, 
    [0.0, 0.20, 0.85, 0.95], 
    [40, 0, 0, -40]
  )

  // Center Poster Handoff & Stretched Hero Shot Pause (0.00 - 0.30 transition, 0.30 - 0.50 pause)
  const posterScale = useTransform(
    scrollYProgress, 
    [0.0, 0.25, 0.85, 0.95], 
    [0.94, 1.0, 1.0, 0.96]
  )
  const posterY = useTransform(
    scrollYProgress, 
    [0.0, 0.25, 0.85, 0.95], 
    [60, 0, 0, -60]
  )
  const posterOpacity = useTransform(
    scrollYProgress, 
    [0.0, 0.18, 0.85, 0.95], 
    [0, 1, 1, 0]
  )

  // Affinity Anchor 1 Reveal (Fades in gently after the hero pause, around 0.50)
  const anchor1Opacity = useTransform(
    scrollYProgress, 
    [0.48, 0.62, 0.85, 0.95], 
    [0, 1, 1, 0]
  )
  const anchor1Y = useTransform(
    scrollYProgress, 
    [0.48, 0.62, 0.85, 0.95], 
    [15, 0, 0, -15]
  )
  const line1Length = useTransform(
    scrollYProgress, 
    [0.50, 0.65], 
    [0, 1]
  )

  // Affinity Anchor 2 Reveal (Fades in after anchor 1 completes, around 0.68)
  const anchor2Opacity = useTransform(
    scrollYProgress, 
    [0.66, 0.78, 0.85, 0.95], 
    [0, 1, 1, 0]
  )
  const anchor2Y = useTransform(
    scrollYProgress, 
    [0.66, 0.78, 0.85, 0.95], 
    [15, 0, 0, -15]
  )
  const line2Length = useTransform(
    scrollYProgress, 
    [0.68, 0.80], 
    [0, 1]
  )

  // System Grid Separator lines height transition to HowItWorks (0.90 - 1.00)
  const separatorHeight = useTransform(scrollYProgress, [0.88, 1.0], [0, 160])

  const { movies, loading, error } = useTrendingMovies()

  // Use fallback movie data if loading or error
  const featuredMovie = !loading && !error && movies.length > 0 ? movies[0] : {
    title: "DUNE: PART TWO",
    posterPath: "https://image.tmdb.org/t/p/w500/1pdfbjO43Funw51M2zJ6K2HGLI8.jpg",
  }

  if (error || (!loading && movies.length === 0)) return null

  return (
    <section 
      ref={containerRef}
      className="relative w-full h-[200vh] bg-[#060608]"
    >
      <div className="sticky top-0 w-full h-screen overflow-hidden flex items-center justify-center">
        
        {/* Background Cinematic Spotlights */}
        <div className="absolute inset-0 pointer-events-none z-0">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[70vw] h-[70vw] bg-[#6B4EFF]/5 rounded-full blur-[140px]" />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[40vw] h-[40vw] bg-[#FFC107]/3 rounded-full blur-[120px]" />
        </div>

        {/* Spatial Composition Layout (Responsive adaptation flex-col on mobile, flex-row on desktop) */}
        <div className="relative w-full max-w-5xl mx-auto px-6 md:px-8 flex flex-col md:flex-row items-center justify-between z-10 gap-12 md:gap-0">
          
          {/* Left Side: Minimal Editorial Label */}
          <motion.div 
            className="w-full md:w-1/4 select-none text-center md:text-left"
            style={{ opacity: leftOpacity, y: leftY }}
          >
            <div className="flex flex-col gap-2">
              <span className="text-[10px] font-mono text-[#00F0FF] tracking-[0.25em] uppercase font-bold">
                Affinity Mapping
              </span>
              <h2 className="text-xl md:text-2xl font-light text-white leading-snug tracking-wide max-w-[220px] mx-auto md:mx-0">
                Why this choice is yours.
              </h2>
            </div>
          </motion.div>

          {/* Center: Movie Poster (Protagonist Hero Shot) */}
          <motion.div 
            className="relative w-full md:w-1/3 flex justify-center"
            style={{
              scale: posterScale,
              y: posterY,
              opacity: posterOpacity
            }}
          >
            {/* Soft Ambient Poster Backlight Glow */}
            <div className="absolute -inset-4 rounded-3xl bg-gradient-to-b from-white/5 to-transparent opacity-20 blur-xl animate-pulse pointer-events-none" />
            
            <div className="relative w-[240px] h-[350px] md:w-[280px] md:h-[410px] rounded-2xl overflow-hidden border border-white/10 bg-black shadow-[0_30px_70px_rgba(0,0,0,0.95)]">
              <img
                src={featuredMovie.posterPath}
                alt={featuredMovie.title}
                className="w-full h-full object-cover opacity-95 select-none pointer-events-none"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/95 via-black/20 to-transparent flex flex-col justify-end p-5 md:p-6">
                <span className="text-white font-bold text-lg md:text-xl leading-tight">
                  {featuredMovie.title}
                </span>
                <span className="text-[#00F0FF] font-semibold text-[10px] md:text-xs mt-1 tracking-wide">
                  98% Match
                </span>
              </div>
            </div>
          </motion.div>

          {/* Right Side: Two Affinity Anchor Blocks & Connecting Vector lines */}
          <div className="w-full md:w-1/3 flex flex-col gap-8 md:gap-12 relative text-center md:text-left px-4 md:px-0">
            
            {/* Animated Connection Guide Lines (Hidden on mobile for clean screen spacing) */}
            <div className="absolute left-[-160px] top-6 w-[160px] h-[150px] pointer-events-none select-none hidden md:block">
              <svg width="100%" height="100%" viewBox="0 0 160 150" fill="none">
                <motion.path
                  d="M 0 50 L 100 50 C 120 50, 140 10, 160 10"
                  stroke="rgba(255, 255, 255, 0.15)"
                  strokeWidth="1.5"
                  strokeDasharray="4 4"
                  style={{ pathLength: line1Length }}
                />
                <motion.path
                  d="M 0 130 L 100 130 C 120 130, 140 130, 160 130"
                  stroke="rgba(255, 255, 255, 0.15)"
                  strokeWidth="1.5"
                  strokeDasharray="4 4"
                  style={{ pathLength: line2Length }}
                />
              </svg>
            </div>

            {/* Anchor Block 1 */}
            <motion.div 
              className="flex flex-col gap-2 max-w-[280px] mx-auto md:mx-0"
              style={{ opacity: anchor1Opacity, y: anchor1Y }}
            >
              <span className="text-[9px] md:text-[10px] font-mono text-white/50 tracking-[0.2em] uppercase">
                [DIRECTED BY DENIS VILLENEUVE]
              </span>
              <p className="text-xs md:text-sm font-light text-zinc-400 leading-relaxed">
                From the director of your most-watched drama last winter.
              </p>
            </motion.div>

            {/* Anchor Block 2 */}
            <motion.div 
              className="flex flex-col gap-2 max-w-[280px] mx-auto md:mx-0"
              style={{ opacity: anchor2Opacity, y: anchor2Y }}
            >
              <span className="text-[9px] md:text-[10px] font-mono text-white/50 tracking-[0.2em] uppercase">
                [SLOW-BURN / ATMOSPHERIC]
              </span>
              <p className="text-xs md:text-sm font-light text-zinc-400 leading-relaxed">
                Matches the quiet, slow-burn tension of your favorite late-night picks.
              </p>
            </motion.div>

          </div>

        </div>

        {/* Structural Vertical Separators for HowItWorks Grid Handoff */}
        <div className="absolute bottom-0 left-0 w-full px-8 flex justify-between pointer-events-none select-none z-10">
          <motion.div 
            className="w-[1px] bg-gradient-to-t from-white/10 to-transparent" 
            style={{ height: separatorHeight }}
          />
          <motion.div 
            className="w-[1px] bg-gradient-to-t from-white/10 to-transparent" 
            style={{ height: separatorHeight }}
          />
          <motion.div 
            className="w-[1px] bg-gradient-to-t from-white/10 to-transparent" 
            style={{ height: separatorHeight }}
          />
        </div>

      </div>
    </section>
  )
}
