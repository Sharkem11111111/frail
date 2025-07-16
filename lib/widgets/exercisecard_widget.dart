import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';


class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onUpdate;
  final bool showLikeButton;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onUpdate,
    this.showLikeButton = true,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    final dataManager = context.watch<FitnessDataProvider>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.showLikeButton)
                  IconButton(
                    icon: Icon(
                      dataManager.exercisePreferences[widget.exercise.name] == 1
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: dataManager.exercisePreferences[widget.exercise.name] == 1
                          ? Colors.red
                          : null,
                    ),
                    onPressed: () {
                      setState(() {
                        dataManager.toggleExercisePreference(widget.exercise.name);
                      });
                      widget.onUpdate();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.exercise.muscles,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExerciseDetail('Sets', '${widget.exercise.sets}'),
                _buildExerciseDetail('Reps', '${widget.exercise.reps}'),
                _buildExerciseDetail('Weight', widget.exercise.weight > 0 
                    ? '${widget.exercise.weight.toInt()} lbs' 
                    : 'Bodyweight'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
