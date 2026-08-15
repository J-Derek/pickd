import { useRef, useEffect } from "react";
import { motion, useScroll, useTransform, useReducedMotion, type MotionValue } from "framer-motion";
import { useTrendingMovies, type MoviePoster } from "@/hooks/useTrendingMovies";

// Row config: direction, speed, depth
const HERO_ROWS = [
  { from: "-50%", to: "0%",   duration: 180, depth: "far",  w: 208, h: 312, shadow: "shadow-lg"                              },
  { from: "0%",   to: "-50%", duration: 120, depth: "mid",  w: 247, h: 370, shadow: "shadow-xl"                             },
  { from: "-50%", to: "0%",   duration: 90,  depth: "fore", w: 286, h: 429, shadow: "shadow-[0_30px_60px_rgba(0,0,0,0.6)]" },
] as const;

// CSS keyframe marquee approach (compositor-friendly)
const KEYFRAMES = `
@keyframes marquee-fwd  { from { transform: translateX(0%)   } to { transform: translateX(-50%) } }
@keyframes marquee-back { from { transform: translateX(-50%) } to { transform: translateX(0%)   } }
`;

import { TMDBPoster } from "@/components/ui/TMDBPoster";

function PosterCard({ movie, w, h, shadow }: { movie: MoviePoster; w: number; h: number; shadow: string }) {
  return (
    <div
      className={`relative flex-shrink-0 overflow-hidden rounded-2xl ${shadow}`}
      style={{ width: w, height: h }}
    >
      <TMDBPoster
        movieId={movie.id}
        alt=""
        className="w-full h-full object-cover"
        draggable={false}
      />
    </div>
  );
}

interface TrendingMarqueeProps {
  variant?: "hero";
  scrollProgress?: MotionValue<number>;
}

export default function TrendingMarquee({ variant = "hero", scrollProgress }: TrendingMarqueeProps) {
  const prefersReduced = useReducedMotion();
  const { rows } = useTrendingMovies();
  const styleRef = useRef<HTMLStyleElement | null>(null);

  useEffect(() => {
    if (styleRef.current) return;
    const el = document.createElement("style");
    el.textContent = KEYFRAMES;
    document.head.appendChild(el);
    styleRef.current = el;
    return () => el.remove();
  }, []);

  // Scroll-driven transforms (parallax + fade)
  const wrapperY  = scrollProgress ? useTransform(scrollProgress, [0, 1], ["0%", "15%"]) : undefined;
  const wrapperOp = scrollProgress ? useTransform(scrollProgress, [0, 0.8], [1, 0])      : undefined;

  return (
    <motion.div
      className="absolute inset-0 z-0 overflow-hidden"
      style={{ y: wrapperY, opacity: wrapperOp }}
    >
      {/* Environmental lighting blobs */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute rounded-full blur-3xl" style={{ width: 600, height: 600, top: "10%", left: "20%", background: "rgba(107,78,255,0.12)", transform: "translateZ(0)" }} />
        <div className="absolute rounded-full blur-3xl" style={{ width: 500, height: 500, top: "40%", right: "15%", background: "rgba(0,240,255,0.08)", transform: "translateZ(0)" }} />
        <div className="absolute rounded-full blur-3xl" style={{ width: 400, height: 400, bottom: "5%",  left: "40%", background: "rgba(255,193,7,0.07)",  transform: "translateZ(0)" }} />
      </div>

      {/* Poster grid — tilted + blurred so text stays readable */}
      <div className="absolute inset-0 -rotate-[8deg] scale-110" style={{ transformOrigin: "center center", filter: "blur(7px)" }}>
        <div className="h-full flex flex-col justify-around gap-4 md:gap-6 py-8">
          {HERO_ROWS.map((row, ri) => {
            const rowPosters: MoviePoster[] = rows[ri % rows.length] ?? rows[0];
            // Duplicate for seamless loop
            const doubled = [...rowPosters, ...rowPosters];
            const anim = ri === 1 ? "marquee-back" : "marquee-fwd";
            return (
              <div key={ri} className="overflow-hidden">
                <div
                  className="flex gap-4 md:gap-6"
                  style={
                    prefersReduced
                      ? {}
                      : {
                          animation: `${anim} ${row.duration}s linear infinite`,
                          willChange: "transform",
                        }
                  }
                >
                  {doubled.map((m, ci) => (
                    <PosterCard key={`${m.id}-${ci}`} movie={m} w={row.w} h={row.h} shadow={row.shadow} />
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Depth masks — vignette */}
      <div className="absolute inset-0 pointer-events-none" style={{ background: "radial-gradient(ellipse 80% 80% at 50% 50%, transparent 30%, rgba(10,10,15,0.85) 100%)" }} />
      <div className="absolute inset-0 pointer-events-none" style={{ background: "linear-gradient(to bottom, rgba(10,10,15,0.6) 0%, transparent 20%, transparent 80%, rgba(10,10,15,0.9) 100%)" }} />
      <div className="absolute inset-0 pointer-events-none" style={{ background: "linear-gradient(to right, rgba(10,10,15,0.5) 0%, transparent 15%, transparent 85%, rgba(10,10,15,0.5) 100%)" }} />
    </motion.div>
  );
}
