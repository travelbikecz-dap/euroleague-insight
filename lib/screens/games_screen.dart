import 'dart:async';

import 'package:flutter/material.dart';

import '../config/live_game_polling.dart';
import '../models/euroleague_game.dart';
import '../models/game_round.dart';
import '../models/live_game_snapshot.dart';
import '../repositories/games_repository.dart';
import '../screens/matchup_screen.dart';
import '../services/game_status_resolver.dart';
import '../services/live_game_api_service.dart';
import '../services/live_game_merger.dart';
import '../widgets/game_card.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with WidgetsBindingObserver {
  final _repository = GamesRepository();
  final _liveService = LiveGameApiService();
  PageController? _pageController;
  Timer? _liveTimer;

  List<GameRound>? _baseRounds;
  Map<int, LiveGameSnapshot> _liveSnapshots = {};
  int _currentPage = 0;
  bool _loading = true;
  String? _error;

  List<GameRound>? get _rounds {
    final baseRounds = _baseRounds;
    if (baseRounds == null) return null;
    return LiveGameMerger.applyToRounds(baseRounds, _liveSnapshots);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRounds();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLivePolling();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncLivePolling();
      unawaited(_pollLiveGames());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopLivePolling();
    }
  }

  Future<void> _loadRounds({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rounds = await _repository.getRegularSeasonRounds(
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      if (rounds.isEmpty) {
        _pageController?.dispose();
        _pageController = null;
        setState(() {
          _baseRounds = rounds;
          _liveSnapshots = {};
          _loading = false;
        });
        _stopLivePolling();
        return;
      }

      final targetPage = _targetPage(rounds, preserveCurrentRound: forceRefresh);
      _pageController?.dispose();
      _pageController = PageController(initialPage: targetPage);

      setState(() {
        _baseRounds = rounds;
        if (!forceRefresh) {
          _liveSnapshots = {};
        }
        _currentPage = targetPage;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _pageController == null) return;
        if (_pageController!.hasClients &&
            _pageController!.page?.round() != targetPage) {
          _pageController!.jumpToPage(targetPage);
        }
      });

      _syncLivePolling();
      unawaited(_pollLiveGames());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  int _targetPage(List<GameRound> rounds, {required bool preserveCurrentRound}) {
    if (preserveCurrentRound && _baseRounds != null && _baseRounds!.isNotEmpty) {
      final safeIndex = _currentPage.clamp(0, _baseRounds!.length - 1);
      final currentRoundNumber = _baseRounds![safeIndex].roundNumber;
      final preservedIndex = rounds.indexWhere(
        (round) => round.roundNumber == currentRoundNumber,
      );
      if (preservedIndex >= 0) return preservedIndex;
    }

    final primaryRound = _repository.selectPrimaryRound(rounds);
    return _roundIndex(rounds, primaryRound).clamp(0, rounds.length - 1);
  }

  int _roundIndex(List<GameRound> rounds, GameRound selected) {
    return rounds.indexWhere(
      (round) => round.roundNumber == selected.roundNumber,
    );
  }

  Iterable<EuroleagueGame> get _allGames {
    return _baseRounds?.expand((round) => round.games) ?? const [];
  }

  void _syncLivePolling() {
    final hasCandidates = GameStatusResolver.livePollCandidates(_allGames).isNotEmpty;
    if (!hasCandidates) {
      _stopLivePolling();
      return;
    }

    _liveTimer ??= Timer.periodic(LiveGamePolling.interval, (_) {
      unawaited(_pollLiveGames());
    });
  }

  void _stopLivePolling() {
    _liveTimer?.cancel();
    _liveTimer = null;
  }

  Future<void> _pollLiveGames() async {
    final baseRounds = _baseRounds;
    if (baseRounds == null || baseRounds.isEmpty) return;

    final candidates = GameStatusResolver.livePollCandidates(_allGames);
    if (candidates.isEmpty) {
      if (mounted) {
        setState(() => _liveSnapshots = {});
      }
      _stopLivePolling();
      return;
    }

    final candidateCodes = candidates.map((game) => game.gameCode).toSet();
    final snapshots = await _liveService.fetchHeaders(
      seasonCode: candidates.first.seasonCode,
      gameCodes: candidateCodes,
    );

    if (!mounted) return;

    setState(() {
      _liveSnapshots
        ..removeWhere((code, _) => !candidateCodes.contains(code))
        ..addAll(snapshots);
    });
    _syncLivePolling();
  }

  Future<void> _openRoundPicker() async {
    final rounds = _rounds;
    if (rounds == null || rounds.isEmpty) return;

    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return ListView.builder(
          itemCount: rounds.length,
          itemBuilder: (context, index) {
            final round = rounds[index];
            final isSelected = index == _currentPage;

            return ListTile(
              selected: isSelected,
              title: Text(
                round.compactHeaderLabel,
                style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '${round.games.length} games',
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () => Navigator.pop(context, index),
            );
          },
        );
      },
    );

    if (!mounted || selected == null || _pageController == null) return;

    await _pageController!.animateToPage(
      selected,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _baseRounds == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && (_baseRounds == null || _baseRounds!.isEmpty)) {
      return Center(
        child: Text(
          'ERROR: $_error',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    final rounds = _rounds;
    if (rounds == null || rounds.isEmpty) {
      return const Center(
        child: Text(
          'No regular season games available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (_pageController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _RoundHeader(
          round: rounds[_currentPage],
          canGoBack: _currentPage > 0,
          canGoForward: _currentPage < rounds.length - 1,
          onPrevious: () => _pageController?.previousPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
          onNext: () => _pageController?.nextPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
          onPickRound: _openRoundPicker,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadRounds(forceRefresh: true),
            color: Colors.orange,
            backgroundColor: Colors.grey[900],
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final round = rounds[index];
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: round.games.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, gameIndex) {
                    final game = round.games[gameIndex];
                    return GameCard(
                      game: game,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchUpScreen(game: game),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundHeader extends StatelessWidget {
  final GameRound round;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickRound;

  const _RoundHeader({
    required this.round,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
    required this.onPickRound,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useCompactHeader = screenWidth < 400;
    final titleText = useCompactHeader
        ? round.compactHeaderLabel
        : 'Round ${round.roundNumber} · ${round.dateLabel}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoBack ? onPrevious : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Expanded(
            child: InkWell(
              onTap: onPickRound,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${round.games.length} games · tap to jump',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: canGoForward ? onNext : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
