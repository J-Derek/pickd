import { useState } from "react";
import GlassButton from "./GlassButton";

const NAV_LINKS = [
  { label: "How it works", href: "#how-it-works" },
  { label: "Features",     href: "#features" },
  { label: "Report a bug", href: "https://github.com/J-Derek/Pickd/issues" },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    if (href.startsWith("#")) {
      e.preventDefault();
      const targetId = href.substring(1);
      const el = document.getElementById(targetId);
      if (el) {
        el.scrollIntoView({ behavior: "smooth" });
      }
    }
  };

  return (
    <>
      <nav
        className="fixed top-0 left-0 right-0 z-50 h-16 flex items-center px-5 md:px-10"
        style={{
          background: "var(--nav-bg)",
          backdropFilter: "blur(20px)",
          WebkitBackdropFilter: "blur(20px)",
          borderBottom: "1px solid var(--border)",
        }}
      >
        {/* Logo */}
        <a href="#" className="flex items-center gap-2.5 flex-shrink-0">
          <img src="/logo.jpg" alt="Pickd" className="w-8 h-8 rounded-lg object-cover"
               style={{ boxShadow: "0 0 10px var(--indigo-glow)" }}
               onError={e => { e.currentTarget.style.display = "none"; }} />
          <span className="font-bold text-base text-white tracking-tight"
                style={{ fontFamily: "var(--font-display)", letterSpacing: "-0.02em" }}>
            Pickd
          </span>
        </a>

        {/* Desktop links */}
        <div className="hidden md:flex items-center gap-8 ml-10">
          {NAV_LINKS.map(l => (
            <a
              key={l.label}
              href={l.href}
              target={l.href.startsWith("http") ? "_blank" : undefined}
              rel={l.href.startsWith("http") ? "noopener noreferrer" : undefined}
              onClick={(e) => handleNavClick(e, l.href)}
              className="text-sm transition-colors duration-200 text-white/45 hover:text-white"
            >
              {l.label}
            </a>
          ))}
        </div>

        {/* Right */}
        <div className="ml-auto flex items-center gap-2 md:gap-3">
          <a
            href="https://github.com/J-Derek/Pickd"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="GitHub"
            className="hidden sm:flex items-center justify-center w-9 h-9 rounded-full transition-colors duration-200 text-white/45 hover:text-white"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
            </svg>
          </a>

          <GlassButton href="https://github.com/J-Derek/Pickd/releases/download/v1.0.0/app-release.apk">Download APK</GlassButton>

          {/* Hamburger — mobile only */}
          <button className="md:hidden flex items-center justify-center w-9 h-9 rounded-full ml-1"
                  style={{ color: "var(--text-60)" }}
                  onClick={() => setOpen(o => !o)} aria-label="Toggle menu">
            {open
              ? <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
              : <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
            }
          </button>
        </div>
      </nav>

      {/* Mobile drawer */}
      {open && (
        <div className="fixed top-16 left-0 right-0 z-40 md:hidden flex flex-col py-3 px-6"
             style={{ background: "var(--nav-bg)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)", borderBottom: "1px solid var(--border)" }}>
          {NAV_LINKS.map(l => (
            <a
              key={l.label}
              href={l.href}
              target={l.href.startsWith("http") ? "_blank" : undefined}
              rel={l.href.startsWith("http") ? "noopener noreferrer" : undefined}
              className="text-sm py-3 border-b"
              style={{ color: "var(--text-60)", borderColor: "var(--border)" }}
              onClick={(e) => {
                setOpen(false);
                handleNavClick(e, l.href);
              }}
            >
              {l.label}
            </a>
          ))}
          <a
            href="https://github.com/J-Derek/Pickd"
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm py-3 sm:hidden"
            style={{ color: "var(--text-60)" }}
            onClick={() => setOpen(false)}
          >
            GitHub
          </a>
        </div>
      )}
    </>
  );
}
