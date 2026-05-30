import 'package:flutter/material.dart';
import 'team_detail_screen.dart';
import '../services/team_stats_service.dart';
import '../models/standing.dart';
import '../models/team_stats.dart';
import '../data/team_names.dart';
import '../services/standings_api_service.dart';

enum _StandingZone { playoffs, playIn, out }

const _cardColor = Color(0xFF1C1C1E);
const _playoffsColor = Color(0xFF34C759);
const _playInColor = Color(0xFFFFD60A);

_StandingZone _zoneForIndex(int index) {
  if (index <= 5) return _StandingZone.playoffs;
  if (index <= 9) return _StandingZone.playIn;
  return _StandingZone.out;
}

Color? _zoneStripeColor(_StandingZone zone) {
  return switch (zone) {
    _StandingZone.playoffs => _playoffsColor,
    _StandingZone.playIn => _playInColor,
    _StandingZone.out => null,
  };
}

bool _isCrvenaLogo(Standing standing) {
  return standing.team.logo == 'assets/logos/crvena.png';
}

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late Future<List<Standing>> standings;
  late Future<List<TeamStats>> teamStats;

  @override
  void initState() {
    super.initState();
    standings = StandingsApiService().fetchStandings();
    teamStats = TeamStatsService().getAllTeams();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Standing>>(
      future: standings,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'ERROR: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final standingsList = snapshot.data!;

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _StandingsLegend()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final standing = standingsList[index];
                  final zone = _zoneForIndex(index);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (index == 6) const _ZoneDivider(label: 'Play-in'),
                      if (index == 10) const _ZoneDivider(label: 'Out'),
                      _StandingRowCard(
                        standing: standing,
                        position: index + 1,
                        zone: zone,
                        onTap: () => _openTeamDetail(context, standing),
                      ),
                    ],
                  );
                },
                childCount: standingsList.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }

  Future<void> _openTeamDetail(
    BuildContext context,
    Standing standing,
  ) async {
    final stats = await teamStats;
    if (!context.mounted) return;

    final selectedIndex = stats.indexWhere(
      (team) => team.clubCode == standing.clubCode,
    );

    if (selectedIndex == -1) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailScreen(
          teams: stats,
          initialIndex: selectedIndex,
        ),
      ),
    );
  }
}

class _StandingsLegend extends StatelessWidget {
  const _StandingsLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: const [
          _LegendItem(color: _playoffsColor, label: 'Playoffs (1–6)'),
          _LegendItem(color: _playInColor, label: 'Play-in (7–10)'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ZoneDivider extends StatelessWidget {
  final String label;

  const _ZoneDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.white.withValues(alpha: 0.12)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: Colors.white.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}

class _StandingRowCard extends StatelessWidget {
  final Standing standing;
  final int position;
  final _StandingZone zone;
  final VoidCallback onTap;

  const _StandingRowCard({
    required this.standing,
    required this.position,
    required this.zone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stripeColor = _zoneStripeColor(zone);
    final compactCrvenaLogo = _isCrvenaLogo(standing);
    final logoSize = compactCrvenaLogo ? 32.0 : 40.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stripeColor != null)
                  Container(width: 4, color: stripeColor),
                Expanded(
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$position.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (compactCrvenaLogo)
                          SizedBox(
                            width: logoSize,
                            height: logoSize,
                            child: Image.asset(
                              standing.team.logo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.sports_basketball,
                                  color: Colors.orange,
                                  size: logoSize * 0.75,
                                );
                              },
                            ),
                          )
                        else
                          Image.asset(
                            standing.team.logo,
                            width: logoSize,
                            height: logoSize,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.sports_basketball,
                                color: Colors.orange,
                              );
                            },
                          ),
                      ],
                    ),
                    title: Text(
                      TeamNames.shortName(standing.team.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'W: ${standing.wins} | L: ${standing.losses}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PF: ${standing.pointsFor}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'PA: ${standing.pointsAgainst}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: standing.last5Form.map((result) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Text(
                                result == 'W' ? '✅' : '❌',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
