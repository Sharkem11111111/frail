import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final FitnessDataManager dataManager = FitnessDataManager();

  @override
  void initState() {
    super.initState();
    dataManager.onSleepChanged = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    double sleepProgress = dataManager.hoursSlept / dataManager.sleepGoal;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Last Night\'s Sleep',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(
                      value: sleepProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${dataManager.hoursSlept}h',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'Goal: ${dataManager.sleepGoal}h',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sleep Log Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Log sleep feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Sleep'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sleep History
            Expanded(
              child: ListView.builder(
                itemCount: dataManager.weekSleep.length,
                itemBuilder: (context, index) {
                  final sleep = dataManager.weekSleep[index];
                  final isGoodSleep = sleep.hours >= dataManager.sleepGoal;
                  
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.bedtime,
                        color: isGoodSleep ? Colors.green : Colors.orange,
                      ),
                      title: Text(sleep.day),
                      trailing: Text(
                        '${sleep.hours}h',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isGoodSleep ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepEntry {
  final String day;
  final double hours;
  
  SleepEntry(this.day, this.hours);
}
