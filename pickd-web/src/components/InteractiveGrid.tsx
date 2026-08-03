import { useRef, useState } from "react"

export default function InteractiveGrid({
  className = "",
}: {
  className?: string
}) {
  const containerRef = useRef<HTMLDivElement>(null)

  const [cursor, setCursor] = useState({ x: -999, y: -999 })

  const [hovering, setHovering] = useState(false)

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()

    setCursor({ x: e.clientX - rect.left, y: e.clientY - rect.top })
  }

  const mask = `radial-gradient(circle at ${cursor.x}px ${cursor.y}px, #000 80px, transparent 140px)`

  return (
    <div
      ref={containerRef}
      className={`absolute inset-0 overflow-hidden pointer-events-auto ${className}`}
      onPointerEnter={() => setHovering(true)}
      onPointerMove={handlePointerMove}
      onPointerLeave={() => {
        setHovering(false)

        setCursor({ x: -999, y: -999 })
      }}
    >
      {/* Base dot grid */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage:
            "radial-gradient(circle at center, rgba(107,78,255,0.18) 1px, transparent 1.2px)",

          backgroundSize: "24px 24px",
        }}
      />

      {/* Revealed dot grid under cursor */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none transition-opacity duration-300"
        style={{
          backgroundImage:
            "radial-gradient(circle at center, rgba(107,78,255,0.7) 1.6px, transparent 2px)",

          backgroundSize: "24px 24px",

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
          bottom: "-10%",

          left: "50%",

          transform: "translateX(-50%)",

          width: "70vw",

          height: "50vh",

          background:
            "radial-gradient(ellipse at center, rgba(107,78,255,0.22) 0%, transparent 70%)",

          filter: "blur(60px)",
        }}
      />

      {/* Secondary cyan accent glow */}
      <div
        aria-hidden="true"
        className="absolute pointer-events-none"
        style={{
          top: "20%",

          right: "10%",

          width: "30vw",

          height: "30vh",

          background:
            "radial-gradient(ellipse at center, rgba(0,240,255,0.06) 0%, transparent 70%)",

          filter: "blur(80px)",
        }}
      />
    </div>
  )
}
