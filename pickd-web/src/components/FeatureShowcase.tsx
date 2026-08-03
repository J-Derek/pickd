import { useRef, useState, useEffect, useCallback } from 'react'
import { motion, useScroll, useTransform } from 'framer-motion'
import { useReducedMotion } from '../hooks/useReducedMotion'

const FEATURES = [
  {
    number: '01',
    accent: '#6B4EFF',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
      </svg>
    ),
    headline: 'Skip the genre quiz.',
    body: 'Three movies. That\'s it. Pickd builds an emotional fingerprint of your taste instead of sorting you into a checkbox.',
    tag: 'Taste DNA',
  },
  {
    number: '02',
    accent: '#00F0FF',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <polyline points="9 10 4 15 9 20" />
        <path d="M20 4v7a4 4 0 0 1-4 4H4" />
      </svg>
    ),
    headline: 'Decide in half a second.',
    body: 'Right to watch, left to pass. Every swipe trains your deck to know you better than your group chat does.',
    tag: 'Swipe Deck',
  },
  {
    number: '03',
    accent: '#FFC107',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
      </svg>
    ),
    headline: 'Deeper than the homepage.',
    body: 'Critically loved, barely seen. Hidden Gems surfaces what streaming platforms bury under their own promoted rows.',
    tag: 'Hidden Gems',
  },
  {
    number: '04',
    accent: '#6B4EFF',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <line x1="8" y1="6" x2="21" y2="6" />
        <line x1="8" y1="12" x2="21" y2="12" />
        <line x1="8" y1="18" x2="21" y2="18" />
        <line x1="3" y1="6" x2="3.01" y2="6" />
        <line x1="3" y1="12" x2="3.01" y2="12" />
        <line x1="3" y1="18" x2="3.01" y2="18" />
      </svg>
    ),
    headline: 'Zero latency, zero excuses.',
    body: 'Filter by mood, runtime, or platform, instantly, cached locally. No spinner, no "buffering."',
    tag: 'Dynamic Watchlist',
  },
]

function FeatureCard({ feature, index, activeIndex }: { feature: typeof FEATURES[0]; index: number; activeIndex: number }) {
  const dist = index - activeIndex
  const rotation = dist * 3
  const opacity = dist === 0 ? 1 : dist === 1 ? 0.7 : 0.4
  const scale = dist === 0 ? 1 : dist === 1 ? 0.97 : 0.94

  return (
    <div
      className="flex-shrink-0 w-80 md:w-96"
      style={{
        transform: `rotate(${rotation}deg) scale(${scale})`,
        opacity,
        transition: 'transform 0.5s cubic-bezier(0.16,1,0.3,1), opacity 0.4s ease',
        transformOrigin: 'bottom center',
      }}
    >
      <div
        className="h-[480px] rounded-2xl p-8 flex flex-col justify-between relative overflow-hidden"
        style={{
          background: 'rgba(255,255,255,0.035)',
          border: '1px solid rgba(255,255,255,0.08)',
          backdropFilter: 'blur(12px)',
        }}
      >
        {/* Accent corner glow */}
        <div
          aria-hidden="true"
          className="absolute top-0 right-0 w-40 h-40 pointer-events-none"
          style={{
            background: `radial-gradient(circle at top right, ${feature.accent}20 0%, transparent 70%)`,
          }}
        />

        <div>
          {/* Number */}
          <span
            className="text-xs font-semibold tracking-widest uppercase mb-6 block"
            style={{ color: feature.accent, fontFamily: 'var(--font-body)' }}
          >
            {feature.number}
          </span>

          {/* Tag pill */}
          <div
            className="inline-flex items-center gap-2 rounded-full px-3 py-1 mb-6"
            style={{
              background: `${feature.accent}15`,
              border: `1px solid ${feature.accent}30`,
            }}
          >
            <span style={{ color: feature.accent }}>{feature.icon}</span>
            <span className="text-xs font-medium text-white/70" style={{ fontFamily: 'var(--font-body)' }}>
              {feature.tag}
            </span>
          </div>

          {/* Headline */}
          <h3
            className="text-2xl md:text-3xl font-bold text-white leading-tight mb-4"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            {feature.headline}
          </h3>

          {/* Body */}
          <p className="text-white/50 leading-relaxed text-sm md:text-base" style={{ fontFamily: 'var(--font-body)' }}>
            {feature.body}
          </p>
        </div>

        {/* Bottom accent bar */}
        <div
          className="h-px w-full mt-6"
          style={{ background: `linear-gradient(to right, ${feature.accent}60, transparent)` }}
          aria-hidden="true"
        />
      </div>
    </div>
  )
}

function MobileCarousel() {
  const [active, setActive] = useState(0)
  const trackRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const track = trackRef.current
    if (!track) return

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const idx = Number((entry.target as HTMLElement).dataset.index)
            setActive(idx)
          }
        })
      },
      { root: track, threshold: 0.5 }
    )

    Array.from(track.children).forEach((child) => observer.observe(child))
    return () => observer.disconnect()
  }, [])

  return (
    <div className="w-full">
      <div
        ref={trackRef}
        className="flex gap-4 overflow-x-auto pb-4"
        style={{
          scrollSnapType: 'x mandatory',
          scrollbarWidth: 'none',
          msOverflowStyle: 'none',
          paddingLeft: 'calc(50vw - 160px)',
          paddingRight: 'calc(50vw - 160px)',
        }}
        role="list"
        aria-label="Feature cards"
      >
        {FEATURES.map((feature, i) => (
          <div
            key={feature.tag}
            data-index={i}
            style={{ scrollSnapAlign: 'center', flexShrink: 0 }}
            role="listitem"
          >
            <div
              className="w-72 h-[420px] rounded-2xl p-7 flex flex-col justify-between relative overflow-hidden"
              style={{
                background: 'rgba(255,255,255,0.035)',
                border: '1px solid rgba(255,255,255,0.08)',
              }}
            >
              <div
                aria-hidden="true"
                className="absolute top-0 right-0 w-32 h-32"
                style={{ background: `radial-gradient(circle at top right, ${feature.accent}20 0%, transparent 70%)` }}
              />
              <div>
                <span className="text-xs font-semibold tracking-widest uppercase mb-4 block" style={{ color: feature.accent }}>
                  {feature.number}
                </span>
                <div
                  className="inline-flex items-center gap-2 rounded-full px-3 py-1 mb-4"
                  style={{ background: `${feature.accent}15`, border: `1px solid ${feature.accent}30` }}
                >
                  <span style={{ color: feature.accent }}>{feature.icon}</span>
                  <span className="text-xs font-medium text-white/70">{feature.tag}</span>
                </div>
                <h3 className="text-xl font-bold text-white leading-tight mb-3" style={{ fontFamily: 'var(--font-display)' }}>
                  {feature.headline}
                </h3>
                <p className="text-white/50 leading-relaxed text-sm">{feature.body}</p>
              </div>
              <div className="h-px w-full" style={{ background: `linear-gradient(to right, ${feature.accent}60, transparent)` }} aria-hidden="true" />
            </div>
          </div>
        ))}
      </div>

      {/* Dot indicators */}
      <div className="flex justify-center gap-2 mt-6" role="tablist" aria-label="Feature card navigation">
        {FEATURES.map((_, i) => (
          <button
            key={i}
            role="tab"
            aria-selected={i === active}
            aria-label={`Go to feature ${i + 1}`}
            onClick={() => {
              const track = trackRef.current
              if (!track) return
              const child = track.children[i] as HTMLElement
              child.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' })
            }}
            className="transition-all duration-300 rounded-full focus:outline-none focus:ring-2 focus:ring-[#6B4EFF]/50"
            style={{
              width: i === active ? 20 : 6,
              height: 6,
              background: i === active ? '#6B4EFF' : 'rgba(255,255,255,0.2)',
            }}
          />
        ))}
      </div>
    </div>
  )
}

function DesktopDeck() {
  const wrapperRef = useRef<HTMLDivElement>(null)
  const [activeIndex, setActiveIndex] = useState(0)
  const reduced = useReducedMotion()

  const { scrollYProgress } = useScroll({
    target: wrapperRef,
    offset: ['start start', 'end end'],
  })

  useEffect(() => {
    if (reduced) return
    const unsub = scrollYProgress.on('change', (v) => {
      const idx = Math.min(Math.round(v * (FEATURES.length - 1)), FEATURES.length - 1)
      setActiveIndex(idx)
    })
    return unsub
  }, [scrollYProgress, reduced])

  if (reduced) {
    return (
      <div className="grid grid-cols-2 gap-6 max-w-4xl mx-auto px-6">
        {FEATURES.map((feature, i) => (
          <div
            key={feature.tag}
            className="rounded-2xl p-7 flex flex-col gap-4 relative overflow-hidden"
            style={{
              background: 'rgba(255,255,255,0.035)',
              border: '1px solid rgba(255,255,255,0.08)',
            }}
          >
            <span className="text-xs font-semibold tracking-widest uppercase" style={{ color: feature.accent }}>{feature.number}</span>
            <h3 className="text-xl font-bold text-white" style={{ fontFamily: 'var(--font-display)' }}>{feature.headline}</h3>
            <p className="text-white/50 text-sm leading-relaxed">{feature.body}</p>
          </div>
        ))}
      </div>
    )
  }

  return (
    <div ref={wrapperRef} style={{ height: '300vh' }}>
      <div className="sticky top-0 h-screen flex flex-col items-center justify-center overflow-hidden">
        {/* Section label */}
        <div className="absolute top-12 left-1/2 -translate-x-1/2 text-center">
          <span className="text-xs tracking-widest uppercase text-white/30 font-medium">Features</span>
        </div>

        {/* Progress dots */}
        <div className="absolute right-10 top-1/2 -translate-y-1/2 flex flex-col gap-3" role="tablist" aria-label="Feature navigation">
          {FEATURES.map((_, i) => (
            <div
              key={i}
              role="tab"
              aria-selected={i === activeIndex}
              aria-label={`Feature ${i + 1}`}
              className="rounded-full transition-all duration-400"
              style={{
                width: 6,
                height: i === activeIndex ? 20 : 6,
                background: i === activeIndex ? '#6B4EFF' : 'rgba(255,255,255,0.2)',
              }}
            />
          ))}
        </div>

        {/* Card deck */}
        <div className="relative flex items-center justify-center w-full" style={{ perspective: '1200px' }}>
          <div className="flex items-center" style={{ gap: '24px' }}>
            {FEATURES.map((feature, i) => (
              <FeatureCard key={feature.tag} feature={feature} index={i} activeIndex={activeIndex} />
            ))}
          </div>
        </div>

        {/* Active headline echo */}
        <motion.div
          className="absolute bottom-16 left-1/2 -translate-x-1/2 text-center"
          key={activeIndex}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
        >
          <span className="text-xs text-white/25 tracking-wide" style={{ fontFamily: 'var(--font-body)' }}>
            Scroll to explore
          </span>
        </motion.div>
      </div>
    </div>
  )
}

export default function FeatureShowcase() {
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const mq = window.matchMedia('(max-width: 767px)')
    const handle = (e: MediaQueryListEvent) => setIsMobile(e.matches)
    setIsMobile(mq.matches)
    mq.addEventListener('change', handle)
    return () => mq.removeEventListener('change', handle)
  }, [])

  return (
    <section id="features" aria-label="Features" style={{ backgroundColor: 'var(--ink)' }}>
      {isMobile ? (
        <div className="py-20 px-4">
          <div className="text-center mb-12">
            <span className="text-xs tracking-widest uppercase text-white/30 font-medium block mb-3">Features</span>
            <h2
              className="text-3xl font-bold text-white"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              Built around how you actually choose.
            </h2>
          </div>
          <MobileCarousel />
        </div>
      ) : (
        <DesktopDeck />
      )}
    </section>
  )
}
