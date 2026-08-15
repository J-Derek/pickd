import { useRef } from "react";
import { motion, useScroll, useTransform, useReducedMotion, type MotionValue } from "framer-motion";
import { useIsMobile } from "@/hooks/useIsMobile";

import { TMDBPoster } from "@/components/ui/TMDBPoster";
import moodSelectionImg from "../../screenshots/moodselection.jpeg";
import pickThreeImg from "../../screenshots/pickthreelike.jpeg";
import overviewImg from "../../screenshots/overview.jpeg";

// ─── Data ──────────────────────────────────────────────────────────────────
const TASTE_ESTABLISHED_MOVIES = [
  { title: "Inception", year: "2010", movieId: 27205 },
  { title: "Spirited Away", year: "2001", movieId: 129 },
  { title: "The Dark Knight", year: "2008", movieId: 155 },
  { title: "Dune", year: "2021", movieId: 438631 },
  { title: "Everything Everywhere All at Once", year: "2022", movieId: 545611 },
  { title: "Spider-Man: Into the Spider-Verse", year: "2018", movieId: 324857 },
];

const DECK_MOVIES = [
  { title: "Inception", year: "2010", movieId: 27205 },
  { title: "Interstellar", year: "2014", movieId: 157336 },
  { title: "Dune", year: "2021", movieId: 438631 },
  { title: "Blade Runner 2049", year: "2017", movieId: 335984 },
  { title: "Arrival", year: "2016", movieId: 329865 },
  { title: "Ex Machina", year: "2014", movieId: 264660 },
  { title: "Mad Max: Fury Road", year: "2015", movieId: 76341 },
  { title: "The Dark Knight", year: "2008", movieId: 155 },
];

const WATCHLIST_MOVIES = [
  {
    title: "Parasite",
    year: "2019",
    rating: "8.5",
    movieId: 496243,
    provider: "Prime Video",
  },
  {
    title: "Everything Everywhere All at Once",
    year: "2022",
    rating: "7.8",
    movieId: 545611,
    provider: "Netflix",
  },
  {
    title: "Glass Onion",
    year: "2022",
    rating: "7.1",
    movieId: 661374,
    provider: "Netflix",
  },
  {
    title: "Oppenheimer",
    year: "2023",
    rating: "8.9",
    movieId: 872585,
    provider: "Prime Video",
  },
  {
    title: "The Batman",
    year: "2022",
    rating: "7.8",
    movieId: 414906,
    provider: "Max",
  },
  {
    title: "Killers of the Flower Moon",
    year: "2023",
    rating: "7.6",
    movieId: 466420,
    provider: "Apple TV+",
  },
];

const INK = "var(--bg)";
const FU = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };
const FS = { hidden: { opacity: 0, scale: 0.94 }, visible: { opacity: 1, scale: 1 } };
const SPRING_TRANSITION = { type: "spring", stiffness: 350, damping: 25, bounce: 0 };
const VP = { once: true, amount: 0.15 };

// ─── Precision Apple Titanium Phone Chassis ────────────────────────────────
function Phone({
  children,
  height = "clamp(340px, 48vh, 500px)",
}: {
  children?: React.ReactNode;
  height?: string;
}) {
  return (
    <div
      className="relative flex-shrink-0 select-none"
      style={{
        height,
        aspectRatio: "390/844",
      }}
    >
      {/* Outer Titanium Edge & Volumetric Shadow */}
      <div
        className="absolute inset-0 rounded-[36px] p-2"
        style={{
          background: "linear-gradient(155deg, rgba(255,255,255,0.22) 0%, rgba(255,255,255,0.03) 45%, rgba(0,0,0,0.9) 100%)",
          boxShadow: "0 30px 80px -10px rgba(0,0,0,0.95), 0 0 0 1px rgba(255,255,255,0.08), inset 0 1px 1px rgba(255,255,255,0.25)",
        }}
      >
        {/* Hardware Buttons */}
        <div className="absolute -left-[3px] top-[14%] w-[3px] h-[4%] bg-[#2a2a2d] rounded-l-sm shadow-sm" />
        <div className="absolute -left-[3px] top-[21%] w-[3px] h-[7%] bg-[#2a2a2d] rounded-l-sm shadow-sm" />
        <div className="absolute -left-[3px] top-[29%] w-[3px] h-[7%] bg-[#2a2a2d] rounded-l-sm shadow-sm" />
        <div className="absolute -right-[3px] top-[22%] w-[3px] h-[10%] bg-[#2a2a2d] rounded-r-sm shadow-sm" />

        {/* Inner OLED Bezel & Island */}
        <div className="relative w-full h-full rounded-[28px] overflow-hidden bg-black">
          {/* Dynamic Island */}
          <div className="absolute top-2 left-1/2 -translate-x-1/2 w-18 h-3.5 bg-black/95 rounded-full z-40 flex items-center justify-end px-2 shadow-sm">
            <div className="w-1.5 h-1.5 rounded-full bg-[#151515] ring-1 ring-white/10" />
          </div>

          {/* Screen Content */}
          <div className="w-full h-full bg-[#0b0b0e]">{children}</div>

          {/* Subtle Specular Screen Sheen */}
          <div
            className="absolute inset-0 pointer-events-none z-30"
            style={{
              background: "linear-gradient(130deg, rgba(255,255,255,0.08) 0%, transparent 45%, rgba(0,0,0,0.12) 100%)",
            }}
          />

          {/* Home Bar */}
          <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-20 h-1 bg-white/20 rounded-full z-40 pointer-events-none" />
        </div>
      </div>
    </div>
  );
}

function Eyebrow({ children }: { children: React.ReactNode }) {
  return (
    <p
      className="text-xs font-semibold uppercase mb-3"
      style={{ color: "#6B4EFF", letterSpacing: "0.2em" }}
    >
      {children}
    </p>
  );
}

function SideLabel({
  step,
  heading,
  body,
}: {
  step: string;
  heading: React.ReactNode;
  body: string;
}) {
  return (
    <div className="w-full md:w-auto md:flex-1 text-center md:text-left" style={{ maxWidth: 380 }}>
      <Eyebrow>{step}</Eyebrow>
      <h2
        className="font-bold leading-[0.95] tracking-tight mb-3.5 text-white"
        style={{
          fontFamily: "var(--font-display)",
          fontSize: "clamp(1.8rem, 3vw, 3.2rem)",
          letterSpacing: "-0.03em",
        }}
      >
        {heading}
      </h2>
      <p
        className="font-light leading-relaxed"
        style={{
          fontSize: "clamp(0.9rem, 1.1vw, 1.05rem)",
          color: "rgba(255,255,255,0.52)",
          lineHeight: 1.6,
        }}
      >
        {body}
      </p>
    </div>
  );
}

function Chapter({
  op,
  y,
  children,
}: {
  op?: MotionValue<number>;
  y?: MotionValue<number>;
  children: React.ReactNode;
}) {
  return (
    <motion.div
      style={{
        opacity: op,
        y,
        position: "absolute",
        inset: 0,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "0 1.5rem",
      }}
    >
      {children}
    </motion.div>
  );
}

// ─── Apple-Grade Watchlist Media Showcase ───────────────────────────────────
function WatchlistShowcase() {
  return (
    <div className="w-full max-w-5xl flex flex-col items-center justify-center text-center">
      {/* Editorial Apple-Style Header */}
      <div className="mb-6 max-w-xl">
        <Eyebrow>Your Watchlist</Eyebrow>
        <h3
          className="text-white text-2xl md:text-3xl font-bold tracking-tight mb-1.5"
          style={{
            fontFamily: "var(--font-display)",
            letterSpacing: "-0.03em",
          }}
        >
          Everything you saved, in one place.
        </h3>
        <p className="text-xs md:text-sm text-white/45 font-light">
          Synced across streaming providers with instant one-tap launch.
        </p>
      </div>

      {/* 6-Card Media Grid with Emil Kowalski Fluid Spring Physics */}
      <div className="grid grid-cols-3 md:grid-cols-6 gap-3 md:gap-4 w-full max-w-4xl px-2">
        {WATCHLIST_MOVIES.map((m) => (
          <motion.div
            key={m.title}
            whileHover={{
              y: -8,
              scale: 1.03,
              transition: SPRING_TRANSITION,
            }}
            whileTap={{ scale: 0.97, transition: { duration: 0.08 } }}
            className="group relative rounded-2xl overflow-hidden flex flex-col justify-end select-none cursor-pointer"
            style={{
              height: "clamp(150px, 22vh, 210px)",
              aspectRatio: "2/3",
              background: "rgba(255,255,255,0.03)",
              border: "1px solid rgba(255,255,255,0.12)",
              boxShadow: "0 20px 48px rgba(0,0,0,0.75), inset 0 1px 0 rgba(255,255,255,0.15)",
              backdropFilter: "blur(12px)",
            }}
          >
            {/* Poster Image */}
            <TMDBPoster
              movieId={m.movieId}
              alt={m.title}
              className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
            />

            {/* Clean Apple-Style Glass Provider Badge */}
            <div className="absolute top-2 right-2 z-20">
              <span
                className="px-2 py-0.5 rounded-full text-[9px] font-medium text-white/85 backdrop-blur-md shadow-sm"
                style={{
                  background: "rgba(0, 0, 0, 0.65)",
                  border: "1px solid rgba(255, 255, 255, 0.14)",
                }}
              >
                {m.provider}
              </span>
            </div>

            {/* Bottom Scrim */}
            <div
              className="absolute inset-0 z-10 pointer-events-none"
              style={{
                background:
                  "linear-gradient(to top, rgba(0,0,0,0.92) 0%, rgba(0,0,0,0.4) 45%, transparent 70%)",
              }}
            />

            {/* Card Metadata */}
            <div className="relative z-20 p-2.5 text-left">
              <p
                className="text-white text-xs font-semibold leading-tight line-clamp-2 drop-shadow-sm"
                style={{ fontFamily: "var(--font-display)" }}
              >
                {m.title}
              </p>
              <div className="flex items-center gap-1.5 mt-1">
                <span className="text-[10px] text-white/45 font-light">{m.year}</span>
                <span className="text-[10px] text-amber-300 font-medium flex items-center gap-0.5">
                  ★ {m.rating}
                </span>
              </div>
            </div>

            {/* Specular Edge Highlight on Hover */}
            <div
              className="absolute inset-0 pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-300 z-30"
              style={{
                border: "1px solid rgba(107, 78, 255, 0.5)",
                borderRadius: "inherit",
              }}
            />
          </motion.div>
        ))}
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════════════
// MOBILE SCENE4
// ════════════════════════════════════════════════════════════════════════════
function Scene4Mobile() {
  const border = { borderBottom: "1px solid rgba(255,255,255,0.06)" };
  const section = "py-20 px-5 flex flex-col items-center";

  return (
    <div id="features" style={{ background: INK }}>
      {/* Step 1 — Vibe */}
      <section className={section} style={border}>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FU}
          transition={SPRING_TRANSITION}
          className="text-center mb-8"
        >
          <SideLabel
            step="Step 1"
            heading={<>WHAT YOU<br />FEELING LIKE TODAY</>}
            body="Action. Horror. Comedy. Pick as many as fit your mood."
          />
        </motion.div>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FS}
          transition={{ ...SPRING_TRANSITION, delay: 0.1 }}
          className="flex justify-center"
        >
          <Phone height="clamp(420px, 58vh, 540px)">
            <img src={moodSelectionImg} alt="Mood selection" className="w-full h-full object-cover" />
          </Phone>
        </motion.div>
      </section>

      {/* Step 2 — Pick 3 */}
      <section className={section} style={border}>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FU}
          transition={SPRING_TRANSITION}
          className="text-center mb-8"
        >
          <SideLabel
            step="Step 2"
            heading={<>PICK 3 OR MORE<br />MOVIES YOU LOVE.</>}
            body="Optional. It just helps narrow things down."
          />
        </motion.div>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FS}
          transition={{ ...SPRING_TRANSITION, delay: 0.1 }}
          className="flex justify-center"
        >
          <Phone height="clamp(420px, 58vh, 540px)">
            <img src={pickThreeImg} alt="Pick 3 movies" className="w-full h-full object-cover" />
          </Phone>
        </motion.div>
      </section>

      {/* Taste Established — Arc */}
      <section className={section} style={border}>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FU}
          transition={SPRING_TRANSITION}
          className="text-center mb-6"
        >
          <p className="text-base font-light text-white/50" style={{ letterSpacing: "0.06em" }}>
            Taste, established.
          </p>
          <p className="text-xs mt-1 text-white/30 tracking-widest uppercase">
            Three films. Infinite signal.
          </p>
        </motion.div>
        <div className="flex items-end justify-center gap-2 mb-6">
          {TASTE_ESTABLISHED_MOVIES.slice(0, 3).map((m, i) => (
            <motion.div
              key={m.title}
              initial="hidden"
              whileInView="visible"
              viewport={VP}
              variants={FS}
              transition={{ ...SPRING_TRANSITION, delay: i * 0.1 }}
              className="relative overflow-hidden rounded-xl flex-shrink-0"
              style={{
                width: i === 1 ? "34vw" : "28vw",
                maxWidth: 140,
                height: i === 1 ? "51vw" : "42vw",
                maxHeight: 210,
                marginBottom: i !== 1 ? "2vw" : 0,
                border: "1px solid rgba(255,255,255,0.08)",
                boxShadow: "0 16px 40px rgba(0,0,0,0.7)",
              }}
            >
              <TMDBPoster movieId={m.movieId} alt={m.title} className="w-full h-full object-cover" />
              <div
                className="absolute inset-0"
                style={{ background: "linear-gradient(to top, rgba(0,0,0,0.7) 0%, transparent 50%)" }}
              />
            </motion.div>
          ))}
        </div>
      </section>

      {/* Your Deck — Horizontal scroll */}
      <section className={section} style={border}>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FU}
          transition={SPRING_TRANSITION}
          className="text-center mb-8"
        >
          <Eyebrow>Your Deck</Eyebrow>
          <p className="text-sm font-light text-white/50">Scroll to flip through your cards</p>
          <p className="text-xs mt-1 text-white/25">
            In the app, this is a swipe. Left to skip, right to save, up for watched.
          </p>
        </motion.div>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FU}
          transition={{ ...SPRING_TRANSITION, delay: 0.1 }}
          className="w-full"
        >
          <div
            className="flex gap-3 overflow-x-auto pb-4 px-2"
            style={{ scrollbarWidth: "none", WebkitOverflowScrolling: "touch" } as React.CSSProperties}
          >
            {DECK_MOVIES.map((m) => (
              <div
                key={m.title}
                className="relative overflow-hidden rounded-xl flex-shrink-0"
                style={{
                  width: "38vw",
                  maxWidth: 160,
                  height: "57vw",
                  maxHeight: 240,
                  border: "1px solid rgba(255,255,255,0.08)",
                  boxShadow: "0 12px 32px rgba(0,0,0,0.6)",
                }}
              >
                <TMDBPoster movieId={m.movieId} alt={m.title} className="w-full h-full object-cover" />
                <div
                  className="absolute inset-0"
                  style={{ background: "linear-gradient(to top, rgba(0,0,0,0.75) 0%, transparent 50%)" }}
                />
                <p className="absolute bottom-2 left-2 right-2 text-white font-semibold truncate text-[11px]">
                  {m.title}
                </p>
              </div>
            ))}
          </div>
          <p className="text-xs mt-3 text-center tracking-widest uppercase text-white/20">
            Swipe left to skip · Swipe right to watchlist
          </p>
        </motion.div>
      </section>

      {/* Watchlist on Mobile */}
      <section className={section} style={border}>
        <WatchlistShowcase />
      </section>

      {/* Tap to explore / Overview */}
      <section className={section} style={border}>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FU}
          transition={SPRING_TRANSITION}
          className="text-center mb-8"
        >
          <Eyebrow>Overview</Eyebrow>
          <p className="text-sm font-light text-white/50">
            Direct streaming links & trailers in one tap
          </p>
        </motion.div>
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={VP}
          variants={FS}
          transition={{ ...SPRING_TRANSITION, delay: 0.1 }}
          className="flex justify-center"
        >
          <Phone height="clamp(420px, 58vh, 540px)">
            <img src={overviewImg} alt="Overview" className="w-full h-full object-cover" />
          </Phone>
        </motion.div>
      </section>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════════════════
// DESKTOP SCENE4 — scroll-scrubbed
// ════════════════════════════════════════════════════════════════════════════
function PreDeck() {
  const ref = useRef<HTMLDivElement>(null);
  const R = useReducedMotion();
  const { scrollYProgress: p } = useScroll({ target: ref, offset: ["start start", "end end"] });
  const s = 1 / 3;
  const op0 = useTransform(p, [0, s * 0.8, s], [1, 1, 0]);
  const op1 = useTransform(p, [s * 0.85, s + s * 0.15, s + s * 0.8, 2 * s], [0, 1, 1, 0]);
  const op2 = useTransform(p, [2 * s * 0.9, 2 * s + s * 0.15, 1], [0, 1, 1]);
  const y0 = useTransform(p, [0, s * 0.15], [0, 0]);
  const y1 = useTransform(p, [s * 0.85, s + s * 0.15], [32, 0]);

  return (
    <div id="features" ref={ref} style={{ height: "300vh", position: "relative" }}>
      <div className="sticky top-0 overflow-hidden" style={{ height: "100dvh", background: INK }}>
        {/* Soft Ambient Environmental Spotlights */}
        <div
          className="pointer-events-none absolute inset-0"
          style={{
            background:
              "radial-gradient(ellipse 65% 55% at 50% 50%, rgba(107,78,255,0.06) 0%, transparent 70%)",
          }}
        />

        {/* Step 1: Mood */}
        <Chapter op={op0} y={R ? undefined : y0}>
          <div className="flex flex-col md:flex-row items-center justify-center gap-10 md:gap-16 w-full max-w-5xl py-6">
            <SideLabel
              step="Step 1"
              heading={<>WHAT YOU<br />FEELING LIKE TODAY</>}
              body="Action. Horror. Comedy. Pick as many as fit your mood."
            />
            <Phone height="clamp(360px, 50vh, 500px)">
              <img src={moodSelectionImg} alt="Mood selection" className="w-full h-full object-cover" />
            </Phone>
          </div>
        </Chapter>

        {/* Step 2: Pick 3 */}
        <Chapter op={op1} y={R ? undefined : y1}>
          <div className="flex flex-col-reverse md:flex-row items-center justify-center gap-10 md:gap-16 w-full max-w-5xl py-6">
            <Phone height="clamp(360px, 50vh, 500px)">
              <img src={pickThreeImg} alt="Pick 3 movies" className="w-full h-full object-cover" />
            </Phone>
            <SideLabel
              step="Step 2"
              heading={<>PICK 3 OR MORE<br />MOVIES YOU LOVE.</>}
              body="Optional. It just helps narrow things down."
            />
          </div>
        </Chapter>

        {/* Chapter 3: Taste Established */}
        <Chapter op={op2}>
          <div className="flex flex-col items-center">
            <p
              className="text-lg font-light mb-2 text-center text-white/60"
              style={{ letterSpacing: "0.08em" }}
            >
              Taste, established.
            </p>
            <p className="text-xs mb-10 text-center text-white/30 tracking-widest uppercase">
              Three films. Infinite signal.
            </p>
            <div className="flex items-end justify-center gap-3 md:gap-4 relative">
              {/* Floor Shadow Plane */}
              <div
                className="absolute -bottom-6 left-1/2 -translate-x-1/2 w-4/5 h-12 rounded-full blur-xl pointer-events-none"
                style={{ background: "rgba(107,78,255,0.18)" }}
              />

              {TASTE_ESTABLISHED_MOVIES.map((m, i) => (
                <motion.div
                  key={`${m.title}-${i}`}
                  whileHover={{ y: -6, scale: 1.05, transition: SPRING_TRANSITION }}
                  className="relative overflow-hidden rounded-2xl flex-shrink-0 select-none cursor-pointer"
                  style={{
                    height: i === 2 || i === 3 ? "clamp(160px,30vh,280px)" : "clamp(120px,24vh,220px)",
                    aspectRatio: "2/3",
                    transform: `translateY(${i === 2 || i === 3 ? -20 : 0}px) rotate(${(i - 2.5) * 4.5}deg)`,
                    boxShadow: "0 28px 70px rgba(0,0,0,0.85)",
                    border:
                      i === 2 || i === 3
                        ? "1px solid rgba(107,78,255,0.35)"
                        : "1px solid rgba(255,255,255,0.08)",
                    zIndex: i === 2 || i === 3 ? 10 : 5,
                  }}
                >
                  <TMDBPoster movieId={m.movieId} alt={m.title} className="w-full h-full object-cover" />
                  <div
                    className="absolute inset-0"
                    style={{
                      background: "linear-gradient(to top, rgba(0,0,0,0.72) 0%, transparent 50%)",
                    }}
                  />
                  <p className="absolute bottom-2.5 left-2.5 right-2.5 text-white text-[11px] font-semibold truncate drop-shadow-sm">
                    {m.title}
                  </p>
                </motion.div>
              ))}
            </div>
            <p
              className="text-xs mt-10 tracking-widest uppercase font-medium"
              style={{ color: "#6B4EFF" }}
            >
              Building your deck…
            </p>
          </div>
        </Chapter>
      </div>
    </div>
  );
}

function DeckSection() {
  const ref = useRef<HTMLDivElement>(null);
  const R = useReducedMotion();
  const { scrollYProgress: p } = useScroll({ target: ref, offset: ["start start", "end end"] });
  const rowX = useTransform(p, [0.05, 0.95], ["36vw", "-54vw"]);
  const deckP = useTransform(p, [0.05, 0.95], [0, 7]);
  const sc0 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(0 - v) * 0.078));
  const sc1 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(1 - v) * 0.078));
  const sc2 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(2 - v) * 0.078));
  const sc3 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(3 - v) * 0.078));
  const sc4 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(4 - v) * 0.078));
  const sc5 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(5 - v) * 0.078));
  const sc6 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(6 - v) * 0.078));
  const sc7 = useTransform(deckP, (v) => Math.max(0.72, 1 - Math.abs(7 - v) * 0.078));
  const scales = [sc0, sc1, sc2, sc3, sc4, sc5, sc6, sc7];
  const sectionOp = useTransform(p, [0, 0.1, 0.9, 1], [0, 1, 1, 0]);

  return (
    <div ref={ref} style={{ height: "220vh", position: "relative" }}>
      <div
        className="sticky top-0 overflow-hidden flex flex-col items-center justify-center"
        style={{ height: "100dvh", background: INK }}
      >
        <div
          className="pointer-events-none absolute inset-0"
          style={{
            background:
              "radial-gradient(ellipse 50% 60% at 50% 50%, rgba(107,78,255,0.04) 0%, transparent 70%)",
          }}
        />
        <motion.div style={{ opacity: sectionOp }} className="w-full flex flex-col items-center">
          <Eyebrow>Your Deck</Eyebrow>
          <p
            className="font-bold mb-2 text-center text-white"
            style={{
              fontFamily: "var(--font-display)",
              fontSize: "clamp(1.8rem, 3.2vw, 2.8rem)",
              letterSpacing: "-0.02em",
            }}
          >
            Scroll to flip through your cards
          </p>
          <p className="text-xs md:text-sm mb-10 text-center text-white/40 max-w-md">
            In the app, this is a swipe. Left to skip, right to save, up for watched.
          </p>
          <div style={{ width: "100%", overflow: "hidden" }}>
            <motion.div style={{ x: R ? "0vw" : rowX }} className="flex items-center gap-4 md:gap-5">
              {DECK_MOVIES.map((m, i) => (
                <motion.div
                  key={m.title}
                  style={{
                    scale: R ? 1 : scales[i],
                    transformOrigin: "center center",
                    height: "clamp(180px,32vh,300px)",
                    aspectRatio: "2/3",
                    boxShadow: "0 24px 64px rgba(0,0,0,0.72)",
                    border: "1px solid rgba(255,255,255,0.08)",
                    flexShrink: 0,
                    borderRadius: 18,
                    overflow: "hidden",
                    position: "relative",
                  }}
                >
                  <TMDBPoster movieId={m.movieId} alt={m.title} className="w-full h-full object-cover" />
                  <div
                    style={{
                      position: "absolute",
                      inset: 0,
                      background: "linear-gradient(to top, rgba(0,0,0,0.85) 0%, transparent 45%)",
                    }}
                  />
                  <div style={{ position: "absolute", bottom: 12, left: 12, right: 12 }}>
                    <p
                      className="truncate text-white font-semibold"
                      style={{ fontSize: "clamp(10px,1.1vw,13px)" }}
                    >
                      {m.title}
                    </p>
                    <p style={{ color: "rgba(255,255,255,0.4)", fontSize: "11px", marginTop: 2 }}>
                      {m.year}
                    </p>
                  </div>
                </motion.div>
              ))}
            </motion.div>
          </div>
          <p className="mt-10 text-xs tracking-widest uppercase text-white/20">
            Swipe left to skip &nbsp;·&nbsp; Swipe right to watchlist
          </p>
        </motion.div>
      </div>
    </div>
  );
}

function PostDeck() {
  const ref = useRef<HTMLDivElement>(null);
  const R = useReducedMotion();
  const { scrollYProgress: p } = useScroll({ target: ref, offset: ["start start", "end end"] });
  const s = 1 / 3;
  const op0 = useTransform(p, [0, s * 0.15, s * 0.8, s], [0, 1, 1, 0]);
  const op1 = useTransform(p, [s * 0.85, s + s * 0.15, s + s * 0.8, 2 * s], [0, 1, 1, 0]);
  const op2 = useTransform(p, [2 * s * 0.9, 2 * s + s * 0.15, 1], [0, 1, 1]);
  const y0 = useTransform(p, [0, s * 0.15], [30, 0]);
  const y1 = useTransform(p, [s * 0.85, s + s * 0.15], [30, 0]);
  const y2 = useTransform(p, [2 * s * 0.9, 2 * s + s * 0.15], [30, 0]);

  return (
    <div ref={ref} style={{ height: "300vh", position: "relative" }}>
      <div className="sticky top-0 overflow-hidden" style={{ height: "100dvh", background: INK }}>
        <div
          className="pointer-events-none absolute inset-0"
          style={{
            background:
              "radial-gradient(ellipse 60% 60% at 50% 50%, rgba(107,78,255,0.05) 0%, transparent 70%)",
          }}
        />

        {/* Chapter 0: Apple-Grade Watchlist Media Showcase */}
        <Chapter op={op0} y={R ? undefined : y0}>
          <WatchlistShowcase />
        </Chapter>

        {/* Chapter 1: Overview & Streaming */}
        <Chapter op={op1} y={R ? undefined : y1}>
          <div className="flex flex-col md:flex-row items-center justify-center gap-10 md:gap-16 w-full max-w-5xl">
            <SideLabel
              step="Overview"
              heading={<>TAP ANY TITLE TO<br />DISCOVER & STREAM</>}
              body="Instant access to trailers, episode guides, and direct links to Netflix, Prime Video, Apple TV+ & YouTube."
            />
            <Phone height="clamp(360px, 50vh, 500px)">
              <img src={overviewImg} alt="Overview" className="w-full h-full object-cover" />
            </Phone>
          </div>
        </Chapter>
      </div>
    </div>
  );
}

function Scene4Desktop() {
  return (
    <>
      <PreDeck />
      <DeckSection />
      <PostDeck />
    </>
  );
}

// ─── Root ──────────────────────────────────────────────────────────────────
export default function Scene4() {
  const mobile = useIsMobile();
  return mobile ? <Scene4Mobile /> : <Scene4Desktop />;
}
