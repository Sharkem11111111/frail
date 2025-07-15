import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import 'workoutactivescreen_screen.dart';
import 'aiworkoutgeneratorscreen_screen.dart';


class WorkoutPreviewScreen extends StatelessWidget {
  const WorkoutPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = FitnessDataManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Generated'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Success Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.green.withOpacity(0.7)],
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  '🤖 AI Workout Generated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${dataManager.currentWorkout.length} exercises ready for you',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // Exercise Preview
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataManager.currentWorkout.length,
              itemBuilder: (context, index) {
                final exercise = dataManager.currentWorkout[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(exercise.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.muscles),
                        Text(
                          '${exercise.sets} sets × ${exercise.reps} reps${exercise.weight > 0 ? ' @ ${exercise.weight.toInt()} lbs' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      dataManager.startActiveWorkout(); // Start persistent workout session
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const WorkoutActiveScreen()),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Workout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AIWorkoutGeneratorScreen()),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate New'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          dataManager.clearActiveWorkout(); // Properly clear the workout
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
