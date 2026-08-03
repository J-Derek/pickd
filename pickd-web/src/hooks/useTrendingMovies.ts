import { useState, useEffect } from "react"

export interface MovieItem {
  id: number
  title: string
  posterPath: string
  voteAverage: number
  releaseDate: string
}

const FALLBACK_MOVIES: MovieItem[] = [
  {
    id: 693134,
    title: "Dune: Part Two",
    posterPath:
      "https://image.tmdb.org/t/p/w342/1pdfLPoLStmCGGl1v3p9vAYVzE7.jpg",
    voteAverage: 8.3,
    releaseDate: "2024-02-27",
  },
  {
    id: 157336,
    title: "Interstellar",
    posterPath:
      "https://image.tmdb.org/t/p/w342/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
    voteAverage: 8.4,
    releaseDate: "2014-11-05",
  },
  {
    id: 872585,
    title: "Oppenheimer",
    posterPath:
      "https://image.tmdb.org/t/p/w342/8Gxv8gSFCU0XGDykEGvCiofl1Kf.jpg",
    voteAverage: 8.1,
    releaseDate: "2023-07-19",
  },
  {
    id: 335984,
    title: "Blade Runner 2049",
    posterPath:
      "https://image.tmdb.org/t/p/w342/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg",
    voteAverage: 7.9,
    releaseDate: "2017-10-04",
  },
  {
    id: 27205,
    title: "Inception",
    posterPath:
      "https://image.tmdb.org/t/p/w342/oYuLEydvwzK8zahB12yF22074d.jpg",
    voteAverage: 8.4,
    releaseDate: "2010-07-15",
  },
]

const TMDB_READ_TOKEN =
  "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ODEwZWZkZTMwZGE0ZGMyNTZjNjI1MmVhY2NjOTc4MSIsIm5iZiI6MTc3NDA5NzQ3NC4wODYwMDAyLCJzdWIiOiI2OWJlOTQ0MjQ3MjI1NzFhYzkwZTJhOTYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.xUFgUaLVe6oasd764gAOIFIYIpE_Vb1E-FP5YOY9H2c"

export function useTrendingMovies() {
  const [movies, setMovies] = useState<MovieItem[]>(FALLBACK_MOVIES)
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let isMounted = true

    async function fetchMovies() {
      try {
        const response = await fetch(
          "https://api.themoviedb.org/3/trending/movie/day",
          {
            headers: {
              Authorization: `Bearer ${TMDB_READ_TOKEN}`,
              "Content-Type": "application/json",
            },
          },
        )

        if (!response.ok) {
          throw new Error(`Failed to fetch trending movies: ${response.status}`)
        }

        const data = await response.json()
        if (isMounted && data.results) {
          const filtered: MovieItem[] = data.results
            .filter((m: any) => m.poster_path && (m.vote_count ?? 0) >= 30)
            .map((m: any) => ({
              id: m.id,
              title: m.title || m.original_title,
              posterPath: `https://image.tmdb.org/t/p/w342${m.poster_path}`,
              voteAverage: Number((m.vote_average || 0).toFixed(1)),
              releaseDate: m.release_date || "",
            }))
            .slice(0, 18)

          if (filtered.length > 0) {
            setMovies(filtered)
          }
        }
      } catch (err: any) {
        if (isMounted) {
          setError(err.message || "Error fetching trending movies")
        }
      } finally {
        if (isMounted) {
          setLoading(false)
        }
      }
    }

    fetchMovies()

    return () => {
      isMounted = false
    }
  }, [])

  return { movies, loading, error }
}
