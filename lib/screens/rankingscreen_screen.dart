import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';
import '../widgets/rankingrulecard_widget.dart';
import '../widgets/rankcard_widget.dart';
import 'package:provider/provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  FitnessDataProvider get dataProvider => context.watch<FitnessDataProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Rankings'),
        backgroundColor: dataProvider.getRankColor(),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Rank Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    dataProvider.getRankColor(),
                    dataProvider.getRankColor().withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    dataProvider.getRankIconPath(),
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dataProvider.getRankDisplayName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dataProvider.totalWorkoutsCompleted} Workouts Completed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress to next rank
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Next Promotion',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (5 - dataProvider.getWorkoutsUntilPromotion()) / 5,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dataProvider.getWorkoutsUntilPromotion()} workouts remaining',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Rank System Explanation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Rankings Work',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const RankingRuleCard(
                        icon: Icons.trending_up,
                        title: 'Promotion',
                        description: 'Complete 5 workouts to advance one division',
                        color: Colors.green,
                      ),
                      const RankingRuleCard(
                        icon: Icons.trending_down,
                        title: 'Demotion',
                        description: 'No workouts for 7+ days drops you one division',
                        color: Colors.red,
                      ),
                      const RankingRuleCard(
                        icon: Icons.flag,
                        title: 'Starting Point',
                        description: 'Everyone begins at Tin III and works their way up',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // All Ranks Display
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Ranks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...FitnessRank.values.map((rank) => RankCard(
                    rank: rank,
                    isCurrentRank: rank == dataProvider.currentRank,
                    isAchieved: _isRankAchieved(rank),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isRankAchieved(FitnessRank rank) {
    return FitnessRank.values.indexOf(rank) >= FitnessRank.values.indexOf(dataProvider.currentRank);
  }
}
