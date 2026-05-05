import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sonic_vault/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:sonic_vault/features/stats/models/top_track.dart';
import 'package:sonic_vault/shared/repositories/firebase_repo.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _userName = '';

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
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
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

                    // ── WELCOME MESSAGE ──────────────
                    _buildWelcomeHeader(),

                    const SizedBox(height: 20),

                    // ── STATS CARDS ROW ──────────────
                    _buildStatsCards(viewModel),

                    const SizedBox(height: 24),

                    // ── MONTHLY GOAL ─────────────────
                    _buildMonthlyGoal(viewModel),

                    const SizedBox(height: 24),

                    // ── HISTOGRAM ────────────────────
                    _buildHistogram(viewModel),

                    const SizedBox(height: 24),

                    // ── TOP TRACKS ───────────────────
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
        Text(
          greeting,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Welcome, ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: _userName.isEmpty ? '...' : _userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold, // name in bold as required
                ),
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
    final totalMins = stats?.remainingMinutes ?? 0;
    final trackCount = stats?.topTracks.length ?? 0;
    final goalPercent = (viewModel.goalProgress * 100).toInt();

    return Row(
      children: [
        _statCard(
          value: '${totalHours}h',
          label: 'this month',
          color: const Color(0xFF22c55e),
        ),
        const SizedBox(width: 12),
        _statCard(
          value: '$trackCount',
          label: 'tracks',
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        _statCard(
          value: '$goalPercent%',
          label: 'goal',
          color: const Color(0xFF22c55e),
        ),
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
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
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

          // label + goal selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              // ── GOAL DROPDOWN ──────────────────
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
                    fontSize: 14,
                  ),
                  items: viewModel.goalOptions.map((int hours) {
                    return DropdownMenuItem(
                      value: hours,
                      child: Text('$hours h'),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    if (value != null) {
                      viewModel.setMonthlyGoal(value);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalHours}h ${totalMins}min listened',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Text(
                '${viewModel.monthlyGoalHours}h goal',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: viewModel.goalProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF22c55e),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HISTOGRAM ─────────────────────────────────
  Widget _buildHistogram(StatsViewModel viewModel) {
    final stats = viewModel.statsData;
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    // build bar groups from daily stats
    final Map<int, int> dayMinutes = {};
    if (stats != null) {
      for (final stat in stats.dailyStats) {
        dayMinutes[stat.date.day] = stat.minutes;
      }
    }

    // create bars for every day of current month
    final int daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;

    final List<BarChartGroupData> bars = List.generate(
      daysInMonth,
          (index) {
        final int day = index + 1;
        final int minutes = dayMinutes[day] ?? 0;
        final bool isToday = day == now.day;

        return BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(
              toY: minutes.toDouble(),
              color: isToday
                  ? const Color(0xFF22c55e)
                  : const Color(0xFF22c55e).withOpacity(0.35),
              width: 6,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              ),
            ),
          ],
        );
      },
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minutes / day — $monthName',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: stats == null || stats.dailyStats.isEmpty
                ? const Center(
              child: Text(
                'No listening data yet',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            )
                : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (dayMinutes.values.isEmpty
                    ? 60
                    : dayMinutes.values.reduce(
                        (a, b) => a > b ? a : b) +
                    10)
                    .toDouble(),
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // only show every 5 days
                        if (value.toInt() % 5 != 0) {
                          return const SizedBox();
                        }
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
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
            const Text(
              'Most Listened',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (tracks.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: const Text(
                  'see all',
                  style: TextStyle(
                    color: Color(0xFF22c55e),
                    fontSize: 13,
                  ),
                ),
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
                color: Colors.white38,
                fontSize: 13,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...tracks.asMap().entries.map((entry) {
            final int index = entry.key;
            final TopTrack topTrack = entry.value;
            return _buildTopTrackItem(index + 1, topTrack);
          }),
      ],
    );
  }

  Widget _buildTopTrackItem(int rank, TopTrack topTrack) {
    final int hours = topTrack.totalMinutes ~/ 60;
    final int mins = topTrack.totalMinutes % 60;
    final String duration = hours > 0 ? '${hours}h${mins}' : '${mins}min';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          // rank number
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // cover image
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
              child: Image.network(
                topTrack.track.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.music_note_rounded,
                  color: Color(0xFF22c55e),
                  size: 24,
                ),
              ),
            )
                : const Icon(
              Icons.music_note_rounded,
              color: Color(0xFF22c55e),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topTrack.track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${topTrack.track.artist} • ${topTrack.playCount} plays',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // total time
          Text(
            duration,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
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