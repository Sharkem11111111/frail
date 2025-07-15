import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';
import 'workoutactivescreen_screen.dart';

class UpperBodyWorkoutScreen extends StatefulWidget {
  const UpperBodyWorkoutScreen({super.key});

  @override
  State<UpperBodyWorkoutScreen> createState() => _UpperBodyWorkoutScreenState();
}

class _UpperBodyWorkoutScreenState extends State<UpperBodyWorkoutScreen> {
  final dataManager = FitnessDataManager();
  List<Exercise> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _generateRecommendedWorkout();
  }

  void _generateRecommendedWorkout() {
    selectedExercises.clear();
    
    // Add favorite upper body exercises if available
    selectedExercises.addAll(dataManager.upperBodyFavorites.take(3));
    
    // Fill with default upper body exercises if needed
    if (selectedExercises.length < 4) {
      final defaults = [
        Exercise('Push-ups', 'Chest, Triceps, Shoulders')..sets = 3..reps = 12,
        Exercise('Pull-ups', 'Back, Biceps')..sets = 3..reps = 8,
        Exercise('Shoulder Press', 'Shoulders, Triceps')..sets = 3..reps = 10,
        Exercise('Bicep Curls', 'Biceps')..sets = 3..reps = 12,
      ];
      
      for (final defaultEx in defaults) {
        if (!selectedExercises.any((e) => e.name == defaultEx.name)) {
          selectedExercises.add(defaultEx);
          if (selectedExercises.length >= 4) break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMuscles = dataManager.getAvailableMuscles();
    final upperBodyMuscles = ['chest', 'back', 'shoulders', 'biceps', 'triceps', 'forearms'];
    final readyUpperMuscles = availableMuscles.where((m) => upperBodyMuscles.contains(m)).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upper Body Workout'),
        actions: [
          TextButton(
            onPressed: _startWorkout,
            child: const Text('Start', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Muscle Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upper Body Focus',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (readyUpperMuscles.isNotEmpty) ...[
                      Text(
                        '✅ Ready to train: ${readyUpperMuscles.join(', ')}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ] else ...[
                      const Text(
                        '⏳ Upper body muscles still recovering',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'This workout includes ${dataManager.upperBodyFavorites.length} of your favorite upper body exercises.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Exercise List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: selectedExercises.length,
              itemBuilder: (context, index) {
                final exercise = selectedExercises[index];
                final isFavorite = dataManager.upperBodyFavorites.any((e) => e.name == exercise.name);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isFavorite ? Icons.favorite : Icons.fitness_center,
                      color: isFavorite ? Colors.red : Theme.of(context).primaryColor,
                    ),
                    title: Text(exercise.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.muscles),
                        Text(
                          '${exercise.sets} sets × ${exercise.reps} reps @ ${exercise.weight > 0 ? '${exercise.weight.toInt()} lbs' : 'bodyweight'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editExercise(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => selectedExercises.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editExercise(int index) {
    // Simple edit for sets/reps/weight - basic implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${selectedExercises[index].name}'),
        content: const Text('Exercise editing coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startWorkout() {
    dataManager.currentWorkout = selectedExercises;
    dataManager.onWorkoutChanged?.call();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutActiveScreen()),
    );
  }
}
