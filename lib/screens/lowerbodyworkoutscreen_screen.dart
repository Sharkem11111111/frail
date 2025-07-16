import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';
import 'workoutactivescreen_screen.dart';

class LowerBodyWorkoutScreen extends StatefulWidget {
  const LowerBodyWorkoutScreen({super.key});

  @override
  State<LowerBodyWorkoutScreen> createState() => _LowerBodyWorkoutScreenState();
}

class _LowerBodyWorkoutScreenState extends State<LowerBodyWorkoutScreen> {
  List<Exercise> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _generateRecommendedWorkout();
  }

  void _generateRecommendedWorkout() {
    selectedExercises.clear();
    
    // Add favorite lower body exercises if available
    selectedExercises.addAll(context.watch<FitnessDataProvider>().lowerBodyFavorites.take(3));
    
    // Fill with default lower body exercises if needed
    if (selectedExercises.length < 4) {
      final defaults = [
        Exercise('Squats', 'Legs, Glutes')..sets = 3..reps = 15,
        Exercise('Lunges', 'Legs, Glutes')..sets = 3..reps = 12,
        Exercise('Glute Bridges', 'Glutes, Hamstrings')..sets = 3..reps = 15,
        Exercise('Calf Raises', 'Calves')..sets = 3..reps = 20,
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
    final availableMuscles = context.watch<FitnessDataProvider>().getAvailableMuscles();
    final lowerBodyMuscles = ['legs', 'glutes', 'calves'];
    final readyLowerMuscles = availableMuscles.where((m) => lowerBodyMuscles.contains(m)).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lower Body Workout'),
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
                      'Lower Body Focus',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (readyLowerMuscles.isNotEmpty) ...[
                      Text(
                        '✅ Ready to train: ${readyLowerMuscles.join(', ')}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ] else ...[
                      const Text(
                        '⏳ Lower body muscles still recovering',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'This workout includes ${context.watch<FitnessDataProvider>().lowerBodyFavorites.length} of your favorite lower body exercises.',
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
                final isFavorite = context.watch<FitnessDataProvider>().lowerBodyFavorites.any((e) => e.name == exercise.name);
                
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
    context.read<FitnessDataProvider>().currentWorkout = selectedExercises;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutActiveScreen()),
    );
  }
}
