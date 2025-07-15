import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  final List<Exercise> availableExercises;

  const WorkoutBuilderScreen({super.key, required this.availableExercises});

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  final _workoutNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Exercise> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Workout'),
        actions: [
          TextButton(
            onPressed: selectedExercises.isNotEmpty ? _saveWorkout : null,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: widget.availableExercises.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No exercises available!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Like exercises from workout history\nto add them to your exercise pool',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Workout Info Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _workoutNameController,
                            decoration: const InputDecoration(
                              labelText: 'Workout Name',
                              hintText: 'e.g., "Upper Body Blast"',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              hintText: 'Brief description of this workout',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Selected: ${selectedExercises.length} exercises',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Exercise Selection
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.availableExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = widget.availableExercises[index];
                      final isSelected = selectedExercises.any((e) => e.name == exercise.name);
                      final dataManager = FitnessDataManager();
                      final preferenceScore = dataManager.exercisePreferences[exercise.name] ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                final newExercise = Exercise(exercise.name, exercise.muscles);
                                newExercise.sets = exercise.sets;
                                newExercise.reps = exercise.reps;
                                newExercise.weight = exercise.weight;
                                selectedExercises.add(newExercise);
                              } else {
                                selectedExercises.removeWhere((e) => e.name == exercise.name);
                              }
                            });
                          },
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
                          secondary: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.thumb_up, size: 12, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  '$preferenceScore',
                                  style: const TextStyle(color: Colors.green, fontSize: 12),
                                ),
                              ],
                            ),
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

  void _saveWorkout() {
    if (_workoutNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }

    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise')),
      );
      return;
    }

    final dataManager = FitnessDataManager();
    dataManager.saveWorkout(
      _workoutNameController.text.trim(),
      selectedExercises,
      description: _descriptionController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout "${_workoutNameController.text.trim()}" saved!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
