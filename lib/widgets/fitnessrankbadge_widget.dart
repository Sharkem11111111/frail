import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';

class FitnessRankBadge extends StatefulWidget {
  const FitnessRankBadge({super.key});

  @override
  State<FitnessRankBadge> createState() => _FitnessRankBadgeState();
}

class _FitnessRankBadgeState extends State<FitnessRankBadge> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.watch<FitnessDataProvider>().getRankColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.watch<FitnessDataProvider>().getRankColor(), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                context.watch<FitnessDataProvider>().getRankIconPath(),
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Text(
                context.watch<FitnessDataProvider>().getRankDisplayName(),
                style: TextStyle(
                  color: context.watch<FitnessDataProvider>().getRankColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to view ranks',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
