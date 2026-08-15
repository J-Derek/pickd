import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion } from "framer-motion";

const DISPLAY = "var(--font-display)";

export default function Scene5() {
  const ref = useRef<HTMLDivElement>(null);
  const prefersReduced = useReducedMotion();
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start 95%", "end end"] });

  const headlineOp = useTransform(scrollYProgress, [0, 0.22], [0, 1]);
  const headlineY  = useTransform(scrollYProgress, [0, 0.22], [40, 0]);
  const subOp      = useTransform(scrollYProgress, [0.12, 0.35], [0, 1]);
  const subY       = useTransform(scrollYProgress, [0.12, 0.35], [40, 0]);
  const badgesOp   = useTransform(scrollYProgress, [0.26, 0.50], [0, 1]);
  const badgesY    = useTransform(scrollYProgress, [0.26, 0.50], [40, 0]);
  const footerOp   = useTransform(scrollYProgress, [0.55, 0.85], [0, 1]);

  return (
    <section ref={ref} className="relative flex flex-col items-center text-center px-6 pt-28 pb-16 md:pt-32 md:pb-20" style={{ background: "var(--bg)" }}>
      <div className="w-px h-8 mb-8" style={{ background: "rgba(107,78,255,0.25)" }} />

      <motion.h2
        style={
          prefersReduced
            ? { opacity: headlineOp, fontFamily: DISPLAY, fontSize: "clamp(2.5rem, 8vw, 9rem)" }
            : { opacity: headlineOp, y: headlineY, fontFamily: DISPLAY, fontSize: "clamp(2.5rem, 8vw, 9rem)" }
        }
        className="text-white font-semibold leading-[0.95] tracking-tighter"
      >
        START
        <br />
        DISCOVERING.
      </motion.h2>

      <motion.p
        style={
          prefersReduced
            ? { opacity: subOp, fontSize: "clamp(1rem, 2vw, 1.5rem)", color: "rgba(255,255,255,0.55)", maxWidth: 480, lineHeight: 1.65 }
            : { opacity: subOp, y: subY, fontSize: "clamp(1rem, 2vw, 1.5rem)", color: "rgba(255,255,255,0.55)", maxWidth: 480, lineHeight: 1.65 }
        }
        className="mt-8 font-light mx-auto"
      >
        Pickd is distributed directly via GitHub Releases.
      </motion.p>

      <motion.div
        style={prefersReduced ? { opacity: badgesOp } : { opacity: badgesOp, y: badgesY }}
        className="flex flex-col sm:flex-row justify-center gap-4 mt-14"
      >
        <StoreBadge
          icon={
            <svg width="22" height="22" viewBox="0 0 24 24" fill="white">
              <path d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.166 6.839 9.489.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.603-3.369-1.34-3.369-1.34-.454-1.156-1.11-1.462-1.11-1.462-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.831.092-.646.35-1.086.636-1.336-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.379.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.161 22 16.416 22 12c0-5.523-4.477-10-10-10z" />
            </svg>
          }
          line1="Download on"
          line2="GitHub"
        />
      </motion.div>

      <footer
        className="mt-28 flex flex-col items-center gap-3 text-center max-w-xl mx-auto"
      >
        <div className="flex flex-col sm:flex-row items-center justify-center gap-2 text-xs leading-relaxed text-white/45">
          <span className="font-semibold text-white/70 tracking-widest text-[11px]">TMDB</span>
          <span className="hidden sm:inline text-white/20">•</span>
          <span>This product uses the TMDB API but is not endorsed or certified by TMDB.</span>
        </div>
        <p className="text-xs mt-1 text-white/25">
          © 2026 Pickd. All rights reserved.
        </p>
      </footer>
    </section>
  );
}

function StoreBadge({ icon, line1, line2 }: { icon: React.ReactNode; line1: string; line2: string }) {
  return (
    <a
      href="https://github.com/J-Derek/Pickd/releases/download/v1.0.0/app-release.apk"
      className="flex items-center gap-3 px-5 rounded-xl transition-opacity duration-200 hover:opacity-75"
      style={{
        height: 52,
        background: "rgba(255,255,255,0.06)",
        border: "1px solid rgba(255,255,255,0.1)",
      }}
    >
      {icon}
      <div className="text-left">
        <p className="text-xs" style={{ color: "rgba(255,255,255,0.45)" }}>{line1}</p>
        <p className="text-sm font-semibold text-white leading-tight">{line2}</p>
      </div>
    </a>
  );
}
