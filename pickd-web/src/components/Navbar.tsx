import GlassButton from './GlassButton'

export default function Navbar() {
  return (
    <nav
      className="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-6 md:px-10 h-16"
      style={{
        background: 'rgba(10, 10, 15, 0.7)',
        backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        borderBottom: '1px solid rgba(255,255,255,0.06)',
      }}
    >
      {/* Logo */}
      <a href="#" className="flex items-center gap-3 focus:outline-none focus:ring-2 focus:ring-[#6B4EFF]/50 rounded-md" aria-label="Pickd home">
        <img
          src="/logo.jpg"
          alt="Pickd"
          className="w-8 h-8 rounded-lg object-cover shadow-[0_0_10px_rgba(107,78,255,0.3)]"
        />
        <span
          className="text-lg font-semibold tracking-tight text-white"
          style={{ fontFamily: 'var(--font-display)' }}
        >
          Pickd
        </span>
      </a>

      {/* Nav links + CTA */}
      <div className="flex items-center gap-6">
        <a
          href="#how-it-works"
          className="hidden md:block text-sm text-white/50 hover:text-white/90 transition-colors duration-150"
        >
          How it works
        </a>
        <a
          href="#features"
          className="hidden md:block text-sm text-white/50 hover:text-white/90 transition-colors duration-150"
        >
          Features
        </a>
        <a
          href="https://github.com/J-Derek/Pickd/issues"
          target="_blank"
          rel="noopener noreferrer"
          className="hidden md:block text-sm text-white/50 hover:text-white/90 transition-colors duration-150"
        >
          Report a bug
        </a>
        <a
          href="https://github.com/J-Derek/Pickd"
          target="_blank"
          rel="noopener noreferrer"
          className="text-white/50 hover:text-white/90 transition-colors duration-150 flex items-center"
          aria-label="GitHub Repository"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.44 9.8 8.21 11.39.6.11.82-.26.82-.58 0-.28-.01-1.03-.01-2.02-3.34.73-4.04-1.61-4.04-1.61-.54-1.39-1.33-1.76-1.33-1.76-1.09-.74.08-.73.08-.73 1.2.08 1.84 1.24 1.84 1.24 1.07 1.83 2.8 1.3 3.49 1 .11-.78.42-1.3.76-1.6-2.67-.3-5.47-1.33-5.47-5.93 0-1.31.47-2.38 1.24-3.22-.12-.3-.54-1.52.12-3.17 0 0 1.01-.32 3.3 1.23.96-.27 1.98-.4 3-.4s2.04.14 3 .4c2.29-1.55 3.3-1.23 3.3-1.23.66 1.65.24 2.87.12 3.17.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.63-5.48 5.93.43.37.81 1.1.81 2.22 0 1.6-.01 2.9-.01 3.29 0 .32.22.69.82.57C20.57 21.8 24 17.3 24 12c0-6.63-5.37-12-12-12z" />
          </svg>
        </a>
        <GlassButton href="https://github.com/J-Derek/Pickd/releases" size="sm" target="_blank" rel="noopener noreferrer">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="7 10 12 15 17 10" />
            <line x1="12" y1="15" x2="12" y2="3" />
          </svg>
          Download APK
        </GlassButton>
      </div>
    </nav>
  )
}
