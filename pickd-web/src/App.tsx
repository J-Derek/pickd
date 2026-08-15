import { useEffect, useRef, useState } from "react";
import Navbar from "./components/Navbar";
import Hero from "./components/Hero";
import ProblemStatement from "./components/ProblemStatement";
import Scene3 from "./components/Scene3";
import Scene4 from "./components/Scene4";
import Scene5 from "./components/Scene5";
import NotFound from "./components/NotFound";

function useSpotlight(containerRef: React.RefObject<HTMLDivElement | null>) {
  useEffect(() => {
    if (typeof window === "undefined") return;
    if ("ontouchstart" in window) return;
    let rafId = 0;
    const handle = (e: MouseEvent) => {
      if (rafId) return;
      rafId = requestAnimationFrame(() => {
        containerRef.current?.style.setProperty("--mouse-x", `${e.clientX}px`);
        containerRef.current?.style.setProperty("--mouse-y", `${e.clientY}px`);
        rafId = 0;
      });
    };
    window.addEventListener("mousemove", handle, { passive: true });
    return () => { window.removeEventListener("mousemove", handle); cancelAnimationFrame(rafId); };
  }, [containerRef]);
}

export default function App() {
  const containerRef = useRef<HTMLDivElement>(null);
  useSpotlight(containerRef);

  const [path, setPath] = useState(() => (typeof window !== "undefined" ? window.location.pathname : "/"));

  useEffect(() => {
    const handlePop = () => setPath(window.location.pathname);
    window.addEventListener("popstate", handlePop);
    return () => window.removeEventListener("popstate", handlePop);
  }, []);

  const isHome = path === "/" || path === "" || path === "/index.html";

  if (!isHome) {
    return <NotFound />;
  }

  return (
    <div ref={containerRef} className="relative min-h-screen" style={{ background: "var(--bg)", color: "#fff" }}>
      <div className="pointer-events-none fixed inset-0 z-0" style={{ background: "radial-gradient(600px circle at var(--mouse-x,50%) var(--mouse-y,50%), rgba(107,78,255,0.04), transparent 70%)" }} />
      <div className="pointer-events-none fixed inset-0 z-0" style={{ background: "radial-gradient(300px circle at var(--mouse-x,50%) var(--mouse-y,50%), rgba(107,78,255,0.05), transparent 60%)" }} />
      <Navbar />
      <main className="relative z-10">
        <Hero />
        <ProblemStatement />
        <Scene3 />
        <Scene4 />
        <Scene5 />
      </main>
    </div>
  );
}
