import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";
import { useTrendingMovies, type MoviePoster } from "@/hooks/useTrendingMovies";
import { useIsMobile } from "@/hooks/useIsMobile";

// CSS marquee keyframes injected once — pure GPU transform, no JS per frame
const KEYFRAMES = `
@keyframes mq-l { from { transform: translateX(0) } to { transform: translateX(-50%) } }
@keyframes mq-r { from { transform: translateX(-50%) } to { transform: translateX(0) } }
`;

const NARRATIVE = [
  { text: "Another movie night.",   t: [0.00, 0.12, 0.15] },
  { text: "Netflix.",                t: [0.15, 0.18, 0.25, 0.28] },
  { text: "Prime Video.",            t: [0.28, 0.31, 0.38, 0.41] },
  { text: "Disney+.",                t: [0.41, 0.44, 0.51, 0.54] },
  { text: "Max.",                    t: [0.54, 0.57, 0.64, 0.67] },
  { text: "Thousands of movies.",    t: [0.67, 0.70, 0.77, 0.80] },
  { text: "Still nothing to watch.", t: [0.80, 0.83, 0.90, 0.93] },
  { text: "Sound familiar?",         t: [0.93, 0.96, 1.00, 1.00] },
];

const D_ROWS = [
  { dur: 28, dir: "l" },
  { dur: 38, dir: "r" },
  { dur: 32, dir: "l" },
  { dur: 30, dir: "r" },
  { dur: 35, dir: "l" },
] as const;

const M_ROWS = [
  { dur: 24, dir: "l" },
  { dur: 32, dir: "r" },
  { dur: 28, dir: "l" },
] as const;

import { TMDBPoster } from "@/components/ui/TMDBPoster";

// ── MarqueeRow — pure CSS animation, will-change: transform ──────────────
function MarqueeRow({ posters, dur, dir }: { posters: MoviePoster[]; dur: number; dir: "l" | "r" }) {
  // 8 posters duplicated = 16 total for seamless loop; translateX(-50%) = -1 set width
  const items = [...posters.slice(0, 8), ...posters.slice(0, 8)];
  return (
    <div style={{ overflow: "hidden", flexShrink: 0 }}>
      <div
        style={{
          display: "flex",
          gap: 12,
          width: "max-content",
          animation: `mq-${dir} ${dur}s linear infinite`,
          willChange: "transform",
        }}
      >
        {items.map((m, i) => (
          <div
            key={`${m.id}-${i}`}
            style={{
              width: "clamp(72px, 9vw, 112px)",
              height: "clamp(108px, 13.5vw, 168px)",
              borderRadius: 12,
              overflow: "hidden",
              flexShrink: 0,
            }}
          >
            <TMDBPoster
              movieId={m.id}
              alt=""
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
              loading="lazy"
              draggable={false}
            />
          </div>
        ))}
      </div>
    </div>
  );
}

// ── PosterGrid — renders all rows; optionally pre-blurred via static CSS ──
function PosterGrid({
  rows,
  config,
  blurred,
}: {
  rows: MoviePoster[][];
  config: readonly { dur: number; dir: "l" | "r" }[];
  blurred?: boolean;
}) {
  return (
    <div
      style={{
        position: "absolute",
        inset: 0,
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-around",
        paddingBlock: "2rem",
        gap: 12,
        // Static CSS filter — not animated, zero per-frame cost
        filter: blurred ? "blur(24px)" : "none",
        transform: "rotate(-12deg) scale(1.2) translateZ(0)",
      }}
    >
      {config.map(({ dur, dir }, ri) => (
        <MarqueeRow key={ri} posters={rows[ri % rows.length] ?? rows[0]} dur={dur} dir={dir} />
      ))}
    </div>
  );
}

// ── Desktop — scroll-scrubbed narrative + two-layer focus arc ─────────────
function ProblemStatementDesktop() {
  const ref = useRef<HTMLDivElement>(null);
  const prefersReduced = useReducedMotion();
  const { rows } = useTrendingMovies();

  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end end"] });

  // Poster visibility envelope
  const posterOp = useTransform(scrollYProgress, [0, 0.90, 1.0], [0.7, 0.7, 0]);

  // Focus arc via opacity crossfade — no live blur computation
  // sharpOp peaks in the middle; blurOp peaks at start and end
  const sharpOp = useTransform(scrollYProgress, [0, 0.20, 0.40, 0.70, 0.88, 1.0], [0.4, 0.7, 1, 1, 0.6, 0]);
  const blurOp  = useTransform(scrollYProgress, [0, 0.20, 0.40, 0.70, 0.88, 1.0], [0.8, 0.3, 0, 0, 0.5, 1]);

  // Narrative line opacities — individual hooks, never in a loop
  const op0 = useTransform(scrollYProgress, [0.00, 0.12, 0.15], [1, 1, 0]);
  const op1 = useTransform(scrollYProgress, NARRATIVE[1].t, [0, 1, 1, 0]);
  const op2 = useTransform(scrollYProgress, NARRATIVE[2].t, [0, 1, 1, 0]);
  const op3 = useTransform(scrollYProgress, NARRATIVE[3].t, [0, 1, 1, 0]);
  const op4 = useTransform(scrollYProgress, NARRATIVE[4].t, [0, 1, 1, 0]);
  const op5 = useTransform(scrollYProgress, NARRATIVE[5].t, [0, 1, 1, 0]);
  const op6 = useTransform(scrollYProgress, NARRATIVE[6].t, [0, 1, 1, 0]);
  const op7 = useTransform(scrollYProgress, NARRATIVE[7].t, [0, 1, 1, 0]);
  const lineOps = [op0, op1, op2, op3, op4, op5, op6, op7];

  return (
    <section
      ref={ref}
      id="how-it-works"
      style={{ position: "relative", height: "300vh", background: "var(--bg)" }}
    >
      <style>{KEYFRAMES}</style>

      <div
        style={{
          position: "sticky",
          top: 0,
          height: "100dvh",
          overflow: "hidden",
          isolation: "isolate",
        }}
      >
        {/* ── Poster ecosystem: two GPU layers crossfaded, never blurred live ── */}
        <motion.div style={{ opacity: posterOp, position: "absolute", inset: 0 }}>
          {/* Blurred layer — static 14px filter, opacity only changes */}
          {!prefersReduced && (
            <motion.div style={{ opacity: blurOp, position: "absolute", inset: 0, willChange: "opacity" }}>
              <PosterGrid rows={rows} config={D_ROWS} blurred />
            </motion.div>
          )}
          {/* Sharp layer */}
          <motion.div style={{ opacity: sharpOp, position: "absolute", inset: 0, willChange: "opacity" }}>
            <PosterGrid rows={rows} config={D_ROWS} />
          </motion.div>
        </motion.div>

        {/* ── Ambient glow — baked static gradient, no mix-blend-mode ── */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            pointerEvents: "none",
            background:
              "radial-gradient(ellipse 60% 55% at 32% 44%, rgba(107,78,255,0.20), transparent 68%), " +
              "radial-gradient(ellipse 50% 48% at 72% 62%, rgba(0,240,255,0.11), transparent 66%)",
          }}
        />

        {/* ── Vignette edge masks ── */}
        <div style={{ position: "absolute", inset: 0, pointerEvents: "none", background: "radial-gradient(ellipse 72% 72% at 50% 50%, transparent 16%, rgba(10,10,15,0.85) 100%)" }} />
        <div style={{ position: "absolute", inset: 0, pointerEvents: "none", background: "linear-gradient(to bottom, rgba(10,10,15,0.65) 0%, transparent 20%, transparent 80%, rgba(10,10,15,0.92) 100%)" }} />

        {/* ── Narrative crossfade ── */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            zIndex: 30,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            pointerEvents: "none",
          }}
        >
          <div style={{ position: "relative", width: "100%", maxWidth: 900, padding: "0 1.5rem", height: 200 }}>
            {NARRATIVE.map(({ text }, i) => (
              <motion.h2
                key={text}
                style={{
                  opacity: lineOps[i],
                  fontFamily: "var(--font-display)",
                  fontSize: "clamp(2rem, 6vw, 7rem)",
                  position: "absolute",
                  top: "50%",
                  left: 0,
                  right: 0,
                  transform: "translateY(-50%)",
                  willChange: "opacity",
                }}
                className="font-semibold text-white leading-[0.95] tracking-tighter text-center"
              >
                {text}
              </motion.h2>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

// ── Mobile — viewport-enter fades, not scroll-scrubbed ───────────────────
const FU = { hidden: { opacity: 0, y: 22 }, visible: { opacity: 1, y: 0 } };
const T  = { duration: 0.6, ease: [0.22, 1, 0.36, 1] as const };
const VP = { once: true, amount: 0.5 };

function ProblemStatementMobile() {
  const { rows } = useTrendingMovies();

  return (
    <section id="how-it-works" style={{ background: "var(--bg)", overflow: "hidden" }}>
      <style>{KEYFRAMES}</style>

      {/* Shallow poster strip — 3 rows, reduced tilt, no blur layers */}
      <div style={{ position: "relative", height: "38svh", overflow: "hidden" }}>
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-around",
            gap: 8,
            transform: "rotate(-6deg) scale(1.1) translateZ(0)",
            opacity: 0.5,
          }}
        >
          {M_ROWS.map(({ dur, dir }, ri) => (
            <MarqueeRow key={ri} posters={rows[ri % rows.length] ?? rows[0]} dur={dur} dir={dir} />
          ))}
        </div>
        {/* Fade strip into background */}
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(to bottom, var(--bg) 0%, transparent 28%, transparent 72%, var(--bg) 100%)" }} />
      </div>

      {/* Sequential viewport-enter narrative — no scroll percentage binding */}
      <div
        style={{
          padding: "2.5rem 1.5rem 5rem",
          display: "flex",
          flexDirection: "column",
          gap: "3rem",
          maxWidth: 380,
          margin: "0 auto",
        }}
      >
        {NARRATIVE.map(({ text }) => (
          <motion.h2
            key={text}
            initial="hidden"
            whileInView="visible"
            viewport={VP}
            variants={FU}
            transition={T}
            style={{
              fontFamily: "var(--font-display)",
              fontSize: "clamp(1.7rem, 8vw, 2.8rem)",
            }}
            className="font-semibold leading-[0.95] tracking-tighter text-center text-white"
          >
            {text}
          </motion.h2>
        ))}
      </div>
    </section>
  );
}

// ── Export ────────────────────────────────────────────────────────────────
export default function ProblemStatement() {
  const mobile = useIsMobile();
  return mobile ? <ProblemStatementMobile /> : <ProblemStatementDesktop />;
}
