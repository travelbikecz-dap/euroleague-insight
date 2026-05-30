import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/player_experience.dart';
import '../services/player_experience_api_service.dart';
import '../services/player_stats_api_service.dart';
import '../theme/app_theme.dart';
import '../utils/player_bio_formatter.dart';
import '../widgets/player_avatar.dart';

class PlayerDetailScreen extends StatefulWidget {
  final List<Player> players;
  final int initialIndex;
  final String teamName;

  const PlayerDetailScreen({
    super.key,
    required this.players,
    required this.initialIndex,
    required this.teamName,
  });

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  static const _loopPages = 1000;

  late final PageController _pageController;
  final _statsService = PlayerStatsApiService();
  final _experienceService = PlayerExperienceApiService();
  final _statsFutures = <String, Future<PlayerSeasonStats?>>{};
  final _experienceFutures = <String, Future<PlayerEuroleagueExperience?>>{};

  @override
  void initState() {
    super.initState();
    final count = widget.players.length;
    _pageController = PageController(
      initialPage: count > 0
          ? _loopPages * count + widget.initialIndex.clamp(0, count - 1)
          : 0,
    );

    if (count > 0) {
      _prefetchAround(widget.initialIndex.clamp(0, count - 1));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<PlayerSeasonStats?> _statsFor(Player player) {
    return _statsFutures.putIfAbsent(
      player.code,
      () => _statsService.fetchSeasonStats(player),
    );
  }

  Future<PlayerEuroleagueExperience?> _experienceFor(Player player) {
    return _experienceFutures.putIfAbsent(
      player.code,
      () => _experienceService.fetchExperience(player.code),
    );
  }

  void _prefetchAround(int index) {
    final count = widget.players.length;
    if (count == 0) return;

    for (final offset in [0, 1, -1]) {
      final player = widget.players[(index + offset + count) % count];
      _statsFor(player);
      _experienceFor(player);
    }
  }

  int _playerIndex(int page) => page % widget.players.length;

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No players available',
            style: TextStyle(color: context.cs.onSurface),
          ),
        ),
      );
    }

    if (widget.players.length == 1) {
      final player = widget.players.first;
      return _PlayerDetailPage(
        player: player,
        teamName: widget.teamName,
        statsFuture: _statsFor(player),
        experienceFuture: _experienceFor(player),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) => _prefetchAround(_playerIndex(page)),
      itemBuilder: (context, page) {
        final count = widget.players.length;
        final index = _playerIndex(page);
        final player = widget.players[index];
        final previousPlayer = widget.players[(index - 1 + count) % count];
        final nextPlayer = widget.players[(index + 1) % count];

        return _PlayerDetailPage(
          player: player,
          teamName: widget.teamName,
          statsFuture: _statsFor(player),
          experienceFuture: _experienceFor(player),
          previousPlayerName: previousPlayer.displayName,
          nextPlayerName: nextPlayer.displayName,
        );
      },
    );
  }
}

class _PlayerDetailPage extends StatelessWidget {
  static const double _statCardWidth = 78;
  static const double _statCardHeight = 72;
  static const double _gridSpacing = 8;
  static const int _gridColumns = 4;
  static const double _gridWidth =
      _statCardWidth * _gridColumns + _gridSpacing * (_gridColumns - 1);

  final Player player;
  final String teamName;
  final Future<PlayerSeasonStats?> statsFuture;
  final Future<PlayerEuroleagueExperience?> experienceFuture;
  final String? previousPlayerName;
  final String? nextPlayerName;

  const _PlayerDetailPage({
    required this.player,
    required this.teamName,
    required this.statsFuture,
    required this.experienceFuture,
    this.previousPlayerName,
    this.nextPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (previousPlayerName != null || nextPlayerName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          previousPlayerName != null
                              ? '‹ $previousPlayerName'
                              : '',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          nextPlayerName != null ? '$nextPlayerName ›' : '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              PlayerAvatar(
                photoUrl: player.photoUrl,
                style: PlayerPhotoStyle.hero,
                fallbackText:
                    player.dorsal.isNotEmpty ? '#${player.dorsal}' : '?',
              ),
              const SizedBox(height: 16),
              if (player.dorsal.isNotEmpty)
                Text(
                  '#${player.dorsal}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                ),
              Text(
                player.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _headerSubtitle(player),
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildBioSection(context, player),
              _buildSectionDivider(context),
              FutureBuilder<PlayerSeasonStats?>(
                future: statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: cs.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Could not load season stats',
                        style: TextStyle(color: cs.onSurface),
                      ),
                    );
                  }

                  final stats = snapshot.data;
                  if (stats == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No season stats available',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    );
                  }

                  return _buildStatsSection(
                    context,
                    'SEASON STATS',
                    stats.seasonStats,
                  );
                },
              ),
              _buildSectionDivider(context),
              FutureBuilder<PlayerEuroleagueExperience?>(
                future: experienceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: cs.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  final experience = snapshot.data!;
                  return _buildStatsSection(
                    context,
                    'EUROLEAGUE EXPERIENCE',
                    [
                      PlayerStatItem(
                        label: 'SEASONS',
                        value: experience.seasons.toString(),
                      ),
                      PlayerStatItem(
                        label: 'GAMES',
                        value: experience.games.toString(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headerSubtitle(Player player) {
    final parts = <String>[
      if (player.position.isNotEmpty) player.position,
      teamName,
    ];
    return parts.join(' · ');
  }

  Widget _buildBioSection(BuildContext context, Player player) {
    final rows = _bioRows(player);
    if (rows.isEmpty) return const SizedBox.shrink();
    final cs = context.cs;

    return Column(
      children: [
        _buildSectionTitle(context, 'PLAYER BIO'),
        const SizedBox(height: 12),
        Container(
          width: _gridWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: rows
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 118,
                          child: Text(
                            row.label,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row.value,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  List<_BioRow> _bioRows(Player player) {
    final age = PlayerBioFormatter.ageFromBirthDate(player.birthDate);
    final rows = <_BioRow>[];

    if (age != null) rows.add(_BioRow('Age', age.toString()));
    if (player.height > 0) {
      rows.add(_BioRow('Height', '${player.height} cm'));
    }
    if (player.weight > 0) {
      rows.add(_BioRow('Weight', '${player.weight} kg'));
    }
    if (player.country.isNotEmpty) {
      rows.add(_BioRow('Nationality', player.country));
    }
    if (player.birthCountry.isNotEmpty) {
      rows.add(_BioRow('Born in', player.birthCountry));
    }
    if (player.lastTeam.isNotEmpty) {
      rows.add(
        _BioRow(
          'Last team',
          PlayerBioFormatter.formatTeamName(player.lastTeam),
        ),
      );
    }

    return rows;
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.cs.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    String title,
    List<PlayerStatItem> stats,
  ) {
    return Column(
      children: [
        _buildSectionTitle(context, title),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: _gridWidth,
            child: Wrap(
              spacing: _gridSpacing,
              runSpacing: _gridSpacing,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: stats
                  .map(
                    (stat) => SizedBox(
                      width: _statCardWidth,
                      height: _statCardHeight,
                      child: _buildStatCard(context, stat.label, stat.value),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: _gridWidth,
          child: Divider(color: Theme.of(context).dividerColor, height: 1),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    final cs = context.cs;

    return Container(
      width: _statCardWidth,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BioRow {
  final String label;
  final String value;

  const _BioRow(this.label, this.value);
}
