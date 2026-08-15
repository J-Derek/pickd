import { motion } from "framer-motion";

const DISPLAY = "var(--font-display)";

export default function NotFound() {
  const handleHome = () => {
    window.location.href = "/";
  };

  return (
    <div
      className="relative min-h-screen flex flex-col items-center justify-center px-6 text-center select-none"
      style={{ background: "var(--bg)", color: "#fff", overflow: "hidden" }}
    >
      {/* Ambient background aura */}
      <div className="pointer-events-none absolute inset-0">
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full blur-3xl opacity-20"
          style={{
            width: "clamp(300px, 50vw, 600px)",
            height: "clamp(300px, 50vw, 600px)",
            background: "radial-gradient(circle, #6b4eff 0%, rgba(0,240,255,0.4) 60%, transparent 80%)",
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-transparent to-black/80" />
      </div>

      <div className="relative z-10 max-w-lg flex flex-col items-center">
        {/* Eyebrow */}
        <motion.p
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-xs font-mono tracking-[0.25em] uppercase"
          style={{ color: "rgba(255,255,255,0.45)" }}
        >
          Error 404 // Reel Missing
        </motion.p>

        {/* 404 Large Display Headline */}
        <motion.h1
          initial={{ opacity: 0, scale: 0.94 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="mt-4 font-bold text-white leading-none tracking-tighter"
          style={{
            fontFamily: DISPLAY,
            fontSize: "clamp(4.5rem, 15vw, 10rem)",
            textShadow: "0 0 80px rgba(107,78,255,0.35)",
          }}
        >
          LOST SCENE.
        </motion.h1>

        {/* Description */}
        <motion.p
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="mt-6 font-light leading-relaxed text-sm sm:text-base max-w-sm"
          style={{ color: "rgba(255,255,255,0.55)" }}
        >
          The frames you're looking for aren't in this cut. Head back to the main feature.
        </motion.p>

        {/* Back to Home CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="mt-10"
        >
          <button
            onClick={handleHome}
            className="inline-flex items-center justify-center gap-2 px-8 py-3.5 rounded-full text-sm font-semibold tracking-wider transition-all duration-200 cursor-pointer"
            style={{
              background: "#ffffff",
              color: "#0a0a0f",
              boxShadow: "0 0 30px rgba(255,255,255,0.15)",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = "scale(1.04)";
              e.currentTarget.style.boxShadow = "0 0 40px rgba(255,255,255,0.3)";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = "scale(1)";
              e.currentTarget.style.boxShadow = "0 0 30px rgba(255,255,255,0.15)";
            }}
          >
            RETURN TO HOME
          </button>
        </motion.div>
      </div>

      {/* Subtle footer credit */}
      <div className="absolute bottom-8 text-xs font-mono" style={{ color: "rgba(255,255,255,0.2)" }}>
        PICKD // CINEMA FIRST
      </div>
    </div>
  );
}
