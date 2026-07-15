import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Mood entity — maps user emotion to TMDB genre IDs and search keywords.
/// Config lives here as per CONTEXT.md (mood_config.dart).
class Mood {
  final String id;
  final String label;
  final IconData icon;
  final String hint;
  final List<int> genreIds;
  final List<String> keywords;
  final Color accentColor;

  const Mood({
    required this.id,
    required this.label,
    required this.icon,
    required this.hint,
    required this.genreIds,
    this.keywords = const [],
    required this.accentColor,
  });
}

class GenreItem {
  final int id;
  final String label;
  final IconData icon;
  final Color accentColor;

  const GenreItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
  });
}

const List<GenreItem> kGenres = [
  GenreItem(id: 28, label: 'Action', icon: LucideIcons.swords, accentColor: Color(0xFFFF9544)),
  GenreItem(id: 12, label: 'Adventure', icon: LucideIcons.compass, accentColor: Color(0xFFFFC947)),
  GenreItem(id: 16, label: 'Animation', icon: LucideIcons.sparkles, accentColor: Color(0xFFE87EAD)),
  GenreItem(id: 35, label: 'Comedy', icon: LucideIcons.smile, accentColor: Color(0xFFFFC947)),
  GenreItem(id: 80, label: 'Crime', icon: LucideIcons.shieldAlert, accentColor: Color(0xFFFF6B6B)),
  GenreItem(id: 99, label: 'Documentary', icon: LucideIcons.fileText, accentColor: Color(0xFF4CAF88)),
  GenreItem(id: 18, label: 'Drama', icon: LucideIcons.film, accentColor: Color(0xFFE87EAD)),
  GenreItem(id: 10751, label: 'Family', icon: LucideIcons.users, accentColor: Color(0xFF4CAF88)),
  GenreItem(id: 14, label: 'Fantasy', icon: LucideIcons.wand2, accentColor: Color(0xFF7B8FFF)),
  GenreItem(id: 27, label: 'Horror', icon: LucideIcons.ghost, accentColor: Color(0xFFFF6B6B)),
  GenreItem(id: 9648, label: 'Mystery', icon: LucideIcons.helpCircle, accentColor: Color(0xFF7B8FFF)),
  GenreItem(id: 10749, label: 'Romance', icon: LucideIcons.heart, accentColor: Color(0xFFE87EAD)),
  GenreItem(id: 878, label: 'Sci-Fi', icon: LucideIcons.rocket, accentColor: Color(0xFF7B8FFF)),
  GenreItem(id: 53, label: 'Thriller', icon: LucideIcons.eye, accentColor: Color(0xFFFF6B6B)),
];

/// All moods available in MVP, from CONTEXT.md mood table.
const List<Mood> kMoods = [
  Mood(
    id: 'fun',
    label: 'Fun & Silly',
    icon: LucideIcons.smile,
    hint: 'Comedy · Light · No-brainer',
    genreIds: [35],
    keywords: ['comedy', 'funny', 'feel good'],
    accentColor: Color(0xFFFFC947),
  ),
  Mood(
    id: 'edge',
    label: 'On the Edge',
    icon: LucideIcons.flame,
    hint: 'Thriller · Horror · Tense',
    genreIds: [53, 27],
    keywords: ['suspense', 'psychological', 'dark'],
    accentColor: Color(0xFFFF6B6B),
  ),
  Mood(
    id: 'emotional',
    label: 'Emotional',
    icon: LucideIcons.heart,
    hint: 'Drama · Romance · Feel-something',
    genreIds: [18, 10749],
    keywords: ['emotional', 'heartfelt', 'romance'],
    accentColor: Color(0xFFE87EAD),
  ),
  Mood(
    id: 'mindbend',
    label: 'Mind-Bending',
    icon: LucideIcons.brain,
    hint: 'Sci-Fi · Mystery · Think hard',
    genreIds: [878, 9648],
    keywords: ['mind bending', 'cerebral', 'twist'],
    accentColor: Color(0xFF7B8FFF),
  ),
  Mood(
    id: 'epic',
    label: 'Epic & Action',
    icon: LucideIcons.swords,
    hint: 'Action · Adventure · Hype',
    genreIds: [28, 12],
    keywords: ['action', 'epic', 'adventure'],
    accentColor: Color(0xFFFF9544),
  ),
  Mood(
    id: 'different',
    label: 'Something Different',
    icon: LucideIcons.globe,
    hint: 'Documentary · Foreign · Expand horizons',
    genreIds: [99, 10769],
    keywords: ['documentary', 'foreign', 'world cinema'],
    accentColor: Color(0xFF4CAF88),
  ),
];

/// Genre ID → label lookup for display in chips
const Map<int, String> kGenreLabels = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
  10769: 'Foreign',
};
