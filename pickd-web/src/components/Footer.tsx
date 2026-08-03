import React from "react"

export default function Footer() {
  return (
    <footer className="px-6 pt-10 pb-12 border-t border-border">
      <div className="max-w-[1152px] mx-auto">
        <div className="flex flex-col items-center gap-6">
          {/* Brand */}
          <span className="gradient-text text-[22px] font-black tracking-tight">
            Pickd
          </span>

          {/* Nav links */}
          <nav className="flex items-center flex-wrap justify-center gap-x-6 gap-y-2 text-sm text-muted">
            <FooterLink href="https://github.com/J-Derek/Pickd" external>
              <GitHubIcon />
              GitHub
            </FooterLink>
            <FooterLink
              href="https://github.com/J-Derek/Pickd/releases"
              external
            >
              Releases
            </FooterLink>
            <FooterLink href="https://github.com/J-Derek/Pickd/issues" external>
              Report a bug
            </FooterLink>
          </nav>

          {/* Copyright */}
          <p className="text-[13px] text-muted">
            © 2026 Pickd. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}

interface FooterLinkProps {
  href: string

  external?: boolean

  children: React.ReactNode

  "aria-label"?: string
}

function FooterLink({
  href,
  external,
  children,
  "aria-label": ariaLabel,
}: FooterLinkProps) {
  return (
    <a
      href={href}
      target={external ? "_blank" : undefined}
      rel={external ? "noopener noreferrer" : undefined}
      aria-label={ariaLabel}
      className="inline-flex items-center gap-1.5 text-muted no-underline hover:text-foreground transition-colors duration-200"
    >
      {children}
    </a>
  )
}

function GitHubIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.44 9.8 8.21 11.39.6.11.82-.26.82-.58 0-.28-.01-1.03-.01-2.02-3.34.73-4.04-1.61-4.04-1.61-.54-1.39-1.33-1.76-1.33-1.76-1.09-.74.08-.73.08-.73 1.2.08 1.84 1.24 1.84 1.24 1.07 1.83 2.8 1.3 3.49 1 .11-.78.42-1.3.76-1.6-2.67-.3-5.47-1.33-5.47-5.93 0-1.31.47-2.38 1.24-3.22-.12-.3-.54-1.52.12-3.17 0 0 1.01-.32 3.3 1.23.96-.27 1.98-.4 3-.4s2.04.14 3 .4c2.29-1.55 3.3-1.23 3.3-1.23.66 1.65.24 2.87.12 3.17.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.63-5.48 5.93.43.37.81 1.1.81 2.22 0 1.6-.01 2.9-.01 3.29 0 .32.22.69.82.57C20.57 21.8 24 17.3 24 12c0-6.63-5.37-12-12-12z" />
    </svg>
  )
}
