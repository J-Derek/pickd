import re

with open("C:/DevTools/projects/pickd/pickd-web/src/components/TrendingMarquee.tsx", "r", encoding="utf-8") as f:
    content = f.read()

# I need to add useScroll and useTransform if they are not already imported, and useRef
# Currently it has:
# import { useTrendingMovies } from "../hooks/useTrendingMovies"
# import { useReducedMotion } from "../hooks/useReducedMotion"
# import { motion } from "framer-motion"
if "useScroll" not in content:
    content = content.replace('import { motion } from "framer-motion"', 'import { motion, useScroll, useTransform } from "framer-motion"\nimport { useRef } from "react"')

# Add the hooks to the component
hooks = """  const { movies, loading, error } = useTrendingMovies()
  const reduced = useReducedMotion()
  const containerRef = useRef<HTMLDivElement>(null)
  
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"],
  })

  const yParallax = useTransform(scrollYProgress, [0, 1], ["0%", "15%"])
  const opacityFade = useTransform(scrollYProgress, [0, 0.8], [1, 0])"""

content = re.sub(r'  const { movies, loading, error } = useTrendingMovies\(\)\n  const reduced = useReducedMotion\(\)', hooks, content)

# Change marqueeItems arrays for enough length
arrays = """  const marqueeItems = [...movies, ...movies, ...movies]
  const reversedItems = [...movies].reverse()
  const marqueeItemsReversed = [...reversedItems, ...reversedItems, ...reversedItems]"""

content = re.sub(r'  const marqueeItems = \[\.\.\.movies, \.\.\.movies\]\n  const reversedItems = \[\.\.\.movies\]\.reverse\(\)\n  const marqueeItemsReversed = \[\.\.\.reversedItems, \.\.\.reversedItems\]', arrays, content)

# Replace the isHero return block
hero_block = """  if (isHero) {
    return (
      <motion.div
        ref={containerRef}
        aria-hidden="true"
        className="absolute inset-0 z-0 overflow-hidden pointer-events-none select-none flex flex-col justify-center items-center"
        style={{ y: reduced ? "0%" : yParallax, opacity: reduced ? 1 : opacityFade }}
      >
        {/* Environmental Lighting */}
        <div className="absolute top-[-20%] left-[-10%] w-[60%] h-[60%] rounded-full bg-[#6B4EFF] blur-[140px] opacity-30 mix-blend-screen" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-[#00F0FF] blur-[140px] opacity-20 mix-blend-screen" />
        <div className="absolute top-[20%] left-[50%] -translate-x-1/2 w-[40%] h-[40%] rounded-full bg-[#FFC107] blur-[160px] opacity-[0.08] mix-blend-screen" />

        {/* Depth Masks (Vignette & Fade) */}
        <div className="absolute inset-0 z-20 bg-[radial-gradient(ellipse_at_center,transparent_0%,var(--ink)_100%)] pointer-events-none" />
        <div className="absolute inset-0 z-20 bg-gradient-to-b from-ink via-transparent to-ink pointer-events-none" />
        <div className="absolute inset-0 z-20 bg-ink/30 pointer-events-none backdrop-blur-[2px]" />

        {/* Marquee Grid (Rotated for cinematic floating effect) */}
        <div className="relative w-[150vw] h-[150vh] flex flex-col justify-center gap-6 md:gap-10 transform -rotate-[8deg] scale-110 opacity-70">
          
          {/* Row 0: Far Background (Small, slow, blurred, dark) */}
          <div className="flex w-max relative z-0 opacity-40 blur-[4px] scale-90">
            {reduced ? null : (
              <motion.div
                className="flex gap-6 pr-6"
                animate={{ x: ["-50%", "0%"] }}
                transition={{ repeat: Infinity, repeatType: "loop", duration: 90, ease: "linear" }}
              >
                {marqueeItems.map((movie, idx) => (
                  <div key={`hero-row0-${movie.id}-${idx}`} className="w-40 md:w-56 h-60 md:h-80 rounded-2xl overflow-hidden border border-white/5 bg-white/5 flex-shrink-0">
                    <img src={movie.posterPath} alt="" className="w-full h-full object-cover" />
                  </div>
                ))}
              </motion.div>
            )}
          </div>

          {/* Row 1: Mid Background (Medium speed, slight blur) */}
          <div className="flex w-max relative z-10 opacity-70 blur-[1px]">
            {reduced ? (
              <div className="flex gap-6 px-6">
                {movies.slice(0, 10).map((movie) => (
                  <div key={movie.id} className="w-48 md:w-64 h-72 md:h-96 rounded-2xl overflow-hidden border border-white/10 bg-white/5 flex-shrink-0 shadow-2xl">
                    <img src={movie.posterPath} alt="" className="w-full h-full object-cover" />
                  </div>
                ))}
              </div>
            ) : (
              <motion.div
                className="flex gap-6 pr-6"
                animate={{ x: ["0%", "-50%"] }}
                transition={{ repeat: Infinity, repeatType: "loop", duration: 60, ease: "linear" }}
              >
                {marqueeItemsReversed.map((movie, idx) => (
                  <div key={`hero-row1-${movie.id}-${idx}`} className="w-48 md:w-64 h-72 md:h-96 rounded-2xl overflow-hidden border border-white/10 bg-white/5 flex-shrink-0 shadow-2xl">
                    <img src={movie.posterPath} alt="" className="w-full h-full object-cover" />
                  </div>
                ))}
              </motion.div>
            )}
          </div>

          {/* Row 2: Foreground (Fast, sharp, bright, large) */}
          <div className="flex w-max relative z-20 opacity-90">
            {reduced ? (
              <div className="flex gap-8 px-6">
                {movies.slice(10, 20).map((movie) => (
                  <div key={movie.id} className="w-56 md:w-72 h-80 md:h-[420px] rounded-3xl overflow-hidden border border-white/15 bg-white/5 flex-shrink-0 shadow-[0_30px_60px_rgba(0,0,0,0.6)]">
                    <img src={movie.posterPath} alt="" className="w-full h-full object-cover" />
                  </div>
                ))}
              </div>
            ) : (
              <motion.div
                className="flex gap-8 pr-8"
                animate={{ x: ["-50%", "0%"] }}
                transition={{ repeat: Infinity, repeatType: "loop", duration: 45, ease: "linear" }}
              >
                {marqueeItems.map((movie, idx) => (
                  <div key={`hero-row2-${movie.id}-${idx}`} className="w-56 md:w-72 h-80 md:h-[420px] rounded-3xl overflow-hidden border border-white/15 bg-white/5 flex-shrink-0 shadow-[0_30px_60px_rgba(0,0,0,0.6)]">
                    <img src={movie.posterPath} alt="" className="w-full h-full object-cover" />
                  </div>
                ))}
              </motion.div>
            )}
          </div>

        </div>
      </motion.div>
    )
  }"""

content = re.sub(r'  if \(isHero\) \{.*?\n  \}\n', hero_block + '\n', content, flags=re.DOTALL)

with open("C:/DevTools/projects/pickd/pickd-web/src/components/TrendingMarquee.tsx", "w", encoding="utf-8") as f:
    f.write(content)
print("Updated TrendingMarquee")
