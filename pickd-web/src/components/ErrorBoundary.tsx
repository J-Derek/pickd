import React, { Component, ErrorInfo, ReactNode } from "react"

interface Props {
  children?: ReactNode
}

interface State {
  hasError: boolean

  errorMsg: string
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,

    errorMsg: "",
  }

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, errorMsg: error.message }
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Uncaught error:", error, errorInfo)
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div
          style={{
            padding: "40px",
            background: "red",
            color: "white",
            fontSize: "20px",
          }}
        >
          <h1>React Crashed!</h1>
          <p>{this.state.errorMsg}</p>
        </div>
      )
    }

    return this.props.children
  }
}
