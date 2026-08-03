import { useEffect, useRef, useState } from "react"

export function useReveal(threshold = 0.1) {
  const ref = useRef<HTMLDivElement>(null)

  const [visible, setVisible] = useState(false)

  useEffect(() => {
    const el = ref.current

    if (!el) return

    const reduced = window.matchMedia(
      "(prefers-reduced-motion: reduce)",
    ).matches

    if (reduced) {
      setVisible(true)

      return
    }

    const obs = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setVisible(true)

          obs.disconnect()
        }
      },

      { threshold },
    )

    obs.observe(el)

    return () => obs.disconnect()
  }, [threshold])

  return { ref, visible }
}
