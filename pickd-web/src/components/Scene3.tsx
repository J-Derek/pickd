import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";

export default function Scene3() {
  const ref = useRef<HTMLDivElement>(null);
  const prefersReduced = useReducedMotion();

  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end end"],
  });

  // ── Line motion: slide in from opposite sides ──────────────────────────
  // LEFT line: "YOUR TASTE." — enters from left
  const leftX = useTransform(scrollYProgress, [0.0, 0.38], ["-40vw", "0vw"]);
  // RIGHT line: "YOUR RULES." — enters from right
  const rightX = useTransform(scrollYProgress, [0.0, 0.38], ["40vw", "0vw"]);

  // ── Shared opacity for both headline lines ─────────────────────────────
  // Fade in smoothly as they slide in, hold comfortably, then fade out at exit
  const headlineOp = useTransform(scrollYProgress, [0.0, 0.22, 0.75, 0.95], [0, 1, 1, 0]);

  // ── Sub-copy: fades in after lines meet ────────────────────────────────
  const subOp = useTransform(scrollYProgress, [0.32, 0.48, 0.75, 0.95], [0, 1, 1, 0]);
  const subY = useTransform(scrollYProgress, [0.32, 0.48], ["16px", "0px"]);

  // ── Ambient aura: blooms when lines meet ────────────────────────────────
  const auraOp = useTransform(scrollYProgress, [0.05, 0.38, 0.75, 0.95], [0, 0.22, 0.22, 0]);

  return (
    <div ref={ref} style={{ height: "220vh", position: "relative" }}>
      {/* Sticky viewport-locked canvas */}
      <div
        className="sticky top-0 overflow-hidden"
        style={{ height: "100dvh", background: "var(--bg)" }}
      >
        {/* Ambient aura — blooms when the two lines converge */}
        <motion.div
          className="absolute inset-0 pointer-events-none"
          style={{ opacity: auraOp }}
        >
          <div
            style={{
              position: "absolute",
              inset: 0,
              background:
                "radial-gradient(ellipse 70% 55% at 50% 50%, rgba(107,78,255,0.22) 0%, transparent 70%)",
            }}
          />
        </motion.div>

        {/* ── Main composition ─────────────────────────────────────────── */}
        <div
          className="absolute inset-0 flex flex-col items-center justify-center px-6 text-center"
          style={{ gap: "clamp(1rem, 3vh, 2rem)" }}
        >
          {/* Headline: two lines in separate motion containers */}
          <div style={{ overflow: "hidden", lineHeight: 1 }}>
            {/* "YOUR TASTE." — slides from LEFT */}
            <motion.h2
              style={{
                x: prefersReduced ? 0 : leftX,
                opacity: headlineOp,
                fontFamily: "var(--font-display)",
                fontSize: "clamp(2.8rem, 8.5vw, 8rem)",
                fontWeight: 700,
                letterSpacing: "-0.03em",
                lineHeight: 0.92,
                color: "#ffffff",
              }}
            >
              YOUR TASTE.
            </motion.h2>
          </div>

          <div style={{ overflow: "hidden", lineHeight: 1 }}>
            {/* "YOUR RULES." — slides from RIGHT */}
            <motion.h2
              style={{
                x: prefersReduced ? 0 : rightX,
                opacity: headlineOp,
                fontFamily: "var(--font-display)",
                fontSize: "clamp(2.8rem, 8.5vw, 8rem)",
                fontWeight: 700,
                letterSpacing: "-0.03em",
                lineHeight: 0.92,
                color: "#ffffff",
              }}
            >
              YOUR RULES.
            </motion.h2>
          </div>

          {/* Sub-copy: fades in after convergence */}
          <motion.p
            style={{
              opacity: subOp,
              y: prefersReduced ? 0 : subY,
              fontSize: "clamp(1rem, 2.2vw, 1.4rem)",
              color: "rgba(255,255,255,0.48)",
              maxWidth: 500,
              lineHeight: 1.65,
              fontWeight: 300,
            }}
          >
            No algorithm guessing what you might like.
            <br />
            You pick what matters.
          </motion.p>
        </div>
      </div>
    </div>
  );
}
