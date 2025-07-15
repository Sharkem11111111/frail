import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';


class MuscleRecoveryCard extends StatelessWidget {
  const MuscleRecoveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = FitnessDataManager();
    final availableMuscles = dataManager.getAvailableMuscles();
    final recoveringMuscles = dataManager.getRecoveringMuscles();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.healing,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Muscle Recovery Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (availableMuscles.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ready to train:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Wrap(
                          spacing: 4,
                          children: availableMuscles.map((muscle) => Chip(
                            label: Text(
                              muscle.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.green.withOpacity(0.1),
                            side: const BorderSide(color: Colors.green),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            
            if (availableMuscles.isNotEmpty && recoveringMuscles.isNotEmpty)
              const SizedBox(height: 8),
            
            if (recoveringMuscles.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule, color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Still recovering:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Wrap(
                          spacing: 4,
                          children: recoveringMuscles.map((muscle) => Chip(
                            label: Text(
                              muscle.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            side: const BorderSide(color: Colors.orange),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            
            if (availableMuscles.isEmpty && recoveringMuscles.isEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 6),
                  Text('All muscles are ready for training!'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
