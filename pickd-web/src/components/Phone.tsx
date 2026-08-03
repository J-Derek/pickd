interface PhoneProps {
  src: string

  alt: string
}

export default function Phone({ src, alt }: PhoneProps) {
  return (
    <div className="relative">
      {/* Ambient glow behind device */}
      <div
        className="absolute pointer-events-none"
        style={{
          inset: "-40px",

          borderRadius: "3rem",

          background:
            "radial-gradient(ellipse at center, rgba(107,78,255,0.35) 0%, rgba(0,240,255,0.1) 55%, transparent 80%)",

          filter: "blur(30px)",
        }}
      />

      {/* Clean presentation without fake chrome */}
      <div
        style={{
          position: "relative",

          width: "280px",

          borderRadius: "32px",

          border: "1px solid rgba(255,255,255,0.08)",

          boxShadow:
            "0 40px 80px rgba(0,0,0,0.8), 0 0 0 1px rgba(255,255,255,0.04) inset",

          overflow: "hidden",
        }}
      >
        <img
          src={src}
          alt={alt}
          loading="lazy"
          style={{
            display: "block",
            width: "100%",
            height: "100%",
            objectFit: "cover",
          }}
        />
      </div>
    </div>
  )
}
