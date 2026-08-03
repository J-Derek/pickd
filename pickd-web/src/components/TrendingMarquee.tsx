import { useTrendingMovies } from "../hooks/useTrendingMovies"

import { useReducedMotion } from "../hooks/useReducedMotion"

import { motion, useScroll, useTransform } from "framer-motion"

import { useRef } from "react"

interface TrendingMarqueeProps {
  variant?: "standalone" | "hero"
}

export default function TrendingMarquee({
  variant = "standalone",
}: TrendingMarqueeProps) {
  const { movies, loading, error } = useTrendingMovies()

  const reduced = useReducedMotion()

  const containerRef = useRef<HTMLDivElement>(null)

  const { scrollYProgress } = useScroll({
    target: containerRef,

    offset: ["start start", "end start"],
  })

  const yParallax = useTransform(scrollYProgress, [0, 1], ["0%", "15%"])

  const opacityFade = useTransform(scrollYProgress, [0, 0.8], [1, 0])

  if (error || (!loading && movies.length === 0)) {
    return null
  }

  const isHero = variant === "hero"

  const marqueeItems = [...movies, ...movies, ...movies]

  const reversedItems = [...movies].reverse()

  const marqueeItemsReversed = [
    ...reversedItems,

    ...reversedItems,

    ...reversedItems,
  ]

  if (isHero) {
    return (
      <motion.div
        ref={containerRef}
        aria-hidden="true"
        className="absolute inset-0 z-0 overflow-hidden pointer-events-none select-none flex flex-col justify-center items-center"
        style={{
          y: reduced ? "0%" : yParallax,

          opacity: reduced ? 1 : opacityFade,
        }}
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
                transition={{
                  repeat: Infinity,

                  repeatType: "loop",

                  duration: 90,

                  ease: "linear",
                }}
              >
                {marqueeItems.map((movie, idx) => (
                  <div
                    key={`hero-row0-${movie.id}-${idx}`}
                    className="w-40 md:w-56 h-60 md:h-80 rounded-2xl overflow-hidden border border-white/5 bg-white/5 flex-shrink-0"
                  >
                    <img
                      src={movie.posterPath}
                      alt=""
                      className="w-full h-full object-cover"
                    />
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
                  <div
                    key={movie.id}
                    className="w-48 md:w-64 h-72 md:h-96 rounded-2xl overflow-hidden border border-white/10 bg-white/5 flex-shrink-0 shadow-2xl"
                  >
                    <img
                      src={movie.posterPath}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </div>
            ) : (
              <motion.div
                className="flex gap-6 pr-6"
                animate={{ x: ["0%", "-50%"] }}
                transition={{
                  repeat: Infinity,

                  repeatType: "loop",

                  duration: 60,

                  ease: "linear",
                }}
              >
                {marqueeItemsReversed.map((movie, idx) => (
                  <div
                    key={`hero-row1-${movie.id}-${idx}`}
                    className="w-48 md:w-64 h-72 md:h-96 rounded-2xl overflow-hidden border border-white/10 bg-white/5 flex-shrink-0 shadow-2xl"
                  >
                    <img
                      src={movie.posterPath}
                      alt=""
                      className="w-full h-full object-cover"
                    />
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
                  <div
                    key={movie.id}
                    className="w-56 md:w-72 h-80 md:h-[420px] rounded-3xl overflow-hidden border border-white/15 bg-white/5 flex-shrink-0 shadow-[0_30px_60px_rgba(0,0,0,0.6)]"
                  >
                    <img
                      src={movie.posterPath}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </div>
            ) : (
              <motion.div
                className="flex gap-8 pr-8"
                animate={{ x: ["-50%", "0%"] }}
                transition={{
                  repeat: Infinity,

                  repeatType: "loop",

                  duration: 45,

                  ease: "linear",
                }}
              >
                {marqueeItems.map((movie, idx) => (
                  <div
                    key={`hero-row2-${movie.id}-${idx}`}
                    className="w-56 md:w-72 h-80 md:h-[420px] rounded-3xl overflow-hidden border border-white/15 bg-white/5 flex-shrink-0 shadow-[0_30px_60px_rgba(0,0,0,0.6)]"
                  >
                    <img
                      src={movie.posterPath}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </motion.div>
            )}
          </div>
        </div>
      </motion.div>
    )
  }

  // Standard standalone marquee treatment

  return (
    <section
      className="relative z-20 py-8 overflow-hidden bg-ink/60 border-y border-white/5"
      aria-label="Trending movies on Pickd"
    >
      <div className="max-w-7xl mx-auto px-6 mb-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-[#00F0FF] animate-pulse" />
          <span
            className="text-xs font-semibold uppercase tracking-widest text-white/50"
            style={{ fontFamily: "var(--font-body)" }}
          >
            Trending Today
          </span>
        </div>
        <span
          className="text-[10px] text-white/30 tracking-wide"
          style={{ fontFamily: "var(--font-body)" }}
        >
          Powered by TMDB
        </span>
      </div>

      {/* Gradient side fade masks */}
      <div className="relative w-full overflow-hidden">
        <div className="pointer-events-none absolute inset-y-0 left-0 w-16 md:w-32 z-10 bg-gradient-to-r from-ink to-transparent" />
        <div className="pointer-events-none absolute inset-y-0 right-0 w-16 md:w-32 z-10 bg-gradient-to-l from-ink to-transparent" />

        {loading ? (
          <div className="flex gap-4 px-6 overflow-hidden">
            {Array.from({ length: 8 }).map((_, i) => (
              <div
                key={i}
                className="w-36 md:w-44 h-52 md:h-64 rounded-xl bg-white/5 animate-pulse flex-shrink-0 border border-white/10"
              />
            ))}
          </div>
        ) : reduced ? (
          <div
            className="flex gap-4 px-6 overflow-x-auto pb-2"
            style={{ scrollbarWidth: "none" }}
          >
            {movies.map((movie) => (
              <div
                key={movie.id}
                className="relative flex-shrink-0 w-36 md:w-44 h-52 md:h-64 rounded-xl overflow-hidden border border-white/10 group bg-white/5"
              >
                <img
                  src={movie.posterPath}
                  alt={movie.title}
                  loading="lazy"
                  className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 p-3 flex flex-col justify-end">
                  <p className="text-xs font-bold text-white line-clamp-1">
                    {movie.title}
                  </p>
                  <span className="text-[10px] text-[#00F0FF]">
                    ★ {movie.voteAverage}
                  </span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="flex w-max">
            <motion.div
              className="flex gap-4 pr-4"
              animate={{ x: ["0%", "-50%"] }}
              transition={{
                x: {
                  repeat: Infinity,

                  repeatType: "loop",

                  duration: 35,

                  ease: "linear",
                },
              }}
            >
              {marqueeItems.map((movie, idx) => (
                <div
                  key={`${movie.id}-${idx}`}
                  className="relative flex-shrink-0 w-36 md:w-44 h-52 md:h-64 rounded-xl overflow-hidden border border-white/10 group bg-white/5 shadow-lg"
                >
                  <img
                    src={movie.posterPath}
                    alt={movie.title}
                    loading="lazy"
                    className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 p-3 flex flex-col justify-end">
                    <p className="text-xs font-bold text-white line-clamp-1">
                      {movie.title}
                    </p>
                    <span className="text-[10px] text-[#00F0FF]">
                      ★ {movie.voteAverage}
                    </span>
                  </div>
                </div>
              ))}
            </motion.div>
          </div>
        )}
      </div>
    </section>
  )
}
