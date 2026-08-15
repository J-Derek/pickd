import React, { useState, useEffect } from 'react';

const BASE_URL = "https://image.tmdb.org/t/p/w500";
const API_KEY = import.meta.env.VITE_TMDB_TOKEN || import.meta.env.VITE_TMDB_API_KEY || import.meta.env.VITE_TMDB_READ_TOKEN || "";

// Curated static poster paths for zero-latency, rate-limit-proof loading
const STATIC_POSTERS: Record<number, string> = {
  122: "/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg",    // The Lord of the Rings: The Return of the King
  129: "/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg",    // Spirited Away
  155: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",    // The Dark Knight
  278: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",    // The Shawshank Redemption
  550: "/jSziioSwPVrOy9Yow3XhWIBDjq1.jpg",    // Fight Club
  27205: "/xlaY2zyzMfkhk0HSC5VUwzoZPU1.jpg",  // Inception
  76341: "/ulcAi4dKpAjHwYGS08vNyx9H6I9.jpg",  // Mad Max: Fury Road
  76600: "/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg",  // Avatar: The Way of Water
  157336: "/yQvGrMoipbRoddT0ZR8tPoR7NfX.jpg", // Interstellar
  264660: "/dmJW8IAKHKxFNiUnoDR7JfsK7Rp.jpg", // Ex Machina
  299534: "/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg", // Avengers: Endgame
  324857: "/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg", // Spider-Man: Into the Spider-Verse
  329865: "/x2FJsf1ElAgr63Y3PNPtJrcmpoe.jpg", // Arrival
  335984: "/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg", // Blade Runner 2049
  346698: "/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg", // Barbie
  361743: "/n0YuM4f5lvGAP6MAW2kBIzugXnc.jpg", // Top Gun: Maverick
  414906: "/74xTEgt7R36Fpooo50r9T25onhq.jpg", // The Batman
  438631: "/v1tRXZ4JtD2Iv6fjkPvT4GiwslV.jpg", // Dune
  453395: "/ddJcSKbcp4rKZTmuyWaMhuwcfMz.jpg", // Doctor Strange in the Multiverse of Madness
  466420: "/dB6Krk806zeqd0YNp2ngQ9zXteH.jpg", // Killers of the Flower Moon
  496243: "/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg", // Parasite
  505642: "/sv1xJUazXeYqALzczSZ3O6nkH75.jpg", // Black Panther: Wakanda Forever
  545611: "/u68AjlvlutfEIcpmbYpKcdi09ut.jpg", // Everything Everywhere All at Once
  603692: "/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg", // John Wick: Chapter 4
  614934: "/qBOKWqAFbveZ4ryjJJwbie6tXkQ.jpg", // Elvis
  634649: "/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg", // Spider-Man: No Way Home
  661374: "/vDGr1YdrlfbU9wxTOdpf3zChmv9.jpg", // Glass Onion: A Knives Out Mystery
  762504: "/AcKVlWaNVVVFQwro3nLXqPljcYA.jpg", // Nope
  872585: "/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg", // Oppenheimer
};

// In-memory cache pre-populated with static posters
const posterCache: Record<number, string> = Object.entries(STATIC_POSTERS).reduce(
  (acc, [id, path]) => ({ ...acc, [Number(id)]: `${BASE_URL}${path}` }),
  {}
);

// In-flight promise map to deduplicate concurrent requests for the same movie ID
const inFlightRequests: Record<number, Promise<string | null>> = {};

interface TMDBPosterProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  movieId: number;
  fallbackSrc?: string;
}

export const TMDBPoster: React.FC<TMDBPosterProps> = ({ 
  movieId, 
  fallbackSrc = "https://placehold.co/500x750/111827/4b5563?text=Poster+Not+Found", 
  className,
  ...props 
}) => {
  const [src, setSrc] = useState<string | null>(posterCache[movieId] || null);
  const [error, setError] = useState<boolean>(false);

  useEffect(() => {
    let isMounted = true;
    
    if (posterCache[movieId]) {
      setSrc(posterCache[movieId]);
      return;
    }

    if (!API_KEY) {
      setError(true);
      return;
    }

    // Reuse in-flight promise if another component already triggered a fetch for this ID
    if (!inFlightRequests[movieId]) {
      const isV4Token = API_KEY.length > 40;
      const fetchOptions = isV4Token 
        ? { headers: { Authorization: `Bearer ${API_KEY}`, accept: 'application/json' } } 
        : {};
      const url = isV4Token 
        ? `https://api.themoviedb.org/3/movie/${movieId}` 
        : `https://api.themoviedb.org/3/movie/${movieId}?api_key=${API_KEY}`;

      inFlightRequests[movieId] = fetch(url, fetchOptions)
        .then(res => {
          if (!res.ok) throw new Error("TMDB fetch failed");
          return res.json();
        })
        .then(data => {
          if (data.poster_path) {
            const resolvedUrl = `${BASE_URL}${data.poster_path}`;
            posterCache[movieId] = resolvedUrl;
            return resolvedUrl;
          }
          return null;
        })
        .catch(err => {
          console.error(`Failed to fetch poster for movie ${movieId}:`, err);
          return null;
        })
        .finally(() => {
          delete inFlightRequests[movieId];
        });
    }

    inFlightRequests[movieId].then(resolvedUrl => {
      if (!isMounted) return;
      if (resolvedUrl) {
        setSrc(resolvedUrl);
      } else {
        setError(true);
      }
    });

    return () => {
      isMounted = false;
    };
  }, [movieId]);

  const handleError = (e: React.SyntheticEvent<HTMLImageElement, Event>) => {
    setError(true);
    if (props.onError) props.onError(e);
  };

  if (error || !src) {
    return (
      <img 
        loading="lazy"
        decoding="async"
        {...props} 
        src={fallbackSrc} 
        className={`${className || ''} ${!src ? 'animate-pulse' : ''}`}
        alt={props.alt || "Movie poster"} 
      />
    );
  }

  return (
    <img 
      loading="lazy"
      decoding="async"
      {...props} 
      src={src} 
      onError={handleError}
      className={className} 
    />
  );
};
