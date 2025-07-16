import 'package:flutter/material.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'package:provider/provider.dart';
import 'workoutactivescreen_screen.dart';

class WorkoutPreviewScreen extends StatelessWidget {
  const WorkoutPreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<FitnessDataProvider>();
    final exercises = dataProvider.currentWorkout;
    final purple = const Color(0xFF7C3AED);
    final purpleDark = const Color(0xFF5B21B6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Preview', style: TextStyle(color: Colors.white)),
        backgroundColor: purpleDark,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [purpleDark, purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your AI-Generated Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${exercises.length} exercises',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: exercises.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises found.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ex = exercises[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: purpleDark.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: purple,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              ex.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (ex.muscles.isNotEmpty)
                                  Text(
                                    ex.muscles,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ex.sets} sets × ${ex.reps} reps${ex.weight > 0 ? ' @ ${ex.weight.toInt()} lbs' : ' @ bodyweight'}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleDark,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  label: const Text('Start Workout'),
                  onPressed: exercises.isEmpty
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WorkoutActiveScreen(),
                            ),
                          );
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
