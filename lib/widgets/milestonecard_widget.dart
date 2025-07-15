import 'package:flutter/material.dart';


class MilestoneCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeframe;
  final int targetDays;
  final int currentDays;
  final IconData icon;
  final Color color;
  final String description;
  final bool isLongTerm;

  const MilestoneCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeframe,
    required this.targetDays,
    required this.currentDays,
    required this.icon,
    required this.color,
    required this.description,
    this.isLongTerm = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = currentDays >= targetDays;
    final progress = isLongTerm 
        ? (currentDays >= targetDays ? 1.0 : currentDays / targetDays)
        : (currentDays >= targetDays ? 1.0 : currentDays / targetDays);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isCompleted ? color : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCompleted ? color : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? color : color.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? 'Achieved!' : timeframe,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? color : Colors.grey[600],
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Milestone Reached!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}% Progress',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
