import re

with open("C:/DevTools/projects/pickd/pickd-web/src/components/FeatureShowcase.tsx", "r", encoding="utf-8") as f:
    content = f.read()

# Extract the inner body of the ticket from FeatureCard.
# It starts at `<svg width="0" height="0" className="absolute pointer-events-none">`
# and ends at `</svg>` before `</motion.div>` in FeatureCard.

inner_ticket = """function PhysicalTicketContent({ feature, index }: { feature: typeof FEATURES[0]; index: number }) {
  return (
    <>
      <svg width="0" height="0" className="absolute pointer-events-none">
        <defs>
          <mask id={`ticket-mask-${index}`} maskContentUnits="objectBoundingBox">
            <path d="M 0.08,0 L 0.92,0 A 0.08 0.064 0 0 1 1 0.064 L 1 0.45 A 0.06 0.048 0 0 0 1 0.55 L 1 0.936 A 0.08 0.064 0 0 1 0.92 1 L 0.08 1 A 0.08 0.064 0 0 1 0 0.936 L 0 0.55 A 0.06 0.048 0 0 0 0 0.45 L 0 0.064 A 0.08 0.064 0 0 1 0.08 0 Z" fill="white" />
            
            {/* Film Sprocket Holes along the left edge */}
            {Array.from({ length: 8 }).map((_, i) => (
              <rect key={`sprocket-top-${i}`} x="0.04" y={0.12 + i * 0.035} width="0.02" height="0.015" rx="0.005" fill="black" />
            ))}
            {Array.from({ length: 8 }).map((_, i) => (
              <rect key={`sprocket-bot-${i}`} x="0.04" y={0.60 + i * 0.035} width="0.02" height="0.015" rx="0.005" fill="black" />
            ))}
          </mask>
          
          <filter id={`noiseFilter-${index}`}>
            <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="3" stitchTiles="stitch"/>
            <feColorMatrix type="matrix" values="1 0 0 0 0, 0 1 0 0 0, 0 0 1 0 0, 0 0 0 0.25 0" />
          </filter>

          <linearGradient id={`foil-gradient-${index}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="white" stopOpacity="0.9" />
            <stop offset="25%" stopColor="transparent" />
            <stop offset="75%" stopColor="transparent" />
            <stop offset="100%" stopColor="white" stopOpacity="0.7" />
          </linearGradient>
        </defs>
      </svg>

      {/* Physical Matte Card Body */}
      <div 
        className="absolute inset-0 bg-[#0d0d0f]" 
        style={{ WebkitMaskImage: `url(#ticket-mask-${index})`, maskImage: `url(#ticket-mask-${index})` }}
      >
        {/* Noise overlay for tactile paper feel */}
        <div className="absolute inset-0 pointer-events-none opacity-40" style={{ mixBlendMode: 'overlay' }}>
          <svg className="w-full h-full"><rect width="100%" height="100%" filter={`url(#noiseFilter-${index})`}/></svg>
        </div>
        
        {/* Content */}
        <div className="relative z-20 h-full p-8 pl-12 flex flex-col justify-between">
          {/* Subtle debossed structural lines */}
          <div className="absolute top-8 left-12 right-6 h-px bg-white/5" />
          <div className="absolute bottom-8 left-12 right-6 h-px bg-white/5" />

          <div>
            <span className="text-xs font-semibold tracking-widest uppercase mb-6 block" style={{ color: feature.accent, fontFamily: 'var(--font-body)' }}>
              {feature.number}
            </span>

            {/* Foil Tag Pill */}
            <div
              className="inline-flex items-center gap-2 rounded-full px-3 py-1.5 mb-6 relative overflow-hidden"
              style={{
                background: `linear-gradient(135deg, ${feature.accent}15, transparent)`,
                border: `1px solid ${feature.accent}50`,
                boxShadow: `inset 0 1px 0 0 rgba(255,255,255,0.15)`
              }}
            >
              <div style={{ color: feature.accent }}>
                {feature.icon}
              </div>
              <span className="text-xs font-bold text-white/90" style={{ fontFamily: 'var(--font-body)' }}>
                {feature.tag}
              </span>
            </div>

            <h3 className="text-2xl md:text-3xl font-bold text-white leading-tight mb-4" style={{ fontFamily: 'var(--font-display)', textShadow: '0 2px 10px rgba(0,0,0,0.8)' }}>
              {feature.headline}
            </h3>

            <p className="text-white/70 leading-relaxed text-sm md:text-base font-medium" style={{ fontFamily: 'var(--font-body)' }}>
              {feature.body}
            </p>
          </div>

          <div className="h-[2px] w-full mt-6 opacity-90" style={{ background: `linear-gradient(to right, ${feature.accent}, transparent)` }} aria-hidden="true" />
        </div>
      </div>

      {/* Foil Edge Tracing */}
      <svg className="absolute inset-0 w-full h-full pointer-events-none z-10" viewBox="0 0 1 1" preserveAspectRatio="none">
        <path 
          d="M 0.08,0 L 0.92,0 A 0.08 0.064 0 0 1 1 0.064 L 1 0.45 A 0.06 0.048 0 0 0 1 0.55 L 1 0.936 A 0.08 0.064 0 0 1 0.92 1 L 0.08 1 A 0.08 0.064 0 0 1 0 0.936 L 0 0.55 A 0.06 0.048 0 0 0 0 0.45 L 0 0.064 A 0.08 0.064 0 0 1 0.08 0 Z"
          fill="none"
          stroke={feature.accent}
          strokeWidth="1.5"
          vectorEffect="non-scaling-stroke"
          className="opacity-70"
        />
        <path 
          d="M 0.08,0 L 0.92,0 A 0.08 0.064 0 0 1 1 0.064 L 1 0.45 A 0.06 0.048 0 0 0 1 0.55 L 1 0.936 A 0.08 0.064 0 0 1 0.92 1 L 0.08 1 A 0.08 0.064 0 0 1 0 0.936 L 0 0.55 A 0.06 0.048 0 0 0 0 0.45 L 0 0.064 A 0.08 0.064 0 0 1 0.08 0 Z"
          fill="none"
          stroke={`url(#foil-gradient-${index})`}
          strokeWidth="3"
          vectorEffect="non-scaling-stroke"
          className="opacity-80"
          style={{ mixBlendMode: 'screen' }}
        />
      </svg>
    </>
  )
}
"""

# Now replace FeatureCard
new_feature_card = """function FeatureCard({ feature, index, activeIndex }: { feature: typeof FEATURES[0]; index: number; activeIndex: number }) {
  const reduced = useReducedMotion()
  const isActive = index === activeIndex
  const isPast = index < activeIndex
  const state = isActive ? 'active' : isPast ? 'inactiveTop' : 'inactiveBottom'

  return (
    <motion.div
      className="absolute w-80 md:w-96 h-[480px] flex flex-col justify-between"
      style={{
        transformOrigin: 'center center',
        filter: 'drop-shadow(0 30px 40px rgba(0,0,0,0.6))'
      }}
      variants={cardVariants}
      initial={false}
      animate={reduced ? { opacity: isActive ? 1 : 0, y: isActive ? 0 : isPast ? -40 : 40 } : state}
      transition={reduced ? { duration: 0.4 } : undefined}
    >
      <PhysicalTicketContent feature={feature} index={index} />
    </motion.div>
  )
}"""

# For FeatureCard we regex everything from `function FeatureCard` to the closing `  )\n}\n\nfunction MobileCarousel`
import re
content = re.sub(r'function FeatureCard.*?^\}\n\nfunction MobileCarousel', inner_ticket + '\n' + new_feature_card + '\n\nfunction MobileCarousel', content, flags=re.MULTILINE|re.DOTALL)

# For MobileCarousel we regex everything inside `className="w-72 h-[420px]...` motion.div up to `</motion.div>`
mobile_pattern = r'(<motion\.div[^>]*className="w-72 h-\[420px\][^>]*>).*?(</motion\.div>)'
mobile_replacement = r'''\1
              <PhysicalTicketContent feature={feature} index={i} />
            \2'''
content = re.sub(mobile_pattern, mobile_replacement, content, flags=re.DOTALL)

# For MobileCarousel we also need to change the style to filter: drop-shadow instead of background, border
# Let's just fix the motion.div opening tag for MobileCarousel manually
mobile_opening = """<motion.div
              className="w-72 h-[420px] flex flex-col justify-between relative"
              style={{
                transformOrigin: 'bottom center',
                filter: 'drop-shadow(0 20px 30px rgba(0,0,0,0.5))'
              }}
              {...(reduced ? {} : {"""
content = re.sub(r'<motion\.div\s+className="w-72 h-\[420px\][^>]*style=\{\{[^}]*\}\}\s+\{\.\.\.\(reduced \? \{\} : \{', mobile_opening, content, flags=re.DOTALL)

# For DesktopDeck (reduced motion)
# we need to replace the `rounded-2xl` div inside `FEATURES.map`
desktop_reduced_pattern = r'(<div\s+key={feature\.tag}\s+className=")rounded-2xl p-8 flex flex-col justify-between relative overflow-hidden(".*?style=\{\{[^}]*\}\}\s+>).*?(</div>\s+\)\))'
# Wait, DesktopDeck has a mapped div
def replace_desktop(m):
    return f'''<div
            key={{feature.tag}}
            className="flex flex-col justify-between relative h-[480px]"
            style={{{{
              filter: 'drop-shadow(0 30px 40px rgba(0,0,0,0.6))'
            }}}}
          >
            <PhysicalTicketContent feature={{feature}} index={{i}} />
          </div>
        ))'''
# But the map uses `(feature) =>` so index is not passed. We must change it to `(feature, i) =>`
content = content.replace('{FEATURES.map((feature) => (', '{FEATURES.map((feature, i) => (')
content = re.sub(r'<div\s+key=\{feature\.tag\}\s+className="rounded-2xl.*?</div>\s+\)\)', replace_desktop, content, flags=re.DOTALL)

with open("C:/DevTools/projects/pickd/pickd-web/src/components/FeatureShowcase.tsx", "w", encoding="utf-8") as f:
    f.write(content)
print("Done!")
