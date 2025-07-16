import 'package:flutter/material.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';
import 'package:provider/provider.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {

  double _getAverageSleep(List<SleepEntry> weekSleep) {
    final trackedDays = weekSleep.where((sleep) => sleep.hours > 0).toList();
    if (trackedDays.isEmpty) return 0.0;
    final totalHours = trackedDays.fold(0.0, (sum, sleep) => sum + sleep.hours);
    return totalHours / trackedDays.length;
  }

  int _getDaysTracked(List<SleepEntry> weekSleep) {
    return weekSleep.where((sleep) => sleep.hours > 0).length;
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<FitnessDataProvider>();
    double sleepProgress = (dataProvider.sleepGoal > 0 && dataProvider.hoursSlept >= 0 && dataProvider.hoursSlept.isFinite)
        ? (dataProvider.hoursSlept / dataProvider.sleepGoal).clamp(0.0, 1.0)
        : 0.0;
    
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
                      '${(dataProvider.hoursSlept.isFinite && dataProvider.hoursSlept >= 0) ? dataProvider.hoursSlept : 0}h',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'Goal: ${dataProvider.sleepGoal}h',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Weekly Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Average Sleep',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${_getAverageSleep(dataProvider.weekSleep).toStringAsFixed(1)}h',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Days Tracked',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${_getDaysTracked(dataProvider.weekSleep)}/7',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Sleep Log Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final hours = await showDialog<double>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();
                        return AlertDialog(
                          title: const Text('Log Sleep'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Hours slept',
                              hintText: 'e.g. 7.5',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final value = double.tryParse(controller.text);
                                if (value != null && value > 0 && value <= 24) {
                                  Navigator.pop(context, value);
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                    if (hours != null) {
                      final dataProvider = context.read<FitnessDataProvider>();
                      dataProvider.logSleep(hours);
                    }
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
                itemCount: dataProvider.weekSleep.length,
                itemBuilder: (context, index) {
                  final sleep = dataProvider.weekSleep[index];
                  final isGoodSleep = sleep.hours >= dataProvider.sleepGoal;
                  
                  // Check if this is today
                  final now = DateTime.now();
                  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                  final todayIndex = (now.weekday - 1) % 7;
                  final isToday = index == todayIndex;
                  
                  return Card(
                    color: isToday ? Colors.blue.withOpacity(0.1) : null,
                    child: ListTile(
                      leading: Icon(
                        isToday ? Icons.today : Icons.bedtime,
                        color: isToday 
                            ? Colors.blue 
                            : (isGoodSleep ? Colors.green : Colors.orange),
                      ),
                      title: Row(
                        children: [
                          Text(sleep.day),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: sleep.hours > 0 
                          ? Text(
                              isGoodSleep 
                                  ? 'Great sleep! 👍' 
                                  : 'Below goal - aim for ${dataProvider.sleepGoal}h',
                              style: TextStyle(
                                color: isGoodSleep ? Colors.green : Colors.orange,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: Text(
                        '${sleep.hours}h',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isToday 
                              ? Colors.blue 
                              : (isGoodSleep ? Colors.green : Colors.orange),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
