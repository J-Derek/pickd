function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

export interface MoviePoster {
  id: number;
}

// Curated TMDB Movie IDs
const MOVIE_IDS = [
  27205,   // Inception
  157336,  // Interstellar
  438631,  // Dune
  155,     // The Dark Knight
  872585,  // Oppenheimer
  299534,  // Avengers Endgame
  278,     // The Shawshank Redemption
  361743,  // Top Gun: Maverick
  76600,   // Avatar: The Way of Water
  634649,  // Spider-Man: No Way Home
  414906,  // The Batman
  335984,  // Blade Runner 2049
  76341,   // Mad Max: Fury Road
  496243,  // Parasite
  603692,  // John Wick 4
  466420,  // Killers of the Flower Moon
  346698,  // Barbie
  545611,  // Everything Everywhere All at Once
  661374,  // Glass Onion
  329865,  // Arrival
  264660,  // Ex Machina
  453395,  // Doctor Strange MoM
  762504,  // Nope
  614934,  // Elvis
  550,     // Fight Club
  122,     // LOTR: Return of the King
  505642,  // Black Panther: Wakanda Forever
];

export function useTrendingMovies() {
  const posters: MoviePoster[] = MOVIE_IDS.map((id) => ({ id }));

  // Split into rows, cycling if needed
  const rows = chunk([...posters, ...posters], 9);
  return { posters, rows };
}
