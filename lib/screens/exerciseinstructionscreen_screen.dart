import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';

class ExerciseInstructionScreen extends StatefulWidget {
  final Exercise exercise;
  final ExerciseProgress progress;
  final VoidCallback onCompleteRep;

  const ExerciseInstructionScreen({
    super.key,
    required this.exercise,
    required this.progress,
    required this.onCompleteRep,
  });

  @override
  State<ExerciseInstructionScreen> createState() => _ExerciseInstructionScreenState();
}

class _ExerciseInstructionScreenState extends State<ExerciseInstructionScreen> {
  ExerciseInstructions? instructions;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  Future<void> _loadInstructions() async {
    setState(() => isLoading = true);
    
    try {
      final loadedInstructions = await context.read<FitnessDataProvider>().getExerciseInstructions(widget.exercise.name);
      setState(() {
        instructions = loadedInstructions;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading instructions: $e')),
        );
      }
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.progress.isCompleted)
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                widget.onCompleteRep();
                Navigator.pop(context);
              },
              tooltip: 'Complete Rep',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : instructions == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Instructions not available',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Unable to load exercise instructions',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Info Header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.exercise.name,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Muscles: ${widget.exercise.muscles}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(instructions!.difficulty),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      instructions!.difficulty,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Workout Info
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${widget.exercise.sets}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Sets'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${widget.exercise.reps}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Reps'),
                                      ],
                                    ),
                                  ),
                                  if (widget.exercise.weight > 0)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '${widget.exercise.weight.toInt()} lbs',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (instructions!.equipment != 'None')
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Icon(Icons.fitness_center, size: 24),
                                          Text(
                                            instructions!.equipment,
                                            style: const TextStyle(fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Instructions Section
                      if (instructions!.steps.isNotEmpty) ...[
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...instructions!.steps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(step),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      
                      // Tips Section
                      if (instructions!.tips.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Tips',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...instructions!.tips.map((tip) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.amber[600]),
                                const SizedBox(width: 8),
                                Expanded(child: Text(tip)),
                              ],
                            ),
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),
    );
  }
}
