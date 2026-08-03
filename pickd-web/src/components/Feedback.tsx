import React, { useState } from "react"

import { useReveal } from "../hooks/useReveal"

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

interface FormState {
  name: string

  email: string

  category: string

  message: string
}

export default function Feedback() {
  const { ref, visible } = useReveal(0.08)

  const [form, setForm] = useState<FormState>({
    name: "",

    email: "",

    category: "feature",

    message: "",
  })

  const [errors, setErrors] = useState<Partial<FormState>>({})

  const [loading, setLoading] = useState(false)

  const [success, setSuccess] = useState(false)

  const validate = (): Partial<FormState> => {
    const e: Partial<FormState> = {}

    if (!form.name.trim()) e.name = "Name is required."

    if (!EMAIL_RE.test(form.email)) e.email = "Valid email required."

    if (!form.message.trim()) e.message = "Message is required."

    return e
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    const errs = validate()

    if (Object.keys(errs).length > 0) {
      setErrors(errs)

      return
    }

    setErrors({})

    setLoading(true)

    await new Promise((r) => setTimeout(r, 1500))

    setLoading(false)

    setSuccess(true)
  }

  const set =
    (field: keyof FormState) =>
    (
      e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>,
    ) => {
      setForm((prev) => ({ ...prev, [field]: e.target.value }))

      if (errors[field]) setErrors((prev) => ({ ...prev, [field]: undefined }))
    }

  const fieldBorder = (field: keyof FormState) =>
    errors[field] ? "var(--color-pink)" : "var(--color-border)"

  const baseInputClass =
    "w-full rounded-xl px-4 py-3 text-sm text-foreground bg-elevated outline-none transition-colors duration-200 font-[inherit]"

  return (
    <section
      ref={ref}
      className={`reveal-hidden${visible ? " reveal-visible" : ""} py-28 px-6`}
    >
      <div className="max-w-[640px] mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h2
            className="font-black tracking-[-0.03em] mb-3"
            style={{ fontSize: "clamp(2rem, 4vw, 3rem)" }}
          >
            Got feedback?
          </h2>
          <p className="text-base text-secondary">
            Found a bug or have a feature idea? Derek reads every message.
          </p>
        </div>

        {success ? (
          <div
            aria-live="polite"
            className="text-center rounded-3xl border border-border py-16 px-10"
            style={{
              background: "rgba(19,19,26,0.8)",

              backdropFilter: "blur(24px)",

              WebkitBackdropFilter: "blur(24px)",
            }}
          >
            <div className="text-pink flex justify-center mb-6">
              <svg
                width="48"
                height="48"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <rect x="2" y="7" width="20" height="15" rx="2" ry="2"></rect>
                <polyline points="17 2 12 7 7 2"></polyline>
              </svg>
            </div>
            <h3 className="text-[22px] font-extrabold mb-[10px]">
              Message sent!
            </h3>
            <p className="text-secondary">
              {"Thanks for the feedback. Derek will read it over popcorn."}
            </p>
          </div>
        ) : (
          <form
            onSubmit={handleSubmit}
            noValidate
            className="relative overflow-hidden rounded-3xl border border-border p-10"
            style={{
              background: "rgba(19,19,26,0.8)",

              backdropFilter: "blur(24px)",

              WebkitBackdropFilter: "blur(24px)",
            }}
          >
            {/* Top highlight */}
            <div
              className="absolute top-0 left-0 right-0 h-px pointer-events-none"
              style={{
                background:
                  "linear-gradient(90deg, transparent, rgba(107,78,255,0.4), transparent)",
              }}
            />

            {/* Name + Email row */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-5">
              <div>
                <label
                  htmlFor="fb-name"
                  className="block text-[13px] font-semibold text-secondary mb-2"
                >
                  Name <span className="text-pink">*</span>
                </label>
                <input
                  id="fb-name"
                  type="text"
                  value={form.name}
                  onChange={set("name")}
                  placeholder="Your name"
                  className={baseInputClass}
                  style={{ border: `1px solid ${fieldBorder("name")}` }}
                  onFocus={(e) => {
                    if (!errors.name)
                      e.currentTarget.style.borderColor = "rgba(107,78,255,0.5)"
                  }}
                  onBlur={(e) => {
                    if (!errors.name)
                      e.currentTarget.style.borderColor = fieldBorder("name")
                  }}
                />
                {errors.name && (
                  <p
                    role="alert"
                    aria-live="polite"
                    className="mt-1 text-xs text-pink"
                  >
                    {errors.name}
                  </p>
                )}
              </div>

              <div>
                <label
                  htmlFor="fb-email"
                  className="block text-[13px] font-semibold text-secondary mb-2"
                >
                  Email <span className="text-pink">*</span>
                </label>
                <input
                  id="fb-email"
                  type="email"
                  value={form.email}
                  onChange={set("email")}
                  placeholder="your@email.com"
                  className={baseInputClass}
                  style={{ border: `1px solid ${fieldBorder("email")}` }}
                  onFocus={(e) => {
                    if (!errors.email)
                      e.currentTarget.style.borderColor = "rgba(107,78,255,0.5)"
                  }}
                  onBlur={(e) => {
                    if (!errors.email)
                      e.currentTarget.style.borderColor = fieldBorder("email")
                  }}
                />
                {errors.email && (
                  <p
                    role="alert"
                    aria-live="polite"
                    className="mt-1 text-xs text-pink"
                  >
                    {errors.email}
                  </p>
                )}
              </div>
            </div>

            {/* Category */}
            <div className="mb-5">
              <label
                htmlFor="fb-category"
                className="block text-[13px] font-semibold text-secondary mb-2"
              >
                Type
              </label>
              <select
                id="fb-category"
                value={form.category}
                onChange={set("category")}
                className="w-full rounded-xl text-sm text-foreground outline-none transition-colors duration-200 font-[inherit] cursor-pointer"
                style={{
                  border: `1px solid ${fieldBorder("category")}`,

                  appearance: "none",

                  WebkitAppearance: "none",

                  backgroundColor: "var(--color-elevated)",

                  backgroundImage:
                    "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236B6B80' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E\")",

                  backgroundRepeat: "no-repeat",

                  backgroundPosition: "right 16px center",

                  paddingTop: "12px",

                  paddingBottom: "12px",

                  paddingLeft: "16px",

                  paddingRight: "40px",
                }}
              >
                <option value="feature">Feature request</option>
                <option value="bug">Bug report</option>
                <option value="other">Other</option>
              </select>
            </div>

            {/* Message */}
            <div className="mb-7">
              <label
                htmlFor="fb-message"
                className="block text-[13px] font-semibold text-secondary mb-2"
              >
                Message <span className="text-pink">*</span>
              </label>
              <textarea
                id="fb-message"
                value={form.message}
                onChange={set("message")}
                placeholder="Tell Derek what's on your mind…"
                rows={5}
                className={baseInputClass}
                style={{
                  border: `1px solid ${fieldBorder("message")}`,

                  resize: "vertical",

                  minHeight: "120px",
                }}
                onFocus={(e) => {
                  if (!errors.message)
                    e.currentTarget.style.borderColor = "rgba(107,78,255,0.5)"
                }}
                onBlur={(e) => {
                  if (!errors.message)
                    e.currentTarget.style.borderColor = fieldBorder("message")
                }}
              />
              {errors.message && (
                <p
                  role="alert"
                  aria-live="polite"
                  className="mt-1 text-xs text-pink"
                >
                  {errors.message}
                </p>
              )}
            </div>

            {/* Submit */}
            <button
              type="submit"
              disabled={loading}
              className="btn-indigo w-full py-[15px] px-6 rounded-[14px] font-bold text-[15px] border-0 flex items-center justify-center gap-2 font-[inherit]"
              style={{
                cursor: loading ? "not-allowed" : "pointer",

                opacity: loading ? 0.65 : 1,
              }}
            >
              {loading ? (
                <>
                  <LoadingSpinner />
                  Sending…
                </>
              ) : (
                "Send to Derek"
              )}
            </button>
          </form>
        )}
      </div>
    </section>
  )
}

function LoadingSpinner() {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.5"
      strokeLinecap="round"
      style={{ animation: "spin 0.8s linear infinite" }}
    >
      <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
    </svg>
  )
}
