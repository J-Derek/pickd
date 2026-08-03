import type { ReactNode, MouseEvent } from "react"

interface GlassButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    React.AnchorHTMLAttributes<HTMLAnchorElement> {
  children: ReactNode

  href?: string

  onClick?: (e: any) => void

  size?: "sm" | "md" | "lg"

  className?: string
}

export default function GlassButton({
  children,

  href,

  onClick,

  size = "md",

  className = "",

  ...rest
}: GlassButtonProps) {
  const sizeClasses = {
    sm: "px-4 py-2 text-sm",

    md: "px-6 py-2.5 text-sm",

    lg: "px-8 py-4 text-base",
  }

  const base =
    "inline-flex items-center gap-2 rounded-xl font-medium text-white transition-all duration-200 " +
    "border border-white/10 backdrop-blur-sm " +
    "hover:border-[#6B4EFF]/60 hover:shadow-[0_0_24px_rgba(107,78,255,0.25)] " +
    "focus:outline-none focus:ring-2 focus:ring-[#6B4EFF]/50 focus:ring-offset-2 focus:ring-offset-[#0A0A0F] " +
    sizeClasses[size] +
    " " +
    className

  const style = {
    background:
      "linear-gradient(135deg, rgba(107,78,255,0.15) 0%, rgba(107,78,255,0.05) 100%)",
  }

  if (href) {
    return (
      <a href={href} className={base} style={style} {...rest}>
        {children}
      </a>
    )
  }

  return (
    <button onClick={onClick} className={base} style={style} {...rest}>
      {children}
    </button>
  )
}
