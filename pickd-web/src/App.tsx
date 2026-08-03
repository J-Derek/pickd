import Hero from "./components/Hero"

import Navbar from "./components/Navbar"

import FeatureShowcase from "./components/FeatureShowcase"

import HowItWorks from "./components/HowItWorks"

import FooterCTA from "./components/FooterCTA"

import TrendingMarquee from "./components/TrendingMarquee"

import ProblemStatement from "./components/ProblemStatement"

import PhoneRevealV2 from "./components/PhoneRevealV2"

import RecommendationJourney from "./components/RecommendationJourney"

import { ErrorBoundary } from "./components/ErrorBoundary"

import { useEffect, useRef } from "react"

const SHOW_TRENDING_MARQUEE = true

export default function App() {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (containerRef.current) {
        containerRef.current.style.setProperty("--mouse-x", `${e.clientX}px`)

        containerRef.current.style.setProperty("--mouse-y", `${e.clientY}px`)
      }
    }

    window.addEventListener("mousemove", handleMouseMove)

    return () => window.removeEventListener("mousemove", handleMouseMove)
  }, [])

  return (
    <div
      ref={containerRef}
      className="min-h-screen bg-ink text-foreground relative"
    >
      {/* Interactive Background Spotlight */}
      <div className="pointer-events-none fixed inset-0 z-0">
        {/* Tactile Grid revealed by mouse */}
        <div
          className="absolute inset-0 opacity-[0.07]"
          style={{
            backgroundImage: `
              linear-gradient(to right, rgba(255,255,255,1) 1px, transparent 1px),
              linear-gradient(to bottom, rgba(255,255,255,1) 1px, transparent 1px)
            `,

            backgroundSize: "48px 48px",

            maskImage: `radial-gradient(circle 600px at var(--mouse-x, 50%) var(--mouse-y, 50%), black 0%, transparent 100%)`,

            WebkitMaskImage: `radial-gradient(circle 600px at var(--mouse-x, 50%) var(--mouse-y, 50%), black 0%, transparent 100%)`,
          }}
        />
        {/* Deep indigo ambient glow following mouse */}
        <div
          className="absolute inset-0 opacity-[0.15]"
          style={{
            background: `radial-gradient(circle 800px at var(--mouse-x, 50%) var(--mouse-y, 50%), #6B4EFF 0%, transparent 100%)`,
          }}
        />
      </div>

      <Navbar />

      <main className="relative z-10">
        <ErrorBoundary>
          <Hero showMarquee={SHOW_TRENDING_MARQUEE} />
          <ProblemStatement />
          <PhoneRevealV2 />
          <RecommendationJourney />
          {/* Temporarily disabled while we perfect the cinematic sequence
          <FeatureShowcase />
          <HowItWorks />
          <FooterCTA />
          */}
        </ErrorBoundary>
      </main>
    </div>
  )
}
