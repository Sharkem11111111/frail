import 'package:flutter/material.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'userinfoscreen_screen.dart';
import 'package:provider/provider.dart';

class UserInfoCard extends StatefulWidget {
  const UserInfoCard({super.key});

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  FitnessDataProvider get dataProvider => context.watch<FitnessDataProvider>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserInfoScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  dataProvider.username.isNotEmpty ? dataProvider.username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataProvider.username.isNotEmpty ? dataProvider.username : 'Set up your profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      dataProvider.currentWeight > 0 
                          ? '${dataProvider.currentWeight.toInt()} lbs • ${dataProvider.fitnessGoal}'
                          : 'Tap to add your information',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (dataProvider.currentWeight > 0 && dataProvider.goalWeight > 0)
                      Text(
                        dataProvider.getWeightProgressText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
