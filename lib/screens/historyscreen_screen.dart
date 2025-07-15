import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../widgets/workouthistorycard_widget.dart';
import '../widgets/achievementcard_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample workout history data (only last 2 weeks)
  final List<WorkoutHistory> recentWorkouts = [
    WorkoutHistory(
      'Upper Body Strength', 
      DateTime.now().subtract(const Duration(days: 1)),
      45,
      ['Bench Press', 'Pull-ups', 'Shoulder Press'],
      true,
      DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      DateTime.now().subtract(const Duration(days: 1, minutes: 16)),
      [
        ExerciseDetail('Bench Press', 3, 8, 135),
        ExerciseDetail('Pull-ups', 3, 6, 0),
        ExerciseDetail('Shoulder Press', 3, 10, 65),
      ]
    ),
    WorkoutHistory(
      'Lower Body Power', 
      DateTime.now().subtract(const Duration(days: 3)),
      52,
      ['Squats', 'Deadlifts', 'Lunges'],
      true,
      DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 30)),
      DateTime.now().subtract(const Duration(days: 3, minutes: 38)),
      [
        ExerciseDetail('Squats', 4, 12, 185),
        ExerciseDetail('Deadlifts', 3, 8, 225),
        ExerciseDetail('Lunges', 3, 10, 25),
      ]
    ),
    WorkoutHistory(
      'Full Body HIIT', 
      DateTime.now().subtract(const Duration(days: 5)),
      38,
      ['Burpees', 'Mountain Climbers', 'Jump Squats'],
      true,
      DateTime.now().subtract(const Duration(days: 5, minutes: 45)),
      DateTime.now().subtract(const Duration(days: 5, minutes: 7)),
      [
        ExerciseDetail('Burpees', 4, 15, 0),
        ExerciseDetail('Mountain Climbers', 4, 20, 0),
        ExerciseDetail('Jump Squats', 3, 12, 0),
      ]
    ),
    WorkoutHistory(
      'Push Day', 
      DateTime.now().subtract(const Duration(days: 8)),
      41,
      ['Push-ups', 'Dips', 'Pike Push-ups'],
      true,
      DateTime.now().subtract(const Duration(days: 8, minutes: 50)),
      DateTime.now().subtract(const Duration(days: 8, minutes: 9)),
      [
        ExerciseDetail('Push-ups', 3, 15, 0),
        ExerciseDetail('Dips', 3, 8, 0),
        ExerciseDetail('Pike Push-ups', 2, 6, 0),
      ]
    ),
    WorkoutHistory(
      'Pull Day', 
      DateTime.now().subtract(const Duration(days: 10)),
      47,
      ['Pull-ups', 'Rows', 'Face Pulls'],
      true,
      DateTime.now().subtract(const Duration(days: 10, minutes: 55)),
      DateTime.now().subtract(const Duration(days: 10, minutes: 8)),
      [
        ExerciseDetail('Pull-ups', 3, 7, 0),
        ExerciseDetail('Rows', 3, 12, 95),
        ExerciseDetail('Face Pulls', 3, 15, 20),
      ]
    ),
    WorkoutHistory(
      'Cardio Session', 
      DateTime.now().subtract(const Duration(days: 12)),
      30,
      ['Treadmill', 'Cycling'],
      true,
      DateTime.now().subtract(const Duration(days: 12, minutes: 35)),
      DateTime.now().subtract(const Duration(days: 12, minutes: 5)),
      [
        ExerciseDetail('Treadmill', 1, 20, 0),
        ExerciseDetail('Cycling', 1, 10, 0),
      ]
    ),
  ];

  final List<Achievement> achievements = [
    Achievement(title: 'First Workout', description: 'Completed your first workout session', icon: Icons.star, unlocked: true),
    Achievement(title: 'Week Warrior', description: 'Worked out 3 times this week', icon: Icons.local_fire_department, unlocked: true),
    Achievement(title: 'Consistency King', description: '7 day workout streak', icon: Icons.flash_on, unlocked: false),
    Achievement(title: 'Strength Seeker', description: 'Lifted 1000lbs total in one session', icon: Icons.fitness_center, unlocked: false),
    Achievement(title: 'Early Bird', description: 'Completed 5 morning workouts', icon: Icons.wb_sunny, unlocked: true),
  ];

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
                  _buildStatColumn('This Week', '3', 'Workouts'),
                  _buildStatColumn('Total Time', '156', 'Minutes'),
                  _buildStatColumn('Streak', '5', 'Days'),
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
                      _buildStatColumn('Workouts', '12', 'Completed'),
                      _buildStatColumn('Hours', '8.5', 'Total'),
                      _buildStatColumn('Avg/Week', '3.2', 'Sessions'),
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
                  _buildWorkoutTypeRow('Strength Training', '60%', Colors.blue, 0.6),
                  const SizedBox(height: 12),
                  _buildWorkoutTypeRow('HIIT', '25%', Colors.orange, 0.25),
                  const SizedBox(height: 12),
                  _buildWorkoutTypeRow('Cardio', '15%', Colors.green, 0.15),
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
                    _buildPRRow('Bench Press', '185 lbs', Icons.fitness_center),
                    _buildPRRow('Squat', '225 lbs', Icons.accessibility_new),
                    _buildPRRow('Deadlift', '275 lbs', Icons.self_improvement),
                    _buildPRRow('Pull-ups', '12 reps', Icons.trending_up),
                    _buildPRRow('Plank', '2:30', Icons.timer),
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
                        '3 of 5 unlocked',
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
