import 'package:flutter/material.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../widgets/fitnessscorecard_widget.dart';
import 'package:provider/provider.dart';

class FitnessScoreSection extends StatefulWidget {
  const FitnessScoreSection({super.key});

  @override
  State<FitnessScoreSection> createState() => _FitnessScoreSectionState();
}

class _FitnessScoreSectionState extends State<FitnessScoreSection> {
  FitnessDataProvider get dataManager => context.watch<FitnessDataProvider>();

  @override
  Widget build(BuildContext context) {
    final scores = _calculateFitnessScores();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitness Analytics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Workout Readiness Score
        FitnessScoreCard(
          title: 'Workout Readiness',
          score: scores['readiness']!,
          maxScore: 100,
          icon: Icons.fitness_center,
          color: _getReadinessColor(scores['readiness']!),
          subtitle: _getReadinessMessage(scores['readiness']!),
          isPercentage: true,
        ),
        const SizedBox(height: 12),
        
        // Performance Improvements (can exceed 100%)
        Text(
          'Performance Growth',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: FitnessScoreCard(
                title: 'Lifting',
                score: scores['lifting']!,
                maxScore: 100,
                icon: Icons.fitness_center,
                color: Colors.blue,
                subtitle: '${scores['lifting']! > 100 ? '+' : ''}${(scores['lifting']! - 100).toInt()}% vs start',
                isPercentage: false,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FitnessScoreCard(
                title: 'Cardio',
                score: scores['cardio']!,
                maxScore: 100,
                icon: Icons.directions_run,
                color: Colors.green,
                subtitle: '${scores['cardio']! > 100 ? '+' : ''}${(scores['cardio']! - 100).toInt()}% vs start',
                isPercentage: false,
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        FitnessScoreCard(
          title: 'Overall Performance',
          score: scores['overall']!,
          maxScore: 100,
          icon: Icons.trending_up,
          color: Colors.purple,
          subtitle: '${scores['overall']! > 100 ? '+' : ''}${(scores['overall']! - 100).toInt()}% improvement since starting',
          isPercentage: false,
        ),
      ],
    );
  }

  // --- Helper methods for real analytics ---
  DateTime? get _lastWorkoutDate {
    final allSessions = dataManager.workoutHistory.values.expand((s) => s).toList();
    if (allSessions.isEmpty) return null;
    allSessions.sort((a, b) => b.date.compareTo(a.date));
    return allSessions.first.date;
  }

  DateTime? get _firstWorkoutDate {
    final allSessions = dataManager.workoutHistory.values.expand((s) => s).toList();
    if (allSessions.isEmpty) return null;
    allSessions.sort((a, b) => a.date.compareTo(b.date));
    return allSessions.first.date;
  }

  Map<String, double> get _personalRecords {
    double bench = 0, squat = 0, deadlift = 0;
    int bestCardio = 0; // in minutes
    for (final sessions in dataManager.workoutHistory.values) {
      for (final s in sessions) {
        for (final e in s.exercises) {
          final name = e.name.toLowerCase();
          if (name.contains('bench')) {
            if (e.weight > bench) bench = e.weight;
          } else if (name.contains('squat')) {
            if (e.weight > squat) squat = e.weight;
          } else if (name.contains('deadlift')) {
            if (e.weight > deadlift) deadlift = e.weight;
          } else if (name.contains('run') || name.contains('cardio') || name.contains('treadmill') || name.contains('bike')) {
            if (s.durationMinutes > bestCardio) bestCardio = s.durationMinutes;
          }
        }
      }
    }
    return {
      'bench': bench,
      'squat': squat,
      'deadlift': deadlift,
      'cardio': bestCardio.toDouble(),
    };
  }

  Map<String, double> _getInitialLiftingPRs() {
    // Use the user's first workout for initial PRs, or fallback to 1 if not available
    double bench = 1, squat = 1, deadlift = 1;
    final firstDate = _firstWorkoutDate;
    if (firstDate != null) {
      final firstSessions = dataManager.workoutHistory.values.expand((s) => s).where((s) => s.date == firstDate).toList();
      for (final s in firstSessions) {
        for (final e in s.exercises) {
          final name = e.name.toLowerCase();
          if (name.contains('bench') && e.weight > bench) bench = e.weight;
          else if (name.contains('squat') && e.weight > squat) squat = e.weight;
          else if (name.contains('deadlift') && e.weight > deadlift) deadlift = e.weight;
        }
      }
    }
    return {'bench': bench, 'squat': squat, 'deadlift': deadlift};
  }

  double _calculateLiftingGrowth() {
    final current = _personalRecords;
    final initial = _getInitialLiftingPRs();
    double benchProgress = initial['bench']! > 0 ? current['bench']! / initial['bench']! : 1.0;
    double squatProgress = initial['squat']! > 0 ? current['squat']! / initial['squat']! : 1.0;
    double deadliftProgress = initial['deadlift']! > 0 ? current['deadlift']! / initial['deadlift']! : 1.0;
    double avgProgress = (benchProgress + squatProgress + deadliftProgress) / 3;
    return (avgProgress * 100).clamp(50, 200);
  }

  double _calculateCardioGrowth() {
    final current = _personalRecords['cardio'] ?? 0;
    double initial = 1;
    final firstDate = _firstWorkoutDate;
    if (firstDate != null) {
      final firstSessions = dataManager.workoutHistory.values.expand((s) => s).where((s) => s.date == firstDate).toList();
      for (final s in firstSessions) {
        if (s.durationMinutes > initial) initial = s.durationMinutes.toDouble();
      }
    }
    if (initial <= 0) initial = 1;
    double progress = current / initial;
    return (progress * 100).clamp(50, 200);
  }

  double _calculateWorkoutReadiness() {
    double sleepScore = 0;
    double recoveryScore = 0;
    double nutritionScore = 0;
    // Sleep Score (40% of readiness)
    double sleepHours = dataManager.hoursSlept;
    if (sleepHours >= 8.0) {
      sleepScore = 40;
    } else if (sleepHours >= 7.0) {
      sleepScore = 30 + (sleepHours - 7.0) * 10;
    } else if (sleepHours >= 6.0) {
      sleepScore = 15 + (sleepHours - 6.0) * 15;
    } else {
      sleepScore = sleepHours * 2.5;
    }
    // Recovery Score (35% of readiness) - days since last workout
    DateTime now = DateTime.now();
    DateTime? lastWorkout = _lastWorkoutDate;
    int daysSinceWorkout = lastWorkout != null ? now.difference(lastWorkout).inDays : 99;
    if (daysSinceWorkout == 1) {
      recoveryScore = 35;
    } else if (daysSinceWorkout == 0) {
      recoveryScore = 20;
    } else if (daysSinceWorkout == 2) {
      recoveryScore = 30;
    } else if (daysSinceWorkout >= 3) {
      recoveryScore = 25;
    }
    // Nutrition Score (25% of readiness)
    double calorieRatio = dataManager.caloriesConsumed / (dataManager.calorieGoal > 0 ? dataManager.calorieGoal : 1);
    if (calorieRatio >= 0.8 && calorieRatio <= 1.2) {
      nutritionScore = 25;
    } else if (calorieRatio >= 0.6 && calorieRatio <= 1.4) {
      nutritionScore = 20;
    } else {
      nutritionScore = 10;
    }
    return (sleepScore + recoveryScore + nutritionScore).clamp(0, 100);
  }

  Map<String, double> _calculateFitnessScores() {
    double readiness = _calculateWorkoutReadiness();
    double liftingGrowth = _calculateLiftingGrowth();
    double cardioGrowth = _calculateCardioGrowth();
    double overallGrowth = (liftingGrowth + cardioGrowth) / 2;
    return {
      'readiness': readiness,
      'lifting': liftingGrowth,
      'cardio': cardioGrowth,
      'overall': overallGrowth,
    };
  }

  Color _getReadinessColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getReadinessMessage(double score) {
    if (score >= 80) return 'Excellent! Ready for intense training';
    if (score >= 60) return 'Good condition, moderate intensity recommended';
    if (score >= 40) return 'Fair condition, light training suggested';
    return 'Low readiness, consider rest or recovery';
  }
}
