import { useRef, useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { useReducedMotion } from '../hooks/useReducedMotion'
import GlassButton from './GlassButton'

export default function Hero() {
  const containerRef = useRef<HTMLDivElement>(null)
  const [cursor, setCursor] = useState({ x: -999, y: -999 })
  const [hovering, setHovering] = useState(false)
  const reduced = useReducedMotion()

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()
    setCursor({ x: e.clientX - rect.left, y: e.clientY - rect.top })
  }

  const mask = `radial-gradient(circle at ${cursor.x}px ${cursor.y}px, #000 80px, transparent 140px)`

  return (
    <div
      ref={containerRef}
      className="relative flex flex-col items-center justify-center min-h-screen pt-16 overflow-hidden"
      style={{ backgroundColor: 'var(--ink)' }}
      onPointerEnter={() => setHovering(true)}
      onPointerMove={handlePointerMove}
      onPointerLeave={() => { setHovering(false); setCursor({ x: -999, y: -999 }) }}
    >
      {/* Base dot grid */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage: 'radial-gradient(circle at center, rgba(107,78,255,0.18) 1px, transparent 1.2px)',
          backgroundSize: '24px 24px',
        }}
      />

      {/* Revealed dot grid under cursor */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none transition-opacity duration-300"
        style={{
          backgroundImage: 'radial-gradient(circle at center, rgba(107,78,255,0.7) 1.6px, transparent 2px)',
          backgroundSize: '24px 24px',
          opacity: hovering ? 1 : 0,
          maskImage: mask,
          WebkitMaskImage: mask,
        }}
      />

      {/* Ambient indigo glow */}
      <div
        aria-hidden="true"
        className="absolute pointer-events-none"
        style={{
          bottom: '-10%',
          left: '50%',
          transform: 'translateX(-50%)',
          width: '70vw',
          height: '50vh',
          background: 'radial-gradient(ellipse at center, rgba(107,78,255,0.22) 0%, transparent 70%)',
          filter: 'blur(60px)',
        }}
      />

      {/* Secondary cyan accent glow */}
      <div
        aria-hidden="true"
        className="absolute pointer-events-none"
        style={{
          top: '20%',
          right: '10%',
          width: '30vw',
          height: '30vh',
          background: 'radial-gradient(ellipse at center, rgba(0,240,255,0.06) 0%, transparent 70%)',
          filter: 'blur(80px)',
        }}
      />

      {/* Content */}
      <motion.div
        className="relative z-10 flex flex-col items-center text-center px-6 max-w-4xl mx-auto"
        initial={reduced ? false : { opacity: 0, y: 32 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1] }}
      >
        {/* Badge */}
        <motion.div
          initial={reduced ? false : { opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="mb-8 inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium"
          style={{
            background: 'rgba(107,78,255,0.12)',
            border: '1px solid rgba(107,78,255,0.3)',
            color: '#a891ff',
            fontFamily: 'var(--font-body)',
          }}
        >
          <span className="w-1.5 h-1.5 rounded-full bg-[#6B4EFF] animate-pulse" aria-hidden="true" />
          Android live · iOS coming soon
        </motion.div>

        {/* Headline */}
        <h1
          className="text-5xl md:text-7xl lg:text-8xl font-bold leading-[1.05] tracking-tight text-white mb-6"
          style={{ fontFamily: 'var(--font-display)' }}
        >
          Stop scrolling.
          <br />
          <span style={{ color: '#6B4EFF' }}>Start watching.</span>
        </h1>

        {/* Subhead */}
        <p
          className="text-lg md:text-xl text-white/50 max-w-xl mb-10 leading-relaxed"
          style={{ fontFamily: 'var(--font-body)' }}
        >
          Pick three movies you love. Pickd builds your Taste DNA — then swipes a personalized deck so you spend less time choosing and more time watching.
        </p>

        {/* CTA row */}
        <div className="flex flex-col sm:flex-row items-center gap-4">
          <GlassButton href="https://github.com/J-Derek/Pickd/releases" size="lg" target="_blank" rel="noopener noreferrer">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download APK
          </GlassButton>
          <a
            href="#how-it-works"
            className="text-sm text-white/40 hover:text-white/70 transition-colors duration-150 flex items-center gap-1.5"
          >
            See how it works
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
              <polyline points="6 9 12 15 18 9" />
            </svg>
          </a>
        </div>
      </motion.div>

      {/* Scroll nudge */}
      <motion.div
        className="absolute bottom-8 left-1/2 -translate-x-1/2"
        initial={reduced ? false : { opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.5, duration: 0.6 }}
        aria-hidden="true"
      >
        <div className="w-px h-10 mx-auto" style={{ background: 'linear-gradient(to bottom, rgba(255,255,255,0.15), transparent)' }} />
      </motion.div>
    </div>
  )
}
