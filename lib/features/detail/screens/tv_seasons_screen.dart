import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/models/tv_model.dart';
import '../../../core/models/tv_season_model.dart';
import '../../../core/services/tmdb_service.dart';

class TvSeasonsScreen extends StatefulWidget {
  final int seriesId;
  final String? seriesName;

  const TvSeasonsScreen({
    super.key,
    required this.seriesId,
    this.seriesName,
  });

  @override
  State<TvSeasonsScreen> createState() => _TvSeasonsScreenState();
}

class _TvSeasonsScreenState extends State<TvSeasonsScreen> {
  TvModel? _seriesDetails;
  bool _loadingSeries = true;

  int _selectedSeason = 1;
  TvSeasonModel? _seasonDetails;
  bool _loadingSeason = true;

  @override
  void initState() {
    super.initState();
    _loadSeriesInfo();
  }

  Future<void> _loadSeriesInfo() async {
    final details = await TmdbService.getTvDetails(widget.seriesId);
    if (mounted) {
      setState(() {
        _seriesDetails = details;
        _loadingSeries = false;
      });
      _loadSeason(_selectedSeason);
    }
  }

  Future<void> _loadSeason(int seasonNum) async {
    setState(() {
      _selectedSeason = seasonNum;
      _loadingSeason = true;
    });

    final seasonData = await TmdbService.getTvSeasonDetails(
      widget.seriesId,
      seasonNum,
    );

    if (mounted) {
      setState(() {
        _seasonDetails = seasonData;
        _loadingSeason = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _seriesDetails?.name ?? widget.seriesName ?? 'TV Guide';
    final totalSeasons = _seriesDetails?.numberOfSeasons ?? 1;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: _loadingSeries
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentPrimary),
            )
          : Column(
              children: [
                // Season Selector Tab Bar
                Container(
                  height: 52,
                  color: AppTheme.bgSurface,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: totalSeasons,
                    itemBuilder: (context, index) {
                      final seasonNum = index + 1;
                      final isSelected = seasonNum == _selectedSeason;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            'Season $seasonNum',
                            style: TextStyle(
                              fontFamily: 'SFProText',
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.textInverse : AppTheme.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.accentPrimary,
                          backgroundColor: AppTheme.bgMuted,
                          side: BorderSide.none,
                          onSelected: (_) => _loadSeason(seasonNum),
                        ),
                      );
                    },
                  ),
                ),

                // Season Details & Episode List
                Expanded(
                  child: _loadingSeason
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.accentPrimary),
                        )
                      : _seasonDetails == null || _seasonDetails!.episodes.isEmpty
                          ? const Center(
                              child: Text(
                                'No episode details available for this season.',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _seasonDetails!.episodes.length + 1,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Header with Season Overview
                                  return _buildSeasonHeader(_seasonDetails!);
                                }
                                final ep = _seasonDetails!.episodes[index - 1];
                                return _buildEpisodeTile(ep);
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildSeasonHeader(TvSeasonModel season) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (season.posterPath != null && season.posterPath!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: season.posterUrl,
                width: 70,
                height: 105,
                fit: BoxFit.cover,
              ),
            ),
          if (season.posterPath != null && season.posterPath!.isNotEmpty)
            const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.name.isNotEmpty ? season.name : 'Season ${season.seasonNumber}',
                  style: const TextStyle(
                    fontFamily: 'SFProText',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${season.episodes.length} Episodes${season.airDate != null ? ' • ${season.airDate!.split('-').first}' : ''}',
                  style: const TextStyle(
                    fontFamily: 'SFProText',
                    fontSize: 13,
                    color: AppTheme.accentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (season.overview.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    season.overview,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeTile(TvEpisodeModel ep) {
    final epNum = ep.episodeNumber.toString().padLeft(2, '0');
    final runtimeStr = ep.runtime != null && ep.runtime! > 0 ? '${ep.runtime} min' : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Episode Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ep.stillPath != null && ep.stillPath!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ep.stillUrl,
                            width: 100,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 60,
                            color: AppTheme.bgMuted,
                            child: const Icon(LucideIcons.tv, color: AppTheme.textMuted, size: 24),
                          ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'E$epNum',
                        style: const TextStyle(
                          fontFamily: 'SFProText',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ep.name,
                      style: const TextStyle(
                        fontFamily: 'SFProText',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (runtimeStr.isNotEmpty)
                          Text(
                            runtimeStr,
                            style: const TextStyle(
                              fontFamily: 'SFProText',
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        if (runtimeStr.isNotEmpty && ep.voteAverage > 0)
                          const Text(' • ', style: TextStyle(color: AppTheme.textMuted)),
                        if (ep.voteAverage > 0) ...[
                          const Icon(Icons.star_rounded, color: AppTheme.gemsColor, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            ep.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'SFProDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ep.overview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ep.overview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'SFProText',
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
