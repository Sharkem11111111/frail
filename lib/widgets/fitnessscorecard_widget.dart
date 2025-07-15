import 'package:flutter/material.dart';


class FitnessScoreCard extends StatelessWidget {
  final String title;
  final double score;
  final double maxScore;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isPercentage;
  final bool isCompact;

  const FitnessScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isPercentage = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    double displayValue = isPercentage ? score : (score > maxScore ? score : score);
    double progressValue = isPercentage ? score / maxScore : (score > maxScore ? 1.0 : score / maxScore);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isCompact ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: isCompact ? 14 : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: isCompact ? 4 : 6,
            ),
            const SizedBox(height: 8),
            
            // Score and subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${displayValue.toInt()}${isPercentage ? '%' : '%'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: isCompact ? 18 : null,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isCompact) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
