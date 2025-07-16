import 'package:flutter/material.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'package:provider/provider.dart';

class WorkoutActiveScreen extends StatefulWidget {
  const WorkoutActiveScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutActiveScreen> createState() => _WorkoutActiveScreenState();
}

class _WorkoutActiveScreenState extends State<WorkoutActiveScreen> {
  late List<_ExerciseProgress> _progress;
  final Color purple = const Color(0xFF7C3AED);
  final Color purpleDark = const Color(0xFF5B21B6);

  @override
  void initState() {
    super.initState();
    // Do not use Provider here!
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final dataProvider = context.watch<FitnessDataProvider>();
      _progress = dataProvider.currentWorkout.map((ex) => _ExerciseProgress(ex)).toList();
      _initialized = true;
    }
  }

  void _completeRep(int exIdx) {
    setState(() {
      _progress[exIdx].completeRep();
    });
  }

  void _tooHeavy(int exIdx) {
    setState(() {
      _progress[exIdx].completeRep();
      _progress[exIdx].reduceWeight();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight will be reduced for next set.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool get _allDone => _progress.every((p) => p.isComplete);

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<FitnessDataProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout', style: TextStyle(color: Colors.white)),
        backgroundColor: purpleDark,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _progress.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final prog = _progress[idx];
                  final ex = prog.exercise;
                  return Container(
                    decoration: BoxDecoration(
                      color: purpleDark.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          if (ex.muscles.isNotEmpty)
                            Text(
                              ex.muscles,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Set ${prog.currentSet + 1} of ${ex.sets}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Rep ${prog.currentRep + 1} of ${ex.reps}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Weight: ${prog.currentWeight > 0 ? '${prog.currentWeight.toInt()} lbs' : 'Bodyweight'}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Rep Completed'),
                                  onPressed: prog.isComplete ? null : () => _completeRep(idx),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.warning),
                                  label: const Text('Too Heavy'),
                                  onPressed: prog.isComplete ? null : () => _tooHeavy(idx),
                                ),
                              ),
                            ],
                          ),
                          if (prog.isComplete)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('Exercise complete!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
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
                    backgroundColor: _allDone ? Colors.green : purpleDark,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
                  label: Text(_allDone ? 'Finish Workout' : 'Complete All Exercises'),
                  onPressed: _allDone
                      ? () {
                          // Save workout completion, navigate home, etc.
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseProgress {
  final dynamic exercise;
  int currentSet = 0;
  int currentRep = 0;
  double currentWeight;
  bool isComplete = false;

  _ExerciseProgress(this.exercise)
      : currentWeight = exercise.weight;

  void completeRep() {
    if (isComplete) return;
    currentRep++;
    if (currentRep >= exercise.reps) {
      currentRep = 0;
      currentSet++;
      if (currentSet >= exercise.sets) {
        isComplete = true;
      }
    }
  }

  void reduceWeight() {
    // Reduce by 10% or 5 lbs, whichever is greater, but not below 0
    final reduction = currentWeight > 0 ? (currentWeight * 0.1).clamp(5, double.infinity) : 0;
    currentWeight = (currentWeight - reduction).clamp(0, double.infinity);
  }
}
