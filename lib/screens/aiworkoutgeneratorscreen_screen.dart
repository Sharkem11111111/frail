import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';
import '../services/notification_service.dart';
import 'workoutpreviewscreen_screen.dart';
import 'workoutactivescreen_screen.dart';
import 'package:provider/provider.dart';

class AIWorkoutGeneratorScreen extends StatefulWidget {
  const AIWorkoutGeneratorScreen({super.key});

  @override
  State<AIWorkoutGeneratorScreen> createState() => _AIWorkoutGeneratorScreenState();
}

class _AIWorkoutGeneratorScreenState extends State<AIWorkoutGeneratorScreen> {
  bool _isGenerating = false;
  String _workoutPrompt = '';
  final _promptController = TextEditingController();
  bool _includeWeightsInPrompt = true; // Toggle for debugging prompt length

  @override
  Widget build(BuildContext context) {
    final dataManager = context.watch<FitnessDataProvider>();
    final availableMuscles = dataManager.getAvailableMuscles();
    final recoveringMuscles = dataManager.getRecoveringMuscles();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Workout Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Workout Generation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (availableMuscles.isNotEmpty) ...[
                      Text(
                        '✅ Ready muscles: ${availableMuscles.join(', ')}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                    if (recoveringMuscles.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⏳ Recovering: ${recoveringMuscles.join(', ')}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text(
                      'The AI will consider your equipment, muscle recovery, and exercise preferences to create the perfect workout.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Custom Prompt Section
            Text(
              'Workout Request (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., "I want an upper body strength workout" or "High intensity cardio session"',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _workoutPrompt = value,
            ),
            const SizedBox(height: 20),

            // Quick Generation Buttons
            Text(
              'Quick Generate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickButton('Full Body Strength', 'Generate a balanced full body strength workout'),
                _buildQuickButton('Upper Body Focus', 'Focus on chest, back, shoulders, and arms'),
                _buildQuickButton('Lower Body Power', 'Target legs, glutes, and core'),
                _buildQuickButton('Cardio HIIT', 'High intensity interval training session'),
                _buildQuickButton('Recovery Workout', 'Light exercises for active recovery'),
              ],
            ),
            const SizedBox(height: 20),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateWorkout,
                icon: _isGenerating 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate AI Workout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            // Toggle for prompt weights section (debug only)
            Row(
              children: [
                Checkbox(
                  value: _includeWeightsInPrompt,
                  onChanged: (val) {
                    setState(() {
                      _includeWeightsInPrompt = val ?? true;
                    });
                  },
                ),
                const Text('Include weights in AI prompt (debug)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String title, String prompt) {
    return ElevatedButton(
      onPressed: _isGenerating ? null : () {
        _promptController.text = prompt;
        _workoutPrompt = prompt;
      },
      child: Text(title),
    );
  }

  Future<void> _generateWorkout() async {
    setState(() => _isGenerating = true);

    try {
      final prompt = _workoutPrompt.isEmpty 
          ? 'Generate a personalized workout routine'
          : _workoutPrompt;

      print('Starting workout generation with prompt: $prompt');

      final response = await _getAiWorkoutResponse(prompt);
      
      final dataManager = context.read<FitnessDataProvider>();
      
      if (response.isNotEmpty && dataManager.currentWorkout.isNotEmpty) {
        // Schedule workout reminders if enabled
        // final notificationService = NotificationService();
        // final prefs = await SharedPreferences.getInstance();
        // final workoutRemindersEnabled = prefs.getBool('workout_reminders_enabled') ?? true;
        
        // if (workoutRemindersEnabled) {
        //   await notificationService.scheduleWorkoutReminders();
        // }
        
        // Store context before async operations
        final currentContext = context;
        
        // Show workout preview and ask if user wants to start
        if (mounted) {
          Navigator.pushReplacement(
            currentContext,
            MaterialPageRoute(builder: (context) => const WorkoutPreviewScreen()),
          );
        }
      } else {
        print('AI generation failed or returned empty workout');
        throw Exception('No workout generated or parsed');
      }
    } catch (e) {
      print('Workout generation error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI unavailable. Created smart default workout.'),
          backgroundColor: Colors.orange,
        ),
      );
      
      _generateDefaultWorkout();
      
      // Store context before async operations
      final currentContext = context;
      
      // Check if default workout has exercises
      final dataManager = context.read<FitnessDataProvider>();
      if (dataManager.currentWorkout.isNotEmpty) {
        if (mounted) {
          Navigator.pushReplacement(
            currentContext,
            MaterialPageRoute(builder: (context) => const WorkoutActiveScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              content: Text('Unable to create workout. Please check your muscle recovery status.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<String> _getAiWorkoutResponse(String prompt) async {
    const String apiKey = 'AIzaSyDRkbPi5aB5xPWHj49vkWGAThS9XN4Srys';
    final String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
    
    final dataManager = context.read<FitnessDataProvider>();
    // Build equipment/weights string (optional)
    String equipmentDetails = '';
    if (_includeWeightsInPrompt) {
      equipmentDetails = dataManager.availableEquipment.entries
          .where((e) => e.value.isAvailable)
          .map((e) {
            final weights = e.value.availableWeights;
            if (weights.isNotEmpty) {
              return '- ${e.value.name}: ${weights.map((w) => '${w.toInt()} lbs').join(", ")}';
            } else {
              return '- ${e.value.name}';
            }
          })
          .join('\n');
    }
    final String userContext = '''
USER PROFILE:
- Weight: ${dataManager.currentWeight > 0 ? '${dataManager.currentWeight} lbs' : 'unknown'}
- Height: ${dataManager.height > 0 ? '${(dataManager.height ~/ 12)}\'${(dataManager.height % 12).toInt()}\" (${(dataManager.height * 2.54).toStringAsFixed(0)} cm)' : 'unknown'}

USER FITNESS CONTEXT:
${dataManager.getMuscleRecoveryStatus()}
Available equipment${_includeWeightsInPrompt ? ' and weights' : ''}:${_includeWeightsInPrompt ? '\n$equipmentDetails' : ' ' + dataManager.getAvailableEquipmentNames().join(', ')}
${dataManager.getPreferencesForAI()}

TASK: Generate a workout routine based on the user's request: "$prompt"

REQUIREMENTS:
- Only use exercises that target available (recovered) muscles
- Only suggest exercises that can be done with available equipment
${_includeWeightsInPrompt ? '- Use only the weights the user has for each equipment (see above)\n' : ''}- Include 4-6 exercises with specific sets, reps, and weights
- When suggesting weights, take into account the user's weight and height for safe, realistic recommendations
- Format EXACTLY as: "ExerciseName: sets × reps @ weight"
- Each exercise on a new line
- Use "bodyweight" for exercises with no weights
- Prioritize user's preferred exercises when possible
- Avoid exercises targeting recovering muscles

EXACT FORMAT REQUIRED:
Push-ups: 3 × 12 @ bodyweight
Squats: 4 × 10 @ bodyweight
Plank: 3 × 30 @ bodyweight

Please generate exactly 4-6 exercises in this format:''';

    try {
      print('Sending request to Gemini with context: $userContext');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': userContext}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 500,
          }
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String aiResponse = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        
        print('AI Response: $aiResponse');
        
        if (aiResponse.isNotEmpty) {
          // Parse and apply the workout
          _parseAndApplyAIWorkout(aiResponse);
          return aiResponse.trim();
        } else {
          print('Empty AI response received');
          return '';
        }
      } else {
        // Show detailed error in UI
        String errorMsg = 'Gemini API Error: ${response.statusCode}\n${response.body}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
        print(errorMsg);
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      // Show error in UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gemini error: $e', style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
      print('Error generating AI workout: $e');
      return '';
    }
  }

  void _parseAndApplyAIWorkout(String aiResponse) {
    final dataManager = context.read<FitnessDataProvider>();
    dataManager.currentWorkout.clear();

    print('Parsing AI response: $aiResponse');

    // Split by lines and try to parse each line
    final lines = aiResponse.split('\n');
    bool foundExercises = false;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      print('Processing line: $line');

      // Enhanced parsing patterns
      final exercisePatterns = [
        RegExp(r'^([A-Za-z\s-]+?)\s*:\s*(\d+)\s*[×x]\s*(\d+)(?:\s*@\s*(.+?))?$', caseSensitive: false),
        RegExp(r'^([A-Za-z\s-]+?)\s*-\s*(\d+)\s*sets?\s*(?:of\s*)?(\d+)\s*reps?(?:\s*@\s*(.+?))?$', caseSensitive: false),
        RegExp(r'^(\d+)\.\s*([A-Za-z\s-]+?)\s*:\s*(\d+)\s*[×x]\s*(\d+)(?:\s*@\s*(.+?))?$', caseSensitive: false),
      ];

      Match? foundMatch;
      RegExp? matchedPattern;

      for (RegExp pattern in exercisePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          foundMatch = match;
          matchedPattern = pattern;
          break;
        }
      }

      if (foundMatch != null) {
        String exerciseName = '';
        int sets = 3;
        int reps = 10;
        String weightStr = 'bodyweight';

        if (matchedPattern == exercisePatterns[2]) { // Numbered format
          exerciseName = foundMatch.group(2)?.trim() ?? '';
          sets = int.tryParse(foundMatch.group(3) ?? '') ?? 3;
          reps = int.tryParse(foundMatch.group(4) ?? '') ?? 10;
          weightStr = foundMatch.group(5)?.trim() ?? 'bodyweight';
        } else { // Standard format
          exerciseName = foundMatch.group(1)?.trim() ?? '';
          sets = int.tryParse(foundMatch.group(2) ?? '') ?? 3;
          reps = int.tryParse(foundMatch.group(3) ?? '') ?? 10;
          weightStr = foundMatch.group(4)?.trim() ?? 'bodyweight';
        }

        double weight = 0;
        if (weightStr.toLowerCase() != 'bodyweight') {
          final weightMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(weightStr);
          weight = double.tryParse(weightMatch?.group(1) ?? '0') ?? 0;
        }

        if (exerciseName.isNotEmpty) {
          final muscles = _inferMuscleTargetsFromName(exerciseName);
          final exercise = Exercise(exerciseName, muscles);
          exercise.sets = sets;
          exercise.reps = reps;
          exercise.weight = weight;
          
          dataManager.currentWorkout.add(exercise);
          foundExercises = true;
          
          print('Added exercise: $exerciseName - $sets sets × $reps reps @ ${weight > 0 ? '${weight} lbs' : 'bodyweight'}');
        }
      }
    }

    // If no exercises were found, create a default workout
    if (!foundExercises) {
      print('No exercises parsed from AI response, creating default workout');
      _generateDefaultWorkout();
    } else {
      print('Successfully parsed ${dataManager.currentWorkout.length} exercises');
    }
  }

  String _inferMuscleTargetsFromName(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('push') || name.contains('bench') || name.contains('chest')) {
      return 'Chest, Triceps, Shoulders';
    } else if (name.contains('squat') || name.contains('lunge')) {
      return 'Legs, Glutes';
    } else if (name.contains('pull') || name.contains('row') || name.contains('lat')) {
      return 'Back, Biceps';
    } else if (name.contains('deadlift')) {
      return 'Back, Legs, Glutes';
    } else if (name.contains('curl')) {
      return 'Biceps';
    } else if (name.contains('press') && name.contains('shoulder')) {
      return 'Shoulders, Triceps';
    } else if (name.contains('plank') || name.contains('crunch') || name.contains('abs')) {
      return 'Core';
    } else if (name.contains('tricep') || name.contains('dip')) {
      return 'Triceps';
    } else {
      return 'Full Body';
    }
  }

  void _generateDefaultWorkout() {
    final dataManager = context.read<FitnessDataProvider>();
    final availableMuscles = dataManager.getAvailableMuscles();
    
    dataManager.currentWorkout.clear();
    
    print('Generating default workout for available muscles: $availableMuscles');
    
    // Create a basic workout based on available muscles
    if (availableMuscles.contains('chest')) {
      dataManager.currentWorkout.add(Exercise('Push-ups', 'Chest, Triceps, Shoulders')..sets = 3..reps = 12);
    }
    if (availableMuscles.contains('legs')) {
      dataManager.currentWorkout.add(Exercise('Squats', 'Legs, Glutes')..sets = 3..reps = 15);
    }
    if (availableMuscles.contains('back')) {
      dataManager.currentWorkout.add(Exercise('Pull-ups', 'Back, Biceps')..sets = 3..reps = 8);
    }
    if (availableMuscles.contains('core')) {
      dataManager.currentWorkout.add(Exercise('Plank', 'Core')..sets = 3..reps = 30);
    }
    if (availableMuscles.contains('shoulders') && !availableMuscles.contains('chest')) {
      dataManager.currentWorkout.add(Exercise('Shoulder Press', 'Shoulders, Triceps')..sets = 3..reps = 10);
    }
    if (availableMuscles.contains('biceps')) {
      dataManager.currentWorkout.add(Exercise('Bicep Curls', 'Biceps')..sets = 3..reps = 12);
    }
    if (availableMuscles.contains('triceps') && !availableMuscles.contains('chest')) {
      dataManager.currentWorkout.add(Exercise('Tricep Dips', 'Triceps')..sets = 3..reps = 10);
    }
    
    // If no muscles are available, create a light recovery workout
    if (dataManager.currentWorkout.isEmpty) {
      dataManager.currentWorkout.add(Exercise('Walking in Place', 'Full Body')..sets = 1..reps = 300);
      dataManager.currentWorkout.add(Exercise('Arm Circles', 'Shoulders')..sets = 2..reps = 20);
      dataManager.currentWorkout.add(Exercise('Gentle Stretching', 'Full Body')..sets = 1..reps = 10);
    }
    
    print('Default workout created with ${dataManager.currentWorkout.length} exercises');
  }
}
