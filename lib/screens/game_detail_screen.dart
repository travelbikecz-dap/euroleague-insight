import 'dart:async';

import 'package:flutter/material.dart';

import '../config/live_game_polling.dart';
import '../models/euroleague_game.dart';
import '../models/game_display_status.dart';
import '../services/game_status_resolver.dart';
import '../services/live_game_api_service.dart';
import '../services/live_game_merger.dart';
import '../theme/app_theme.dart';
import '../utils/game_time_formatter.dart';
import '../widgets/team_logo.dart';

class GameDetailScreen extends StatefulWidget {
  final EuroleagueGame game;

  const GameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen>
    with WidgetsBindingObserver {
  final _liveService = LiveGameApiService();
  Timer? _liveTimer;
  late EuroleagueGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = widget.game;
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
    return _game.status.label;
  }

  Color _statusColor(BuildContext context) {
    if (_game.status == GameDisplayStatus.live) {
      return Colors.redAccent;
    }
    return context.statusHighlightColor;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Scaffold(
      appBar: AppBar(
        title: Text(_game.roundLabel),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _statusLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusColor(context),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                GameTimeFormatter.formatFull(_game.utcDate),
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _teamBlock(
                context,
                logo: _game.homeLogo,
                name: _game.homeDisplayName,
                score: _game.homeScore,
                isHome: true,
              ),
              const SizedBox(height: 20),
              _teamBlock(
                context,
                logo: _game.awayLogo,
                name: _game.awayDisplayName,
                score: _game.awayScore,
                isHome: false,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: context.cardDecoration(radius: 12),
                child: Text(
                  'MatchUp and predictions coming in a future update.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamBlock(
    BuildContext context, {
    required String logo,
    required String name,
    required int? score,
    required bool isHome,
  }) {
    final cs = context.cs;

    return Row(
      children: [
        TeamLogo(assetPath: logo, width: 56, height: 56, borderRadius: 12),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHome ? 'Home' : 'Away',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
