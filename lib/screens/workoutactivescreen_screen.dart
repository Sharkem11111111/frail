import 'package:flutter/material.dart';
import 'dart:async';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';
import '../services/notification_service.dart';
import 'restscreen_screen.dart';

class WorkoutActiveScreen extends StatefulWidget {
  const WorkoutActiveScreen({super.key});

  @override
  State<WorkoutActiveScreen> createState() => _WorkoutActiveScreenState();
}

class _WorkoutActiveScreenState extends State<WorkoutActiveScreen> {
  final dataManager = FitnessDataManager();
  
  // Workout tracking - track progress for each exercise
  List<ExerciseProgress> exerciseProgress = [];
  Timer? _workoutTimer;
  int _workoutTimeElapsed = 0;
  bool _isTimerPaused = false;

  @override
  void initState() {
    super.initState();
    dataManager.onWorkoutChanged = () => setState(() {});
    
    // Initialize or restore progress tracking
    _initializeExerciseProgress();
    _startWorkoutTimer();
  }

  void _initializeExerciseProgress() {
    exerciseProgress = [];
    
    // If we have an active workout session, restore progress from saved data
    if (dataManager.hasActiveWorkout && dataManager.exerciseProgressData.isNotEmpty) {
      _workoutTimeElapsed = dataManager.workoutElapsedSeconds;
      
      for (int i = 0; i < dataManager.currentWorkout.length; i++) {
        final exercise = dataManager.currentWorkout[i];
        final progressData = dataManager.exerciseProgressData[i.toString()];
        
        if (progressData != null) {
          exerciseProgress.add(ExerciseProgress(
            exercise: exercise,
            currentSet: progressData['currentSet'] ?? 1,
            repsCompleted: progressData['repsCompleted'] ?? 0,
            setsCompleted: progressData['setsCompleted'] ?? 0,
            isCompleted: progressData['isCompleted'] ?? false,
          ));
        } else {
          // Fallback for missing data
          exerciseProgress.add(ExerciseProgress(
            exercise: exercise,
            currentSet: 1,
            repsCompleted: 0,
            setsCompleted: 0,
            isCompleted: false,
          ));
        }
      }
    } else {
      // Fresh workout - initialize all exercises
      exerciseProgress = dataManager.currentWorkout.map((exercise) => 
        ExerciseProgress(
          exercise: exercise,
          currentSet: 1,
          repsCompleted: 0,
          setsCompleted: 0,
          isCompleted: false,
        )
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataManager.currentWorkout.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Workout')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No workout loaded',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Generate an AI workout or create a custom one',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout'),
        actions: [
          IconButton(
            icon: Icon(_isTimerPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
            tooltip: _isTimerPaused ? 'Resume Timer' : 'Pause Timer',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearWorkout(context),
            tooltip: 'Clear Workout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Workout Timer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isTimerPaused) ...[
                      const Icon(
                        Icons.pause_circle_filled,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _formatTime(_workoutTimeElapsed),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  _isTimerPaused ? 'Workout Paused' : 'Total Workout Time',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Exercise List - Interactive Exercise Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exerciseProgress.length,
              itemBuilder: (context, index) {
                final progress = exerciseProgress[index];
                final exercise = progress.exercise;
                final isCompleted = progress.isCompleted;
                final currentProgress = progress.setsCompleted / exercise.sets;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  color: isCompleted ? Colors.green.withValues(alpha: 0.1) : null,
                  child: InkWell(
                    onTap: () => _showExerciseDetail(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Exercise Info
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isCompleted ? Colors.green : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${exercise.sets} sets × ${exercise.reps} reps${exercise.weight > 0 ? ' @ ${exercise.weight.toInt()} lbs' : ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Progress Bar
                                LinearProgressIndicator(
                                  value: currentProgress,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted ? Colors.green : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Progress Stats
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Set ${progress.currentSet}/${exercise.sets}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${progress.repsCompleted}/${exercise.reps} reps',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Action Buttons
                          Column(
                            children: [
                              // Complete Rep Button
                              SizedBox(
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: (isCompleted || _isTimerPaused) ? null : () => _completeRep(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted 
                                      ? Colors.green 
                                      : _isTimerPaused 
                                        ? Colors.grey 
                                        : Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    isCompleted 
                                      ? '✓ Done' 
                                      : _isTimerPaused 
                                        ? 'Paused'
                                        : '+1 Rep',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                              
                              // Too Heavy Button (only show for weighted exercises)
                              if (exercise.weight > 0 && !isCompleted && !_isTimerPaused) ...[
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 80,
                                  child: ElevatedButton(
                                    onPressed: () => _markTooHeavy(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'Too Heavy',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Complete Workout Button
          if (_isWorkoutComplete())
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isTimerPaused ? null : () => _completeWorkout(context),
                icon: const Icon(Icons.emoji_events),
                label: Text(_isTimerPaused ? 'Resume to Complete' : 'Complete Workout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: _isTimerPaused ? Colors.grey : Colors.amber,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Workout'),
        content: const Text('Are you sure you want to clear the current workout? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              dataManager.clearActiveWorkout(); // Clear the active session properly
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to main screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _completeWorkout(BuildContext context) {
    if (dataManager.currentWorkout.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercises to complete')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Workout Complete!'),
        content: Text('Congratulations! You completed ${dataManager.currentWorkout.length} exercises in ${_formatTime(_workoutTimeElapsed)}. Great job!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Yet'),
          ),
          TextButton(
            onPressed: () async {
              // Schedule muscle recovery notifications
              final notificationService = NotificationService();
              await notificationService.scheduleRecoveryNotificationsForWorkout(dataManager.currentWorkout);
              
              dataManager.completeWorkout(); // This will clear the active session
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to main screen
              
              // Show completion message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Workout completed! Rank: ${dataManager.getRankDisplayName()}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Complete', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // Timer Management Methods
  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (!_isTimerPaused) {
        setState(() {
          _workoutTimeElapsed++;
        });
        
        // Only save progress to disk every 10 seconds to reduce I/O lag
        if (_workoutTimeElapsed % 10 == 0) {
          dataManager.workoutElapsedSeconds = _workoutTimeElapsed;
          _saveExerciseProgress();
        }
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isTimerPaused = !_isTimerPaused;
    });
    
    if (_isTimerPaused) {
      // Save current progress when pausing
      _saveExerciseProgress();
    }
  }

  void _saveExerciseProgress() {
    // Save all exercise progress to persistent storage
    for (int i = 0; i < exerciseProgress.length; i++) {
      final progress = exerciseProgress[i];
      dataManager.updateWorkoutProgress(
        i,
        progress.currentSet,
        progress.repsCompleted,
        progress.setsCompleted,
        progress.isCompleted,
        _workoutTimeElapsed,
      );
    }
  }

  // Interactive Workout Control Methods
  void _markTooHeavy(int exerciseIndex) async {
    final progress = exerciseProgress[exerciseIndex];
    final exercise = progress.exercise;
    
    // Mark the exercise as too heavy and reduce weight for next time
    dataManager.markExerciseTooHeavy(exercise.name, exercise.weight);
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weight reduced for ${exercise.name}. Next time: ${(exercise.weight * 0.9).round()} lbs'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Record the session as incomplete due to weight being too heavy
    dataManager.recordWorkoutSession(
      exercise.name,
      exercise.weight,
      exercise.sets,
      exercise.reps,
      progress.setsCompleted,
      progress.repsCompleted,
      true, // wasTooHeavy
      _workoutTimeElapsed,
    );

    // Navigate to rest screen after marking as too heavy
    final restDuration = _getRestDuration(exercise);
    
    // Show loading indicator first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
    
    // Store context before async operations
    final currentContext = context;
    
    // Small delay to prevent UI freeze, then navigate
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      Navigator.pop(currentContext); // Close loading dialog
      
      await Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => RestScreen(
            duration: restDuration,
            exerciseName: exercise.name,
          ),
        ),
      );
    }
  }
  
  void _completeRep(int exerciseIndex) async {
    final progress = exerciseProgress[exerciseIndex];
    final exercise = progress.exercise;
    
    setState(() {
      progress.repsCompleted++;
      
      // Check if set is completed
      if (progress.repsCompleted >= exercise.reps) {
        progress.setsCompleted++;
        progress.repsCompleted = 0;
        progress.currentSet++;
        
        // Check if exercise is completed
        if (progress.setsCompleted >= exercise.sets) {
          progress.isCompleted = true;
          
          // Record successful workout session when exercise is completed
          dataManager.recordWorkoutSession(
            exercise.name,
            exercise.weight,
            exercise.sets,
            exercise.reps,
            progress.setsCompleted,
            progress.repsCompleted,
            false, // wasTooHeavy
            _workoutTimeElapsed,
          );
          
          // Check if we should suggest weight increase
          if (dataManager.shouldIncreaseWeight(exercise.name)) {
            final increase = dataManager.getSafeWeightIncrease(exercise.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Great progress! Consider increasing ${exercise.name} to ${(exercise.weight + increase).round()} lbs next time'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    });

    // Save progress to persistent storage
    dataManager.updateWorkoutProgress(
      exerciseIndex,
      progress.currentSet,
      progress.repsCompleted,
      progress.setsCompleted,
      progress.isCompleted,
      _workoutTimeElapsed,
    );

    // Navigate to rest screen after completing a rep
    if (!progress.isCompleted) {
      final restDuration = _getRestDuration(exercise);
      
      // Show loading indicator first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
      
      // Store context before async operations
      final currentContext = context;
      
      // Small delay to prevent UI freeze, then navigate
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        Navigator.pop(currentContext); // Close loading dialog
        
        await Navigator.push(
          currentContext,
          MaterialPageRoute(
            builder: (context) => RestScreen(
              duration: restDuration,
              exerciseName: exercise.name,
            ),
          ),
        );
      }
    }
  }

  void _showExerciseDetail(int exerciseIndex) {
    final progress = exerciseProgress[exerciseIndex];
    final exercise = progress.exercise;
    
    // For now, just show a simple dialog since ExerciseInstructionScreen is not implemented
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: Text('Exercise: ${exercise.name}\nSets: ${exercise.sets}\nReps: ${exercise.reps}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isWorkoutComplete() {
    return exerciseProgress.every((progress) => progress.isCompleted);
  }

  // Helper Methods
  int _getRestDuration(Exercise exercise) {
    final name = exercise.name.toLowerCase();
    final muscles = exercise.muscles.toLowerCase();
    
    // Hardcore exercises get 90 seconds rest
    if (name.contains('deadlift') || 
        name.contains('squat') || 
        name.contains('bench press') ||
        name.contains('pull-up') ||
        name.contains('chin-up') ||
        muscles.contains('legs') && exercise.weight > 0 ||
        exercise.weight > 50) {
      return 90; // 90 seconds for hardcore exercises
    }
    
    // Standard exercises get 60 seconds rest
    return 60; // 60 seconds for standard exercises
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    dataManager.onWorkoutChanged = null;
    super.dispose();
  }
}
