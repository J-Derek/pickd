import { useState, useEffect } from "react";

const BREAKPOINT = 768;

export function useIsMobile() {
  const [mobile, setMobile] = useState(
    () => typeof window !== "undefined" && window.innerWidth < BREAKPOINT
  );
  useEffect(() => {
    const mq = window.matchMedia(`(max-width: ${BREAKPOINT - 1}px)`);
    const handler = (e: MediaQueryListEvent) => setMobile(e.matches);
    setMobile(mq.matches);
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, []);
  return mobile;
}
