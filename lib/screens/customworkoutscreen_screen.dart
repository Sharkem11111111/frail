import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';
import 'workoutbuilderscreen_screen.dart';
import 'workoutactivescreen_screen.dart';

class CustomWorkoutScreen extends StatefulWidget {
  const CustomWorkoutScreen({super.key});

  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final dataManager = FitnessDataManager();
  List<Exercise> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewWorkout,
            tooltip: 'Create New Workout',
          ),
          if (selectedExercises.isNotEmpty)
            TextButton(
              onPressed: _startWorkout,
              child: const Text('Start', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Exercise Pool', icon: Icon(Icons.fitness_center)),
                Tab(text: 'Saved Workouts', icon: Icon(Icons.bookmark)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExercisePoolTab(),
                  _buildSavedWorkoutsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisePoolTab() {
    return dataManager.customWorkoutPool.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No custom exercises yet!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete workouts and like exercises\nto build your custom workout pool',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Build Your Workout',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select exercises from your favorites. These are exercises you\'ve liked from previous workouts.',
                          style: TextStyle(color: Colors.grey[600]),
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dataManager.customWorkoutPool.length,
                  itemBuilder: (context, index) {
                    final exercise = dataManager.customWorkoutPool[index];
                    final isSelected = selectedExercises.any((e) => e.name == exercise.name);
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
          );
  }

  Widget _buildSavedWorkoutsTab() {
    return dataManager.savedWorkouts.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No saved workouts yet!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first workout by tapping the + button',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataManager.savedWorkouts.length,
            itemBuilder: (context, index) {
              final workout = dataManager.savedWorkouts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(workout.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${workout.exercises.length} exercises'),
                      if (workout.description.isNotEmpty)
                        Text(
                          workout.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text(
                        'Created: ${_formatDate(workout.createdDate)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _startSavedWorkout(workout.id),
                        tooltip: 'Start Workout',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSavedWorkout(workout.id),
                        tooltip: 'Delete Workout',
                      ),
                    ],
                  ),
                  onTap: () => _showWorkoutDetails(workout),
                ),
              );
            },
          );
  }

  void _createNewWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutBuilderScreen(
          availableExercises: dataManager.customWorkoutPool,
        ),
      ),
    ).then((_) => setState(() {})); // Refresh after returning
  }

  void _startSavedWorkout(String workoutId) {
    dataManager.loadWorkout(workoutId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutActiveScreen()),
    );
  }

  void _deleteSavedWorkout(String workoutId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              dataManager.deleteWorkout(workoutId);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(SavedWorkout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(workout.name),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (workout.description.isNotEmpty) ...[
                Text(workout.description),
                const SizedBox(height: 16),
              ],
              const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...workout.exercises.map((exercise) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${exercise.name} - ${exercise.sets} sets × ${exercise.reps} reps',
                  style: const TextStyle(fontSize: 14),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSavedWorkout(workout.id);
            },
            child: const Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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
