interface GlassButtonProps {
  href?: string;
  onClick?: () => void;
  children: React.ReactNode;
  className?: string;
}

export default function GlassButton({ href, onClick, children, className = "" }: GlassButtonProps) {
  const style: React.CSSProperties = {
    display: "inline-flex",
    alignItems: "center",
    gap: 8,
    height: 40,
    padding: "0 20px",
    borderRadius: 9999,
    fontSize: "0.8125rem",
    fontWeight: 600,
    letterSpacing: "0.06em",
    color: "#fff",
    backdropFilter: "blur(8px)",
    textDecoration: "none",
    whiteSpace: "nowrap",
    cursor: "pointer",
  };

  if (href) {
    return (
      <a href={href} style={style} className={`glass-button ${className}`}>
        {children}
      </a>
    );
  }

  return (
    <button onClick={onClick} style={style} className={`glass-button ${className}`}>
      {children}
    </button>
  );
}
