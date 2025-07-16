import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'aiworkoutgeneratorscreen_screen.dart';
import 'workoutactivescreen_screen.dart';
import 'lowerbodyworkoutscreen_screen.dart';
import 'upperbodyworkoutscreen_screen.dart';
import 'customworkoutscreen_screen.dart';
import 'rankingscreen_screen.dart';
import 'caloriescreen_screen.dart';
import 'sleepscreen_screen.dart';
import 'historyscreen_screen.dart';
import 'progressscreen_screen.dart';
import 'gamesmenuscreen_screen.dart';
import 'aitrainerchatscreen_screen.dart';
import 'userinfocard_screen.dart';
import 'fitnessscoresection_screen.dart';
import '../widgets/fitnessrankbadge_widget.dart';
import '../widgets/musclerecoverycard_widget.dart';
import '../widgets/workoutcard_widget.dart';
import '../models/fitness_models.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // No singleton callbacks needed with Provider
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<FitnessDataProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resume Active Workout Banner
            if (dataProvider.hasActiveWorkout) ...[
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WorkoutActiveScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resume Active Workout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '${dataProvider.currentWorkout.length} exercises • In progress',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Welcome Section with Rank
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RankingScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataProvider.hasActiveWorkout 
                                ? 'Keep up the great work!' 
                                : 'Ready to get strong?',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dataProvider.hasActiveWorkout 
                                ? 'Resume your workout or start a new one.'
                                : 'Choose your workout type and let\'s build some muscle!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const FitnessRankBadge(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Muscle Recovery Status
            const MuscleRecoveryCard(),
            const SizedBox(height: 24),
            
            // Quick Start Section
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Workout Options Grid - Fixed height to ensure proper display
            SizedBox(
              height: 400, // Fixed height for the grid
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling since parent scrolls
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  WorkoutCard(
                    title: 'Start Workout',
                    subtitle: 'AI-generated routine',
                    icon: Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AIWorkoutGeneratorScreen()),
                    ),
                  ),
                  WorkoutCard(
                    title: 'Custom Workout',
                    subtitle: 'Build your own',
                    icon: Icons.build,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomWorkoutScreen()),
                    ),
                  ),
                  WorkoutCard(
                    title: 'Upper Body',
                    subtitle: 'Arms, chest, back',
                    icon: Icons.accessibility_new,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpperBodyWorkoutScreen()),
                    ),
                  ),
                  WorkoutCard(
                    title: 'Lower Body',
                    subtitle: 'Legs, glutes, core',
                    icon: Icons.directions_run,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LowerBodyWorkoutScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Extra padding at bottom
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// WorkoutCard and MuscleRecoveryCard widgets defined in widgets/ directory
