import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../widgets/workouthistorycard_widget.dart';
import '../widgets/achievementcard_widget.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  List<WorkoutHistory> get recentWorkouts {
    // Flatten all workout sessions into a list and sort by date descending
    final List<WorkoutHistory> allWorkouts = [];
    context.watch<FitnessDataProvider>().workoutHistory.forEach((exerciseName, sessions) {
      for (final session in sessions) {
        allWorkouts.add(
    WorkoutHistory(
            session.name,
            session.date,
            session.durationMinutes,
            session.exercises.map((e) => e.name).toList(),
            session.completed,
            session.date,
            session.date.add(Duration(minutes: session.durationMinutes)),
            session.exercises.map((e) => ExerciseDetail(e.name, e.sets, e.reps, e.weight)).toList(),
          ),
        );
      }
    });
    allWorkouts.sort((a, b) => b.date.compareTo(a.date));
    return allWorkouts;
  }

  List<Achievement> get achievements {
    // Example dynamic achievements based on real data
    final totalWorkouts = recentWorkouts.length;
    final streak = _calculateWorkoutStreak();
    return [
      Achievement(
        title: 'First Workout',
        description: 'Completed your first workout session',
        icon: Icons.star,
        unlocked: totalWorkouts > 0,
      ),
      Achievement(
        title: 'Week Warrior',
        description: 'Worked out 3 times this week',
        icon: Icons.local_fire_department,
        unlocked: _workoutsThisWeek() >= 3,
      ),
      Achievement(
        title: 'Consistency King',
        description: '7 day workout streak',
        icon: Icons.flash_on,
        unlocked: streak >= 7,
      ),
      Achievement(
        title: 'Strength Seeker',
        description: 'Lifted 1000lbs total in one session',
        icon: Icons.fitness_center,
        unlocked: _hasLifted1000lbs(),
      ),
      Achievement(
        title: 'Early Bird',
        description: 'Completed 5 morning workouts',
        icon: Icons.wb_sunny,
        unlocked: _morningWorkouts() >= 5,
      ),
    ];
  }

  int _workoutsThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return recentWorkouts.where((w) => w.date.isAfter(startOfWeek)).length;
  }

  int _calculateWorkoutStreak() {
    // Simple streak calculation: count consecutive days with workouts
    final dates = recentWorkouts.map((w) => w.date.toLocal().toIso8601String().substring(0, 10)).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime current = DateTime.now();
    for (final dateStr in dates) {
      if (dateStr == current.toIso8601String().substring(0, 10)) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  bool _hasLifted1000lbs() {
    // Check if any session has total weight lifted >= 1000 lbs
    for (final w in recentWorkouts) {
      double total = w.exerciseDetails.fold(0, (sum, e) => sum + (e.weight * e.reps * e.sets));
      if (total >= 1000) return true;
    }
    return false;
  }

  int _morningWorkouts() {
    // Count workouts started before 9am
    return recentWorkouts.where((w) => w.startTime.hour < 9).length;
  }

  // --- Helper methods for Stats Tab ---
  List<WorkoutHistory> get _monthlyWorkouts {
    final now = DateTime.now();
    return recentWorkouts.where((w) => w.date.year == now.year && w.date.month == now.month).toList();
  }

  int get _monthlyWorkoutCount => _monthlyWorkouts.length;
  double get _monthlyTotalHours => _monthlyWorkouts.fold(0, (sum, w) => sum + w.durationMinutes) / 60.0;
  double get _monthlyAvgPerWeek {
    if (_monthlyWorkouts.isEmpty) return 0.0;
    final now = DateTime.now();
    final first = _monthlyWorkouts.map((w) => w.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final weeks = ((now.difference(first).inDays + 1) / 7).clamp(1, 5); // Avoid div by 0, max 5 weeks/month
    return _monthlyWorkoutCount / weeks;
  }

  Map<String, int> get _monthlyWorkoutTypeCounts {
    // You may want to adjust this mapping based on your exercise naming conventions
    final Map<String, int> counts = {
      'Strength Training': 0,
      'HIIT': 0,
      'Cardio': 0,
    };
    for (final w in _monthlyWorkouts) {
      for (final e in w.exerciseDetails) {
        final name = e.name.toLowerCase();
        if (name.contains('bench') || name.contains('squat') || name.contains('deadlift') || name.contains('press') || name.contains('row') || name.contains('pull-up') || name.contains('push-up')) {
          counts['Strength Training'] = counts['Strength Training']! + 1;
        } else if (name.contains('hiit') || name.contains('interval')) {
          counts['HIIT'] = counts['HIIT']! + 1;
        } else if (name.contains('run') || name.contains('cardio') || name.contains('bike') || name.contains('treadmill')) {
          counts['Cardio'] = counts['Cardio']! + 1;
        }
      }
    }
    return counts;
  }

  Map<String, double> get _monthlyWorkoutTypePercentages {
    final counts = _monthlyWorkoutTypeCounts;
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return {
        'Strength Training': 0.0,
        'HIIT': 0.0,
        'Cardio': 0.0,
      };
    }
    return {
      'Strength Training': counts['Strength Training']! / total,
      'HIIT': counts['HIIT']! / total,
      'Cardio': counts['Cardio']! / total,
    };
  }

  Map<String, String> get _personalRecords {
    // Find max for each PR type
    double bench = 0, squat = 0, deadlift = 0;
    int pullups = 0;
    Duration plank = Duration.zero;
    for (final w in recentWorkouts) {
      for (final e in w.exerciseDetails) {
        final name = e.name.toLowerCase();
        if (name.contains('bench')) {
          if (e.weight > bench) bench = e.weight;
        } else if (name.contains('squat')) {
          if (e.weight > squat) squat = e.weight;
        } else if (name.contains('deadlift')) {
          if (e.weight > deadlift) deadlift = e.weight;
        } else if (name.contains('pull-up')) {
          if (e.reps > pullups) pullups = e.reps;
        } else if (name.contains('plank')) {
          // Assume plank reps = seconds
          if (e.reps > plank.inSeconds) plank = Duration(seconds: e.reps);
        }
      }
    }
    return {
      'Bench Press': bench > 0 ? '${bench.toInt()} lbs' : '-',
      'Squat': squat > 0 ? '${squat.toInt()} lbs' : '-',
      'Deadlift': deadlift > 0 ? '${deadlift.toInt()} lbs' : '-',
      'Pull-ups': pullups > 0 ? '$pullups reps' : '-',
      'Plank': plank.inSeconds > 0 ? _formatDuration(plank) : '-',
    };
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return s > 0 ? '${m}:${s.toString().padLeft(2, '0')}' : '${m}:00';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent', icon: Icon(Icons.history)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Awards', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentTab(),
          _buildStatsTab(),
          _buildAwardsTab(),
        ],
      ),
    );
  }

  Widget _buildRecentTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('This Week', _workoutsThisWeek().toString(), 'Workouts'),
                  _buildStatColumn('Total Time', recentWorkouts.fold(0, (sum, w) => sum + w.durationMinutes).toString(), 'Minutes'),
                  _buildStatColumn('Streak', _calculateWorkoutStreak().toString(), 'Days'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recent Workouts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          // Workout History List
          Expanded(
            child: ListView.builder(
              itemCount: recentWorkouts.length,
              itemBuilder: (context, index) {
                final workout = recentWorkouts[index];
                return WorkoutHistoryCard(workout: workout);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final pr = _personalRecords;
    final typePct = _monthlyWorkoutTypePercentages;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Workouts', _monthlyWorkoutCount.toString(), 'Completed'),
                      _buildStatColumn('Hours', _monthlyTotalHours.toStringAsFixed(1), 'Total'),
                      _buildStatColumn('Avg/Week', _monthlyAvgPerWeek.toStringAsFixed(1), 'Sessions'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Workout Type Breakdown
          Text(
            'Workout Types',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildWorkoutTypeRow('Strength Training', '${(typePct['Strength Training']!*100).toStringAsFixed(0)}%', Colors.blue, typePct['Strength Training']!),
                  const SizedBox(height: 12),
                  _buildWorkoutTypeRow('HIIT', '${(typePct['HIIT']!*100).toStringAsFixed(0)}%', Colors.orange, typePct['HIIT']!),
                  const SizedBox(height: 12),
                  _buildWorkoutTypeRow('Cardio', '${(typePct['Cardio']!*100).toStringAsFixed(0)}%', Colors.green, typePct['Cardio']!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Personal Records
          Text(
            'Personal Records',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPRRow('Bench Press', pr['Bench Press']!, Icons.fitness_center),
                    _buildPRRow('Squat', pr['Squat']!, Icons.accessibility_new),
                    _buildPRRow('Deadlift', pr['Deadlift']!, Icons.self_improvement),
                    _buildPRRow('Pull-ups', pr['Pull-ups']!, Icons.trending_up),
                    _buildPRRow('Plank', pr['Plank']!, Icons.timer),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 40,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${achievements.where((a) => a.unlocked).length} of ${achievements.length} unlocked',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Achievements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return AchievementCard(achievement: achievement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTypeRow(String type, String percentage, Color color, double progress) {
    return Row(
      children: [
        Expanded(
          child: Text(type),
        ),
        Text(percentage),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPRRow(String exercise, String record, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(exercise)),
          Text(
            record,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// WorkoutHistory and ExerciseDetail classes defined in models/fitness_models.dart
