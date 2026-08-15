import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";
import TrendingMarquee from "./TrendingMarquee";

const VARIANTS = {
  container: {
    hidden: {},
    visible: { transition: { staggerChildren: 0.15 } },
  },
  item: {
    hidden: { opacity: 0, y: 24, filter: "blur(8px)" },
    visible: {
      opacity: 1,
      y: 0,
      filter: "blur(0px)",
      transition: { type: "spring", bounce: 0, damping: 22, duration: 1.0 },
    },
  },
  badge: {
    hidden: { opacity: 0, y: 16, filter: "blur(4px)" },
    visible: {
      opacity: 1,
      y: 0,
      filter: "blur(0px)",
      transition: { type: "spring", bounce: 0, damping: 20, duration: 0.8 },
    },
  },
  cta: {
    hidden: { opacity: 0, y: 16, filter: "blur(4px)" },
    visible: {
      opacity: 1,
      y: 0,
      filter: "blur(0px)",
      transition: { type: "spring", bounce: 0, damping: 25, duration: 1.2 },
    },
  },
};

export default function Hero() {
  const containerRef = useRef<HTMLDivElement>(null);
  const prefersReduced = useReducedMotion();

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"],
  });

  // Content parallax + fade on scroll — hold full opacity longer so scrolling feels comfortable
  const contentY  = useTransform(scrollYProgress, [0, 1], ["0%", "20%"]);
  const contentOp = useTransform(scrollYProgress, [0, 0.45, 0.95], [1, 1, 0]);

  return (
    <div
      ref={containerRef}
      className="relative min-h-screen pt-20 pb-10 overflow-hidden flex items-center justify-center"
      style={{ background: "var(--bg)" }}
    >
      {/* Background marquee */}
      <TrendingMarquee variant="hero" scrollProgress={scrollYProgress} />

      {/* Foreground content */}
      <motion.div
        style={prefersReduced ? {} : { y: contentY, opacity: contentOp }}
        variants={VARIANTS.container}
        initial="hidden"
        animate="visible"
        className="relative z-10 max-w-5xl mx-auto text-center px-6"
      >
        {/* Headline */}
        <motion.h1
          variants={VARIANTS.item}
          className="font-semibold text-white leading-[0.95] tracking-tighter mb-4 md:mb-6"
          style={{
            fontFamily: "var(--font-display)",
            fontSize: "clamp(2.75rem, 5.5vw, 6rem)",
            textShadow: "0 20px 40px rgba(0,0,0,0.5)",
          }}
        >
          Find films that
          <br />
          fit your mood.
        </motion.h1>

        {/* Subhead */}
        <motion.p
          variants={VARIANTS.item}
          className="text-base md:text-lg lg:text-xl font-medium leading-relaxed mb-8 md:mb-10 mx-auto"
          style={{ color: "rgba(255,255,255,0.5)", maxWidth: 520 }}
        >
          Pickd learns what you love by watching how you swipe.
          No ratings. No algorithms. Just your taste.
        </motion.p>

        {/* CTA row */}
        <motion.div
          variants={VARIANTS.cta}
          className="flex flex-col sm:flex-row items-center justify-center gap-3.5"
        >
          <a
            href="https://github.com/J-Derek/Pickd/releases/download/v1.0.0/app-release.apk"
            className="hero-primary-btn flex items-center gap-2.5 px-8 rounded-full font-semibold text-sm text-white"
            style={{
              height: 50,
              letterSpacing: "0.06em",
              textDecoration: "none",
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            <span>Download APK</span>
          </a>

          <a
            href="#how-it-works"
            onClick={(e) => {
              e.preventDefault();
              document.getElementById("how-it-works")?.scrollIntoView({ behavior: "smooth" });
            }}
            className="flex items-center gap-2 px-8 rounded-full font-medium text-sm border border-white/10 text-white/60 hover:text-white hover:border-white/30 transition-colors duration-200"
            style={{ height: 50 }}
          >
            See how it works
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="9 18 15 12 9 6" />
            </svg>
          </a>
        </motion.div>
      </motion.div>

      {/* Scroll nudge */}
      <motion.div
        style={prefersReduced ? {} : { opacity: contentOp }}
        className="absolute bottom-4 md:bottom-6 left-1/2 -translate-x-1/2 flex flex-col items-center gap-1.5"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2, duration: 1 }}
      >
        <motion.div
          className="w-px bg-white/20"
          style={{ height: 32 }}
          animate={prefersReduced ? {} : { scaleY: [0, 1, 0], originY: 0 }}
          transition={{ duration: 1.5, repeat: Infinity, ease: "linear" }}
        />
        <span className="text-[11px] tracking-widest uppercase" style={{ color: "rgba(255,255,255,0.2)" }}>
          scroll
        </span>
      </motion.div>
    </div>
  );
}
