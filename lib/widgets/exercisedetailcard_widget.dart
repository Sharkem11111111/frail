import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';


class ExerciseDetailCard extends StatelessWidget {
  final ExerciseDetail exercise;

  const ExerciseDetailCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final dataManager = FitnessDataManager();
    final currentPreference = dataManager.exercisePreferences[exercise.name] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Row(
                  children: [
                    if (currentPreference != 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentPreference > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              currentPreference > 0 ? Icons.thumb_up : Icons.thumb_down,
                              size: 12,
                              color: currentPreference > 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${currentPreference.abs()}',
                              style: TextStyle(
                                color: currentPreference > 0 ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: currentPreference > 0 ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                                                 dataManager.likeExercise(
                           exercise.name,
                           _inferMuscleTargetsFromName(exercise.name),
                           exercise.sets,
                           exercise.reps,
                           exercise.weight,
                         );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${exercise.name} to favorites! 👍'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        color: currentPreference < 0 ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        dataManager.dislikeExercise(exercise.name);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Marked ${exercise.name} as disliked 👎'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailColumn('Sets', exercise.sets.toString()),
                _buildDetailColumn('Reps', exercise.reps.toString()),
                _buildDetailColumn(
                  'Weight', 
                  exercise.weight > 0 ? '${exercise.weight.toInt()} lbs' : 'Bodyweight'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _inferMuscleTargetsFromName(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('push') || name.contains('press') || name.contains('chest')) {
      return 'Chest, Triceps, Shoulders';
    } else if (name.contains('pull') || name.contains('row') || name.contains('back')) {
      return 'Back, Biceps';
    } else if (name.contains('squat') || name.contains('leg') || name.contains('thigh')) {
      return 'Legs, Glutes';
    } else if (name.contains('curl') || name.contains('bicep')) {
      return 'Biceps';
    } else if (name.contains('tricep') || name.contains('extension')) {
      return 'Triceps';
    } else if (name.contains('shoulder') || name.contains('deltoid')) {
      return 'Shoulders';
    } else if (name.contains('calf') || name.contains('raise')) {
      return 'Calves';
    } else if (name.contains('core') || name.contains('abs') || name.contains('plank')) {
      return 'Core';
    } else {
      return 'Full Body';
    }
  }
}
