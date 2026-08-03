const prefersReducedMotion =
  typeof window !== "undefined" &&
  window.matchMedia("(prefers-reduced-motion: reduce)").matches

export function useReducedMotion(): boolean {
  return prefersReducedMotion
}
