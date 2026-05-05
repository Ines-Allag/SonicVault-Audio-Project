import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:sonic_vault/features/stats/models/top_track.dart';
import 'package:sonic_vault/shared/repositories/firebase_repo.dart';
import 'package:sonic_vault/features/explorer/views/explorer_page.dart';
import 'package:sonic_vault/shared/widgets/mini_player_bar.dart';

// ← fl_chart import removed, no longer needed

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _userName = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StatsViewModel>().init();
      _loadUserName();
    });
  }

  Future<void> _loadUserName() async {
    final repo = FirebaseRepository();
    final user = await repo.getCurrentUserData();
    if (mounted && user != null) {
      setState(() {
        _userName = user.fullName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayerBar(),
              const SizedBox(height: 8),
              NavigationBar(
                backgroundColor: const Color(0xFF111111),
                indicatorColor: const Color(0xFF22C55E).withOpacity(0.15),
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  if (index == _currentIndex) return;
                  setState(() => _currentIndex = index);
                  if (index == 1) {
                    Navigator.pushNamed(context, '/explorer');
                  }
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_rounded, color: Colors.white38),
                    selectedIcon: Icon(Icons.bar_chart_rounded,
                        color: Color(0xFF22C55E)),
                    label: 'Stats',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined, color: Colors.white38),
                    selectedIcon: Icon(Icons.explore_rounded,
                        color: Color(0xFF22C55E)),
                    label: 'Explorer',
                  ),
                ],
              ),
            ],
          ),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D0D0D),
            elevation: 0,
            title: const Text(
              'Sonic Vault',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          body: SafeArea(
            child: viewModel.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF22c55e),
              ),
            )
                : RefreshIndicator(
              color: const Color(0xFF22c55e),
              backgroundColor: const Color(0xFF1A1A1A),
              onRefresh: () => viewModel.loadStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 20),
                    _buildStatsCards(viewModel),
                    const SizedBox(height: 24),
                    _buildMonthlyGoal(viewModel),
                    const SizedBox(height: 24),
                    _buildHistogram(viewModel),
                    const SizedBox(height: 24),
                    _buildTopTracks(viewModel),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── WELCOME HEADER ────────────────────────────
  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting,
            style: const TextStyle(color: Colors.white38, fontSize: 14)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Welcome, ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: _userName.isEmpty ? '...' : _userName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STATS CARDS ───────────────────────────────
  Widget _buildStatsCards(StatsViewModel viewModel) {
    final stats = viewModel.statsData;
    final totalHours = stats?.totalHours ?? 0;
    final trackCount = stats?.topTracks.length ?? 0;
    final goalPercent = (viewModel.goalProgress * 100).toInt();

    return Row(
      children: [
        _statCard(
            value: '${totalHours}h',
            label: 'this month',
            color: const Color(0xFF22c55e)),
        const SizedBox(width: 12),
        _statCard(
            value: '$trackCount', label: 'tracks', color: Colors.white),
        const SizedBox(width: 12),
        _statCard(
            value: '$goalPercent%',
            label: 'goal',
            color: const Color(0xFF22c55e)),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── MONTHLY GOAL ──────────────────────────────
  Widget _buildMonthlyGoal(StatsViewModel viewModel) {
    final stats = viewModel.statsData;
    final totalHours = stats?.totalHours ?? 0;
    final totalMins = stats?.remainingMinutes ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Goal',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: viewModel.monthlyGoalHours,
                  dropdownColor: const Color(0xFF1A1A1A),
                  underline: const SizedBox(),
                  style: const TextStyle(
                      color: Color(0xFF22c55e),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  items: viewModel.goalOptions.map((int hours) {
                    return DropdownMenuItem(
                        value: hours, child: Text('$hours h'));
                  }).toList(),
                  onChanged: (int? value) {
                    if (value != null) viewModel.setMonthlyGoal(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${totalHours}h ${totalMins}min listened',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
              Text('${viewModel.monthlyGoalHours}h goal',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: viewModel.goalProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF22c55e)),
            ),
          ),
        ],
      ),
    );
  }

  // ── HISTOGRAM (improved) ──────────────────────
  Widget _buildHistogram(StatsViewModel viewModel) {
    final stats = viewModel.statsData;
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    final Map<int, int> dayMinutes = {};
    if (stats != null) {
      for (final stat in stats.dailyStats) {
        dayMinutes[stat.date.day] = stat.minutes;
      }
    }

    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int maxMinutes = dayMinutes.values.isEmpty
        ? 60
        : dayMinutes.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minutes / day',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22c55e).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF22c55e).withOpacity(0.3)),
                ),
                child: Text(
                  monthName,
                  style: const TextStyle(
                    color: Color(0xFF22c55e),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── SUBTITLE ──────────────────────────
          Text(
            dayMinutes.isEmpty
                ? 'No listening data yet'
                : 'Today: ${dayMinutes[now.day] ?? 0} min · Peak: $maxMinutes min',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),

          const SizedBox(height: 20),

          if (dayMinutes.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        color: Colors.white12, size: 48),
                    SizedBox(height: 8),
                    Text('Start listening to see your chart',
                        style: TextStyle(
                            color: Colors.white24, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── Y AXIS ────────────────────
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${maxMinutes}m',
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 9)),
                      Text('${(maxMinutes * 0.5).round()}m',
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 9)),
                      const Text('0',
                          style: TextStyle(
                              color: Colors.white24, fontSize: 9)),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // ── BARS ──────────────────────
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children:
                            List.generate(daysInMonth, (index) {
                              final int day = index + 1;
                              final int minutes = dayMinutes[day] ?? 0;
                              final bool isToday = day == now.day;
                              final bool hasData = minutes > 0;
                              final double heightRatio = maxMinutes == 0
                                  ? 0
                                  : minutes / maxMinutes;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      // Label on today's bar
                                      if (isToday && hasData)
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 3),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 3,
                                              vertical: 1),
                                          decoration: BoxDecoration(
                                            color:
                                            const Color(0xFF22c55e),
                                            borderRadius:
                                            BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            '$minutes',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 7,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      // Bar
                                      AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 600),
                                        curve: Curves.easeOut,
                                        height: hasData
                                            ? (heightRatio * 130)
                                            .clamp(4.0, 130.0)
                                            : 3,
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? const Color(0xFF22c55e)
                                              : hasData
                                              ? const Color(0xFF22c55e)
                                              .withOpacity(0.5)
                                              : Colors.white
                                              .withOpacity(0.05),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                                isToday ? 4 : 2),
                                            topRight: Radius.circular(
                                                isToday ? 4 : 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        // ── X AXIS LABELS ────────
                        const SizedBox(height: 6),
                        Row(
                          children:
                          List.generate(daysInMonth, (index) {
                            final int day = index + 1;
                            final bool show = day == 1 ||
                                day % 5 == 0 ||
                                day == now.day;
                            final bool isToday = day == now.day;
                            return Expanded(
                              child: Text(
                                show ? '$day' : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isToday
                                      ? const Color(0xFF22c55e)
                                      : Colors.white24,
                                  fontSize: 8,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── LEGEND ────────────────────────────
          if (dayMinutes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22c55e),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Today',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 11)),
                const SizedBox(width: 16),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22c55e).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Other days',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── TOP TRACKS ────────────────────────────────
  Widget _buildTopTracks(StatsViewModel viewModel) {
    final stats = viewModel.statsData;
    final tracks = stats?.topTracks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Most Listened',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            if (tracks.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: const Text('see all',
                    style: TextStyle(
                        color: Color(0xFF22c55e), fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (tracks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'No tracks listened yet this month.\nStart listening to see your stats!',
              style: TextStyle(
                  color: Colors.white38, fontSize: 13, height: 1.6),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...tracks.asMap().entries.map((entry) {
            return _buildTopTrackItem(entry.key + 1, entry.value);
          }),
      ],
    );
  }

  Widget _buildTopTrackItem(int rank, TopTrack topTrack) {
    final int hours = topTrack.totalMinutes ~/ 60;
    final int mins = topTrack.totalMinutes % 60;
    final String duration =
    hours > 0 ? '${hours}h${mins}' : '${mins}min';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('$rank',
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF22c55e).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: topTrack.track.imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(topTrack.track.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.music_note_rounded,
                      color: Color(0xFF22c55e),
                      size: 24)),
            )
                : const Icon(Icons.music_note_rounded,
                color: Color(0xFF22c55e), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topTrack.track.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                    '${topTrack.track.artist} • ${topTrack.playCount} plays',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Text(duration,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────
  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}