import 'dart:async';

import 'package:flutter/material.dart';

import '../config/live_game_polling.dart';
import '../models/matchup_stat_comparison.dart';
import '../models/euroleague_game.dart';
import '../models/game_display_status.dart';
import '../models/standing.dart';
import '../models/team_stats.dart';
import '../services/game_status_resolver.dart';
import '../services/live_game_api_service.dart';
import '../services/live_game_merger.dart';
import '../services/matchup_predictor.dart';
import '../services/standings_api_service.dart';
import '../services/team_stats_api_service.dart';
import '../utils/game_time_formatter.dart';
import '../data/mock_game_mvp.dart';
import '../data/mock_post_game_analysis.dart';
import '../theme/app_theme.dart';
import '../widgets/team_logo.dart';
import '../widgets/matchup_mvp_preview.dart';
import '../widgets/matchup_post_game_preview.dart';

class MatchUpScreen extends StatefulWidget {
  final EuroleagueGame game;

  const MatchUpScreen({
    super.key,
    required this.game,
  });

  @override
  State<MatchUpScreen> createState() => _MatchUpScreenState();
}

class _MatchUpScreenState extends State<MatchUpScreen>
    with WidgetsBindingObserver {
  final _standingsApi = StandingsApiService();
  final _teamStatsApi = TeamStatsApiService();
  final _liveService = LiveGameApiService();

  Timer? _liveTimer;
  late EuroleagueGame _game;
  final _mvpSectionKey = GlobalKey();

  bool _loading = true;
  String? _error;
  TeamStats? _homeStats;
  TeamStats? _awayStats;
  MatchupPrediction? _prediction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = widget.game;
    _loadMatchupData();
    _syncLivePolling();
    unawaited(_pollLiveGame());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLivePolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncLivePolling();
      unawaited(_pollLiveGame());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopLivePolling();
    }
  }

  Future<void> _loadMatchupData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final standings = await _standingsApi.fetchStandings();
      final homeStanding = _findStanding(standings, _game.homeClubCode);
      final awayStanding = _findStanding(standings, _game.awayClubCode);

      final results = await Future.wait([
        _teamStatsApi.fetchTeamStats(homeStanding),
        _teamStatsApi.fetchTeamStats(awayStanding),
      ]);

      if (!mounted) return;

      setState(() {
        _homeStats = results[0];
        _awayStats = results[1];
        _prediction = MatchupPredictor.predict(
          home: results[0],
          away: results[1],
        );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Standing _findStanding(List<Standing> standings, String clubCode) {
    return standings.firstWhere(
      (standing) => standing.clubCode == clubCode,
      orElse: () => throw Exception('Standing not found for club $clubCode'),
    );
  }

  void _syncLivePolling() {
    if (!GameStatusResolver.isLivePollCandidate(_game)) {
      _stopLivePolling();
      return;
    }

    _liveTimer ??= Timer.periodic(LiveGamePolling.interval, (_) {
      unawaited(_pollLiveGame());
    });
  }

  void _stopLivePolling() {
    _liveTimer?.cancel();
    _liveTimer = null;
  }

  Future<void> _pollLiveGame() async {
    if (!GameStatusResolver.isLivePollCandidate(_game)) {
      _stopLivePolling();
      return;
    }

    final snapshot = await _liveService.fetchHeader(
      gameCode: _game.gameCode,
      seasonCode: _game.seasonCode,
    );

    if (!mounted || snapshot == null) return;

    setState(() {
      _game = LiveGameMerger.apply(_game, snapshot);
    });
    _syncLivePolling();
  }

  String get _statusLabel {
    if (_game.status == GameDisplayStatus.live) {
      return _game.liveClockLabel ?? _game.status.label;
    }
    if (_game.status == GameDisplayStatus.scheduled) {
      return GameTimeFormatter.formatScheduled(_game.utcDate);
    }
    return _game.status.label;
  }

  Color _statusColor(ColorScheme cs) {
    if (_game.status == GameDisplayStatus.live) {
      return Colors.redAccent;
    }
    return cs.primary;
  }

  bool get _showPostGameSections {
    return _game.status == GameDisplayStatus.final_ ||
        _game.status == GameDisplayStatus.walkover;
  }

  bool get _showMvpSection {
    return _showPostGameSections || _game.status == GameDisplayStatus.live;
  }

  Widget _buildMvpSection() {
    if (_showPostGameSections) {
      return MatchupMvpPreview(
        mvp: MockGameMvpData.forGame(_game.gameCode),
      );
    }
    return const MatchupMvpPreview.pending();
  }

  Future<void> _scrollToMvp() async {
    final context = _mvpSectionKey.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.06,
    );
  }

  Widget _mvpJumpChip(BuildContext context) {
    final cs = context.cs;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: ActionChip(
          avatar: Icon(Icons.emoji_events_outlined, size: 18, color: cs.primary),
          label: const Text('MVP'),
          labelStyle: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: context.elevatedCard,
          side: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
          onPressed: _scrollToMvp,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cs = context.cs;
    final homeStats = _homeStats!;
    final awayStats = _awayStats!;
    final prediction = _prediction!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _statusLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _statusColor(cs),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _teamHeader(
                  context,
                  logo: _game.homeLogo,
                  name: _game.homeDisplayName,
                ),
                _scoreHeader(context),
                _teamHeader(
                  context,
                  logo: _game.awayLogo,
                  name: _game.awayDisplayName,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_showMvpSection) _mvpJumpChip(context),
            _pregameSections(
              context,
              homeStats: homeStats,
              awayStats: awayStats,
              prediction: prediction,
            ),
            if (_showPostGameSections) ...[
              const SizedBox(height: 20),
              MatchupPostGamePreview(
                preview: MockPostGameAnalysis.forGame(_game.gameCode),
              ),
            ],
            if (_showMvpSection) ...[
              const SizedBox(height: 20),
              KeyedSubtree(
                key: _mvpSectionKey,
                child: _buildMvpSection(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pregameSections(
    BuildContext context, {
    required TeamStats homeStats,
    required TeamStats awayStats,
    required MatchupPrediction prediction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(context, 'Prediction'),
        const SizedBox(height: 10),
        _predictionCard(context, prediction),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Team Comparison'),
        const SizedBox(height: 10),
        _surfaceCard(
          context,
          child: _buildStatScroll(context, homeStats, awayStats),
        ),
        const SizedBox(height: 20),
        _sectionTitle(context, 'Pre-Game Insight'),
        const SizedBox(height: 10),
        _insightCard(context, prediction.insight),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_game.roundLabel),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _ErrorState(message: _error!, onRetry: _loadMatchupData)
            : _buildContent(context),
      ),
    );
  }

  Widget _teamHeader(
    BuildContext context, {
    required String logo,
    required String name,
  }) {
    return Expanded(
      child: Column(
        children: [
          TeamLogo(assetPath: logo, width: 70, height: 70),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreHeader(BuildContext context) {
    final cs = context.cs;

    if (_game.hasScoreboard &&
        (_game.status == GameDisplayStatus.live ||
            _game.status == GameDisplayStatus.final_ ||
            _game.status == GameDisplayStatus.walkover)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          '${_game.homeScore} - ${_game.awayScore}',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'vs',
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: context.cs.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _surfaceCard(BuildContext context, {required Widget child}) {
    final cs = context.cs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }

  Widget _predictionCard(BuildContext context, MatchupPrediction prediction) {
    final cs = context.cs;

    return _surfaceCard(
      context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _probabilityColumn(
              context,
              label: _game.homeDisplayName,
              value: prediction.homeWinProbability.round(),
            ),
          ),
          Container(
            width: 1,
            height: 70,
            color: cs.outline.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _probabilityColumn(
              context,
              label: _game.awayDisplayName,
              value: prediction.awayWinProbability.round(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard(BuildContext context, String insight) {
    return _surfaceCard(
      context,
      child: Text(
        insight,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: context.cs.onSurface,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }

  Widget _probabilityColumn(
    BuildContext context, {
    required String label,
    required int value,
  }) {
    final cs = context.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.primary,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatScroll(
    BuildContext context,
    TeamStats home,
    TeamStats away,
  ) {
    final stats = MatchupStatsBuilder.buildFlat(home: home, away: away);

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: stats.map((s) => _buildStatCard(context, s)).toList(),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, MatchupStatComparison stat) {
    final cs = context.cs;
    var homeColor = cs.onSurface;
    var awayColor = cs.onSurface;

    if (stat.homeValue != stat.awayValue) {
      if (!stat.lowerIsBetter) {
        if (stat.homeValue > stat.awayValue) {
          homeColor = Colors.green;
          awayColor = Colors.red;
        } else {
          homeColor = Colors.red;
          awayColor = Colors.green;
        }
      } else {
        if (stat.homeValue < stat.awayValue) {
          homeColor = Colors.green;
          awayColor = Colors.red;
        } else {
          homeColor = Colors.red;
          awayColor = Colors.green;
        }
      }
    }

    final valueStyle = TextStyle(
      fontSize: _valueFontSize(stat.homeDisplay, stat.awayDisplay),
      fontWeight: FontWeight.bold,
    );

    return Container(
      width: 128,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: context.elevatedCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text(
                  stat.homeDisplay,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle.copyWith(color: homeColor),
                ),
              ),
              Text(
                '-',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              Flexible(
                child: Text(
                  stat.awayDisplay,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle.copyWith(color: awayColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _valueFontSize(String homeDisplay, String awayDisplay) {
    final longest = homeDisplay.length > awayDisplay.length
        ? homeDisplay.length
        : awayDisplay.length;
    if (longest >= 6) return 16;
    if (longest >= 5) return 18;
    return 20;
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
