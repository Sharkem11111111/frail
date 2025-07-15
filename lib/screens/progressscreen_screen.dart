import 'package:flutter/material.dart';
import '../widgets/milestonecard_widget.dart';


class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Simulated user start date (2 weeks ago)
  final DateTime userStartDate = DateTime.now().subtract(const Duration(days: 14));
  final int totalWorkouts = 6; // From our sample data
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final daysSinceStart = DateTime.now().difference(userStartDate).inDays;
    final weeksSinceStart = (daysSinceStart / 7).floor();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Journey', icon: Icon(Icons.timeline)),
            Tab(text: 'Recommendations', icon: Icon(Icons.trending_up)),
            Tab(text: 'Weight Progress', icon: Icon(Icons.monitor_weight)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJourneyTab(daysSinceStart),
          _buildRecommendationsTab(daysSinceStart, weeksSinceStart),
          _buildWeightProgressTab(),
        ],
      ),
    );
  }

  Widget _buildJourneyTab(int daysSinceStart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journey Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Fitness Journey',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _buildJourneyStatColumn('Days Active', daysSinceStart.toString()),
                      ),
                      Expanded(
                        child: _buildJourneyStatColumn('Workouts Done', totalWorkouts.toString()),
                      ),
                      Expanded(
                        child: _buildJourneyStatColumn('Current Phase', _getCurrentPhase(daysSinceStart)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Transformation Milestones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          // Milestones List
          Column(
            children: [
                MilestoneCard(
                  title: 'Neurological Adaptation',
                  subtitle: 'Improved muscle activation & coordination',
                  timeframe: '1-2 weeks',
                  targetDays: 14,
                  currentDays: daysSinceStart,
                  icon: Icons.psychology,
                  color: Colors.blue,
                  description: 'Your nervous system learns to recruit muscles more efficiently.',
                ),
                MilestoneCard(
                  title: 'Performance Gains',
                  subtitle: 'Noticeable strength & endurance increases',
                  timeframe: '2-4 weeks',
                  targetDays: 28,
                  currentDays: daysSinceStart,
                  icon: Icons.trending_up,
                  color: Colors.green,
                  description: 'You can lift heavier weights and have better workout endurance.',
                ),
                MilestoneCard(
                  title: 'Visual Changes',
                  subtitle: 'Muscle definition & posture improvements',
                  timeframe: '4-8 weeks',
                  targetDays: 56,
                  currentDays: daysSinceStart,
                  icon: Icons.visibility,
                  color: Colors.orange,
                  description: 'First visible changes in muscle tone and body composition.',
                ),
                MilestoneCard(
                  title: 'Significant Growth',
                  subtitle: 'Clear muscle hypertrophy & fat loss',
                  timeframe: '8-16 weeks',
                  targetDays: 112,
                  currentDays: daysSinceStart,
                  icon: Icons.fitness_center,
                  color: Colors.purple,
                  description: 'Major improvements that others will notice.',
                ),
                MilestoneCard(
                  title: 'Major Transformation',
                  subtitle: 'Substantial muscle mass & strength',
                  timeframe: '16+ weeks',
                  targetDays: 112,
                  currentDays: daysSinceStart,
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                  description: 'Complete body recomposition and dramatic improvements.',
                  isLongTerm: true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildJourneyStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getCurrentPhase(int days) {
    if (days < 14) return 'Adaptation';
    if (days < 28) return 'Performance';
    if (days < 56) return 'Visual';
    if (days < 112) return 'Growth';
    return 'Transformation';
  }

  Widget _buildRecommendationsTab(int daysSinceStart, int weeksSinceStart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Week Goals Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Week ${weeksSinceStart + 1} Goals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Evidence-based progressive overload guidelines from ACSM and recent research:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Progressive Overload Suggestions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          // Recommendations List
          Column(
            children: [
              _buildRecommendationCard('Increase Weight', 'Add 2.5-5 lbs to your main lifts each week if you can complete all sets with good form.'),
              _buildRecommendationCard('Add Reps', 'Increase reps by 1-2 per set for bodyweight or lighter exercises.'),
              _buildRecommendationCard('Reduce Rest', 'Shorten rest periods by 10-15 seconds to increase intensity.'),
              _buildRecommendationCard('Try New Variations', 'Incorporate new exercises or advanced variations to challenge your muscles.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProgressTab() {
    // Placeholder for weight progress chart
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor_weight, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Weight progress chart coming soon!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Track your weight changes and see your progress over time.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
