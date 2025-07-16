import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FitnessDataProvider extends ChangeNotifier {
  // --- BEGIN MIGRATED FIELDS ---
  List<Exercise> currentWorkout = [
    Exercise('Push-ups', 'Chest, Triceps, Shoulders'),
    Exercise('Squats', 'Legs, Glutes'),
    Exercise('Pull-ups', 'Back, Biceps'),
    Exercise('Plank', 'Core'),
  ];

  NutritionGoals nutritionGoals = NutritionGoals(
    calories: 2200,
    protein: 150.0,
    carbs: 220.0,
    fat: 75.0,
  );
  List<FoodEntry> todaysFoods = [];
  List<FoodEntry> recentFoods = [];
  List<FoodEntry> favoriteFoods = [];
  List<FoodEntry> quickAddFoods = [];
  Map<String, int> foodSearchHistory = {};
  double sleepGoal = 8.0;
  double hoursSlept = 0.0;
  List<SleepEntry> weekSleep = [];
  DateTime lastNutritionUpdate = DateTime.now();
  DateTime lastSleepWeekUpdate = DateTime.now();
  int totalWorkoutsCompleted = 6;
  DateTime lastWorkoutDate = DateTime.now().subtract(const Duration(days: 1));
  FitnessRank currentRank = FitnessRank.tinIII;
  Map<String, EquipmentItem> availableEquipment = {
    'dumbbells': EquipmentItem('Dumbbells', false, maxWeight: 50),
    'barbells': EquipmentItem('Barbells', false, maxWeight: 135),
    'pullup_bar': EquipmentItem('Pull-up Bar', false),
    'flat_bench': EquipmentItem('Flat Bench', false),
    'adjustable_bench': EquipmentItem('Adjustable Bench (Incline/Decline)', false),
    'bench_press': EquipmentItem('Bench Press Station', false, maxWeight: 225),
    'squat_rack': EquipmentItem('Squat Rack', false, maxWeight: 315),
    'cable_machine': EquipmentItem('Cable Machine', false, maxWeight: 200),
    'leg_press': EquipmentItem('Leg Press Machine', false, maxWeight: 400),
    'lat_pulldown': EquipmentItem('Lat Pulldown Machine', false, maxWeight: 150),
    'rowing_machine': EquipmentItem('Rowing Machine', false),
    'treadmill': EquipmentItem('Treadmill', false),
    'stationary_bike': EquipmentItem('Stationary Bike', false),
    'kettlebells': EquipmentItem('Kettlebells', false, maxWeight: 35),
    'resistance_bands': EquipmentItem('Resistance Bands', false),
    'medicine_ball': EquipmentItem('Medicine Ball', false, maxWeight: 20),
    'foam_roller': EquipmentItem('Foam Roller', false),
    'yoga_mat': EquipmentItem('Yoga Mat', false),
    'ab_wheel': EquipmentItem('Ab Wheel', false),
  };
  String username = 'Fitness Warrior';
  double currentWeight = 0.0;
  double goalWeight = 0.0;
  double height = 0.0;
  int age = 0;
  String fitnessGoal = 'Build Muscle';
  DateTime joinDate = DateTime.now();
  Map<String, DateTime> muscleLastWorked = {
    'chest': DateTime.now().subtract(const Duration(days: 3)),
    'back': DateTime.now().subtract(const Duration(days: 3)),
    'shoulders': DateTime.now().subtract(const Duration(days: 2)),
    'biceps': DateTime.now().subtract(const Duration(days: 2)),
    'triceps': DateTime.now().subtract(const Duration(days: 2)),
    'legs': DateTime.now().subtract(const Duration(days: 4)),
    'glutes': DateTime.now().subtract(const Duration(days: 3)),
    'core': DateTime.now().subtract(const Duration(days: 1)),
    'calves': DateTime.now().subtract(const Duration(days: 3)),
    'forearms': DateTime.now().subtract(const Duration(days: 3)),
  };
  Map<String, int> exercisePreferences = {};
  List<Exercise> customWorkoutPool = [];
  List<Exercise> upperBodyFavorites = [];
  List<Exercise> lowerBodyFavorites = [];
  List<SavedWorkout> savedWorkouts = [];
  Map<String, ExerciseInstructions> customExerciseInstructions = {};
  Map<String, double> exerciseWeightHistory = {};
  Map<String, List<WorkoutSession>> workoutHistory = {};
  Map<String, int> exerciseSuccessStreak = {};
  Map<String, int> exerciseFailureStreak = {};
  Map<String, DateTime> lastExerciseAttempt = {};
  bool hasActiveWorkout = false;
  DateTime? workoutStartTime;
  int workoutElapsedSeconds = 0;
  Map<String, dynamic> exerciseProgressData = {};
  // --- END MIGRATED FIELDS ---

  // --- BEGIN METHODS AND GETTERS ---

  // AI Methods to modify data
  void modifyWorkout(List<Exercise> newWorkout) {
    currentWorkout = newWorkout;
    notifyListeners();
  }

  void addExercise(String name, String muscles, {int sets = 3, int reps = 8, double weight = 0}) {
    final exercise = Exercise(name, muscles);
    exercise.sets = sets;
    exercise.reps = reps;
    if (weight == 0) {
      exercise.weight = getRecommendedWeight(name, 0.0);
    } else {
      exercise.weight = weight;
    }
    currentWorkout.add(exercise);
    notifyListeners();
  }

  void removeExercise(String exerciseName) {
    currentWorkout.removeWhere((exercise) => exercise.name.toLowerCase() == exerciseName.toLowerCase());
    notifyListeners();
  }

  void replaceExercise(String oldName, String newName, String muscles, {int sets = 3, int reps = 8, double weight = 0}) {
    final index = currentWorkout.indexWhere((ex) => ex.name.toLowerCase() == oldName.toLowerCase());
    if (index != -1) {
      final newExercise = Exercise(newName, muscles);
      newExercise.sets = sets;
      newExercise.reps = reps;
      if (weight == 0) {
        newExercise.weight = getRecommendedWeight(newName, 0.0);
      } else {
        newExercise.weight = weight;
      }
      currentWorkout[index] = newExercise;
      notifyListeners();
    }
  }

  void updateNutritionGoals(NutritionGoals newGoals) {
    nutritionGoals = newGoals;
    notifyListeners();
  }

  void updateCalorieGoal(int newGoal) {
    nutritionGoals = NutritionGoals(
      calories: newGoal,
      protein: nutritionGoals.protein,
      carbs: nutritionGoals.carbs,
      fat: nutritionGoals.fat,
      fiber: nutritionGoals.fiber,
      sodium: nutritionGoals.sodium,
    );
    notifyListeners();
  }

  void addFood(FoodEntry foodEntry) {
    todaysFoods.add(foodEntry);
    recentFoods.removeWhere((f) => f.name == foodEntry.name);
    recentFoods.insert(0, foodEntry);
    if (recentFoods.length > 20) {
      recentFoods.removeLast();
    }
    foodSearchHistory[foodEntry.name] = (foodSearchHistory[foodEntry.name] ?? 0) + 1;
    notifyListeners();
  }

  void addFoodLegacy(String name, int calories) {
    final foodEntry = FoodEntry(name, calories, mealType: MealType.snack);
    addFood(foodEntry);
  }

  void removeFoodEntry(FoodEntry foodEntry) {
    todaysFoods.remove(foodEntry);
    notifyListeners();
  }

  void addToFavorites(FoodEntry foodEntry) {
    final favoriteEntry = foodEntry.copyWith(isFavorite: true);
    favoriteFoods.removeWhere((f) => f.name == favoriteEntry.name);
    favoriteFoods.add(favoriteEntry);
    notifyListeners();
  }

  void removeFromFavorites(String foodName) {
    favoriteFoods.removeWhere((f) => f.name == foodName);
    notifyListeners();
  }

  void addToQuickAdd(FoodEntry foodEntry) {
    quickAddFoods.removeWhere((f) => f.name == foodEntry.name);
    quickAddFoods.add(foodEntry);
    if (quickAddFoods.length > 10) {
      quickAddFoods.removeLast();
    }
    notifyListeners();
  }

  // Nutrition Calculations
  int get caloriesConsumed => todaysFoods.fold(0, (sum, food) => sum + food.calories);
  double get proteinConsumed => todaysFoods.fold(0.0, (sum, food) => sum + food.protein);
  double get carbsConsumed => todaysFoods.fold(0.0, (sum, food) => sum + food.carbs);
  double get fatConsumed => todaysFoods.fold(0.0, (sum, food) => sum + food.fat);

  int get calorieGoal => nutritionGoals.calories;
  int get remainingCalories => nutritionGoals.calories - caloriesConsumed;
  double get remainingProtein => nutritionGoals.protein - proteinConsumed;
  double get remainingCarbs => nutritionGoals.carbs - carbsConsumed;
  double get remainingFat => nutritionGoals.fat - fatConsumed;

  Map<MealType, List<FoodEntry>> get foodsByMeal {
    final Map<MealType, List<FoodEntry>> result = {};
    for (MealType mealType in MealType.values) {
      result[mealType] = todaysFoods.where((food) => food.mealType == mealType).toList();
    }
    return result;
  }

  Map<MealType, int> get caloriesByMeal {
    final Map<MealType, int> result = {};
    for (MealType mealType in MealType.values) {
      result[mealType] = todaysFoods
          .where((food) => food.mealType == mealType)
          .fold(0, (sum, food) => sum + food.calories);
    }
    return result;
  }

  // --- CONTINUED METHODS AND GETTERS ---

  void updateSleepGoal(double newGoal) {
    sleepGoal = newGoal;
    notifyListeners();
  }

  void logSleep(double hours) {
    hoursSlept = hours;
    
    // Ensure weekSleep is initialized with all days of the week
    if (weekSleep.isEmpty) {
      weekSleep = [
        SleepEntry('Monday', 0.0),
        SleepEntry('Tuesday', 0.0),
        SleepEntry('Wednesday', 0.0),
        SleepEntry('Thursday', 0.0),
        SleepEntry('Friday', 0.0),
        SleepEntry('Saturday', 0.0),
        SleepEntry('Sunday', 0.0),
      ];
    }
    
    // Update the correct day based on current weekday
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayIndex = (now.weekday - 1) % 7; // DateTime.weekday: 1=Mon, ..., 7=Sun
    
    if (todayIndex < weekSleep.length) {
      weekSleep[todayIndex] = SleepEntry(days[todayIndex], hours);
    }
    
    notifyListeners();
  }

  // Ranking System Methods
  void completeWorkout() {
    if (!hasActiveWorkout) return;
    totalWorkoutsCompleted++;
    lastWorkoutDate = DateTime.now();
    List<String> musclesWorked = [];
    for (Exercise exercise in currentWorkout) {
      musclesWorked.addAll(extractMusclesFromExercise(exercise.name, exercise.muscles));
    }
    markMusclesWorked(musclesWorked);
    hasActiveWorkout = false;
    workoutStartTime = null;
    workoutElapsedSeconds = 0;
    exerciseProgressData = {};
    _checkForRankPromotion();
    notifyListeners();
  }

  void startActiveWorkout() {
    hasActiveWorkout = true;
    workoutStartTime = DateTime.now();
    workoutElapsedSeconds = 0;
    exerciseProgressData = {};
    for (int i = 0; i < currentWorkout.length; i++) {
      final exercise = currentWorkout[i];
      exerciseProgressData[i.toString()] = {
        'currentSet': 1,
        'repsCompleted': 0,
        'setsCompleted': 0,
        'isCompleted': false,
      };
    }
    notifyListeners();
  }

  void updateWorkoutProgress(int exerciseIndex, int currentSet, int repsCompleted, int setsCompleted, bool isCompleted, int elapsedSeconds) {
    if (!hasActiveWorkout) return;
    exerciseProgressData[exerciseIndex.toString()] = {
      'currentSet': currentSet,
      'repsCompleted': repsCompleted,
      'setsCompleted': setsCompleted,
      'isCompleted': isCompleted,
    };
    workoutElapsedSeconds = elapsedSeconds;
    notifyListeners();
  }

  bool isWorkoutCompleted() {
    if (!hasActiveWorkout || exerciseProgressData.isEmpty) return false;
    for (int i = 0; i < currentWorkout.length; i++) {
      final progressData = exerciseProgressData[i.toString()];
      if (progressData == null || !progressData['isCompleted']) {
        return false;
      }
    }
    return true;
  }

  void clearActiveWorkout() {
    hasActiveWorkout = false;
    workoutStartTime = null;
    workoutElapsedSeconds = 0;
    exerciseProgressData = {};
    currentWorkout.clear();
    notifyListeners();
  }

  void toggleEquipment(String equipmentKey, bool isAvailable) {
    if (availableEquipment.containsKey(equipmentKey)) {
      availableEquipment[equipmentKey]!.isAvailable = isAvailable;
      notifyListeners();
    }
  }

  void updateEquipmentWeight(String equipmentKey, double maxWeight) {
    if (availableEquipment.containsKey(equipmentKey)) {
      availableEquipment[equipmentKey]!.maxWeight = maxWeight;
      notifyListeners();
    }
  }

  void addSpecificWeight(String equipmentKey, double weight) {
    if (availableEquipment.containsKey(equipmentKey)) {
      if (!availableEquipment[equipmentKey]!.availableWeights.contains(weight)) {
        availableEquipment[equipmentKey]!.availableWeights.add(weight);
        availableEquipment[equipmentKey]!.availableWeights.sort();
        notifyListeners();
      }
    }
  }

  void removeSpecificWeight(String equipmentKey, double weight) {
    if (availableEquipment.containsKey(equipmentKey)) {
      availableEquipment[equipmentKey]!.availableWeights.remove(weight);
      notifyListeners();
    }
  }

  List<double> getAvailableWeights(String equipmentKey) {
    if (availableEquipment.containsKey(equipmentKey)) {
      return List.from(availableEquipment[equipmentKey]!.availableWeights);
    }
    return [];
  }

  List<String> getAvailableEquipmentNames() {
    return availableEquipment.values
        .where((equipment) => equipment.isAvailable)
        .map((equipment) => equipment.name)
        .toList();
  }

  String getEquipmentBasedWorkoutSuggestion() {
    List<String> available = getAvailableEquipmentNames();
    if (available.isEmpty) {
      return "Consider investing in basic equipment like dumbbells or a pull-up bar for better workouts!";
    }
    String suggestion = "Great! You have ${available.join(', ')}.";
    for (String key in availableEquipment.keys) {
      EquipmentItem equipment = availableEquipment[key]!;
      if (equipment.isAvailable && equipment.supportsMultipleWeights && equipment.availableWeights.isNotEmpty) {
        suggestion += "\n${equipment.name}: ${equipment.availableWeights.map((w) => '${w.toInt()} lbs').join(', ')} pairs available.";
      }
    }
    return suggestion + "\nLet's create workouts using your available equipment.";
  }

  void updateUsername(String newUsername) {
    username = newUsername;
    notifyListeners();
  }

  void updateWeight(double newWeight) {
    currentWeight = newWeight;
    notifyListeners();
  }

  void updateGoalWeight(double newGoalWeight) {
    goalWeight = newGoalWeight;
    notifyListeners();
  }

  void updateHeight(double newHeight) {
    height = newHeight;
    notifyListeners();
  }

  void updateAge(int newAge) {
    age = newAge;
    notifyListeners();
  }

  void updateFitnessGoal(String newGoal) {
    fitnessGoal = newGoal;
    notifyListeners();
  }

  double getBMI() {
    if (height <= 0 || currentWeight <= 0) return 0.0;
    double heightInMeters = height * 0.0254;
    double weightInKg = currentWeight * 0.453592;
    return weightInKg / (heightInMeters * heightInMeters);
  }

  String getBMICategory() {
    double bmi = getBMI();
    if (bmi == 0) return 'Not calculated';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  double getWeightProgress() {
    if (goalWeight == 0 || currentWeight == 0) return 0.0;
    if (fitnessGoal == 'Lose Weight') {
      if (currentWeight <= goalWeight) return 1.0;
      double totalToLose = currentWeight - goalWeight;
      return totalToLose > 0 ? (currentWeight - goalWeight) / totalToLose : 0.0;
    } else if (fitnessGoal == 'Build Muscle') {
      if (currentWeight >= goalWeight) return 1.0;
      double totalToGain = goalWeight - currentWeight;
      return totalToGain > 0 ? (currentWeight - goalWeight) / totalToGain : 0.0;
    }
    return 0.0;
  }

  String getWeightProgressText() {
    if (goalWeight == 0 || currentWeight == 0) return 'Set your weight goals to track progress';
    double difference = (goalWeight - currentWeight).abs();
    if (fitnessGoal == 'Lose Weight') {
      if (currentWeight <= goalWeight) return 'Goal achieved! 🎉';
      return '${difference.toStringAsFixed(1)} lbs to lose';
    } else if (fitnessGoal == 'Build Muscle') {
      if (currentWeight >= goalWeight) return 'Goal achieved! 🎉';
      return '${difference.toStringAsFixed(1)} lbs to gain';
    } else {
      return 'Maintaining current weight';
    }
  }

  List<String> getAvailableMuscles() {
    final now = DateTime.now();
    List<String> availableMuscles = [];
    for (String muscle in muscleLastWorked.keys) {
      final daysSinceWorked = now.difference(muscleLastWorked[muscle]!).inDays;
      if (daysSinceWorked >= 2) {
        availableMuscles.add(muscle);
      }
    }
    return availableMuscles;
  }

  List<String> getRecoveringMuscles() {
    final now = DateTime.now();
    List<String> recoveringMuscles = [];
    for (String muscle in muscleLastWorked.keys) {
      final daysSinceWorked = now.difference(muscleLastWorked[muscle]!).inDays;
      if (daysSinceWorked < 2) {
        recoveringMuscles.add(muscle);
      }
    }
    return recoveringMuscles;
  }

  String getMuscleRecoveryStatus() {
    final available = getAvailableMuscles();
    final recovering = getRecoveringMuscles();
    String status = '';
    if (available.isNotEmpty) {
      status += '✅ Ready to train: ${available.join(', ')}\n';
    }
    if (recovering.isNotEmpty) {
      status += '⏳ Still recovering: ${recovering.join(', ')}';
    }
    return status;
  }

  void markMusclesWorked(List<String> muscles) {
    final now = DateTime.now();
    for (String muscle in muscles) {
      if (muscleLastWorked.containsKey(muscle.toLowerCase())) {
        muscleLastWorked[muscle.toLowerCase()] = now;
      }
    }
    notifyListeners();
  }

  List<String> extractMusclesFromExercise(String exerciseName, String muscleTargets) {
    final List<String> muscles = [];
    final combinedText = '${exerciseName.toLowerCase()} ${muscleTargets.toLowerCase()}';
    if (combinedText.contains('push') || combinedText.contains('bench') || combinedText.contains('chest')) {
      muscles.addAll(['chest', 'triceps', 'shoulders']);
    }
    if (combinedText.contains('pull') || combinedText.contains('row') || combinedText.contains('back')) {
      muscles.addAll(['back', 'biceps']);
    }
    if (combinedText.contains('squat') || combinedText.contains('leg') || combinedText.contains('thigh')) {
      muscles.addAll(['legs', 'glutes']);
    }
    if (combinedText.contains('shoulder') || combinedText.contains('press') && combinedText.contains('overhead')) {
      muscles.add('shoulders');
    }
    if (combinedText.contains('bicep') || combinedText.contains('curl')) {
      muscles.add('biceps');
    }
    if (combinedText.contains('tricep') || combinedText.contains('dip')) {
      muscles.add('triceps');
    }
    if (combinedText.contains('plank') || combinedText.contains('core') || combinedText.contains('ab')) {
      muscles.add('core');
    }
    if (combinedText.contains('calf') || combinedText.contains('raise')) {
      muscles.add('calves');
    }
    if (combinedText.contains('glute') || combinedText.contains('bridge')) {
      muscles.add('glutes');
    }
    return muscles.toSet().toList();
  }

  // --- PREFERENCES, SAVED WORKOUTS, WEIGHT/PROGRESS TRACKING, HELPERS ---

  // Exercise Preference Management
  void likeExercise(String exerciseName, String muscles, int sets, int reps, double weight) {
    exercisePreferences[exerciseName] = (exercisePreferences[exerciseName] ?? 0) + 1;
    bool alreadyInPool = customWorkoutPool.any((ex) => ex.name.toLowerCase() == exerciseName.toLowerCase());
    if (!alreadyInPool) {
      final exercise = Exercise(exerciseName, muscles);
      exercise.sets = sets;
      exercise.reps = reps;
      exercise.weight = weight;
      customWorkoutPool.add(exercise);
    }
    List<String> targetedMuscles = extractMusclesFromExercise(exerciseName, muscles);
    bool isUpperBody = targetedMuscles.any((muscle) => ['chest', 'back', 'shoulders', 'biceps', 'triceps', 'forearms'].contains(muscle));
    bool isLowerBody = targetedMuscles.any((muscle) => ['legs', 'glutes', 'calves'].contains(muscle));
    if (isUpperBody) {
      bool alreadyInUpper = upperBodyFavorites.any((ex) => ex.name.toLowerCase() == exerciseName.toLowerCase());
      if (!alreadyInUpper) {
        final exercise = Exercise(exerciseName, muscles);
        exercise.sets = sets;
        exercise.reps = reps;
        exercise.weight = weight;
        upperBodyFavorites.add(exercise);
      }
    }
    if (isLowerBody) {
      bool alreadyInLower = lowerBodyFavorites.any((ex) => ex.name.toLowerCase() == exerciseName.toLowerCase());
      if (!alreadyInLower) {
        final exercise = Exercise(exerciseName, muscles);
        exercise.sets = sets;
        exercise.reps = reps;
        exercise.weight = weight;
        lowerBodyFavorites.add(exercise);
      }
    }
    notifyListeners();
  }

  void dislikeExercise(String exerciseName) {
    exercisePreferences[exerciseName] = (exercisePreferences[exerciseName] ?? 0) - 1;
    if (exercisePreferences[exerciseName]! <= 0) {
      exercisePreferences.remove(exerciseName);
    }
    notifyListeners();
  }

  void toggleExercisePreference(String exerciseName) {
    final currentPreference = exercisePreferences[exerciseName] ?? 0;
    if (currentPreference == 0) {
      exercisePreferences[exerciseName] = 1;
    } else if (currentPreference > 0) {
      exercisePreferences.remove(exerciseName);
    } else {
      exercisePreferences[exerciseName] = 1;
    }
    notifyListeners();
  }

  List<String> getPreferredExercises() {
    var sortedPrefs = exercisePreferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedPrefs.map((entry) => entry.key).take(10).toList();
  }

  String getPreferencesForAI() {
    if (exercisePreferences.isEmpty) return 'No exercise preferences set yet.';
    var liked = exercisePreferences.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var disliked = exercisePreferences.entries.where((e) => e.value < 0).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    String result = '';
    if (liked.isNotEmpty) {
      result += 'PREFERRED EXERCISES (recommend these more): ${liked.map((e) => '${e.key} (score: ${e.value})').join(', ')}\n';
    }
    if (disliked.isNotEmpty) {
      result += 'DISLIKED EXERCISES (avoid these): ${disliked.map((e) => '${e.key} (score: ${e.value})').join(', ')}';
    }
    return result;
  }

  // Saved Workout Management
  void saveWorkout(String name, List<Exercise> exercises, {String description = ''}) {
    final savedWorkout = SavedWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      exercises: exercises.map((e) {
        final copy = Exercise(e.name, e.muscles);
        copy.sets = e.sets;
        copy.reps = e.reps;
        copy.weight = e.weight;
        return copy;
      }).toList(),
      createdDate: DateTime.now(),
      description: description,
    );
    savedWorkouts.add(savedWorkout);
    notifyListeners();
  }

  void deleteWorkout(String workoutId) {
    savedWorkouts.removeWhere((w) => w.id == workoutId);
    notifyListeners();
  }

  void loadWorkout(String workoutId) {
    final workout = savedWorkouts.firstWhere((w) => w.id == workoutId);
    currentWorkout = workout.exercises.map((e) {
      final copy = Exercise(e.name, e.muscles);
      copy.sets = e.sets;
      copy.reps = e.reps;
      copy.weight = e.weight;
      return copy;
    }).toList();
    notifyListeners();
  }

  // Weight Management and Progress Tracking Methods
  void markExerciseTooHeavy(String exerciseName, double currentWeight) {
    final reducedWeight = (currentWeight * 0.9).roundToDouble();
    exerciseWeightHistory[exerciseName] = reducedWeight;
    exerciseFailureStreak[exerciseName] = (exerciseFailureStreak[exerciseName] ?? 0) + 1;
    exerciseSuccessStreak[exerciseName] = 0;
    lastExerciseAttempt[exerciseName] = DateTime.now();
    notifyListeners();
  }

  void recordWorkoutSession(String exerciseName, double weight, int sets, int reps, int completedSets, int completedReps, bool wasTooHeavy, int totalTime) {
    final session = WorkoutSession(
      name: exerciseName,
      date: DateTime.now(),
      exercises: [Exercise(exerciseName, 'Various muscles', sets: sets, reps: reps, weight: weight)],
      durationMinutes: totalTime ~/ 60,
      completed: completedSets >= sets && completedReps >= reps,
      completedSets: completedSets,
      completedReps: completedReps,
    );
    if (!workoutHistory.containsKey(exerciseName)) {
      workoutHistory[exerciseName] = [];
    }
    workoutHistory[exerciseName]!.add(session);
    if (workoutHistory[exerciseName]!.length > 20) {
      workoutHistory[exerciseName]!.removeAt(0);
    }
    exerciseWeightHistory[exerciseName] = weight;
    if (wasTooHeavy) {
      exerciseFailureStreak[exerciseName] = (exerciseFailureStreak[exerciseName] ?? 0) + 1;
      exerciseSuccessStreak[exerciseName] = 0;
    } else if (completedSets >= sets && completedReps >= reps) {
      exerciseSuccessStreak[exerciseName] = (exerciseSuccessStreak[exerciseName] ?? 0) + 1;
      exerciseFailureStreak[exerciseName] = 0;
    }
    lastExerciseAttempt[exerciseName] = DateTime.now();
    notifyListeners();
  }

  double getRecommendedWeight(String exerciseName, double defaultWeight) {
    if (exerciseWeightHistory.containsKey(exerciseName)) {
      final lastWeight = exerciseWeightHistory[exerciseName]!;
      final failureStreak = exerciseFailureStreak[exerciseName] ?? 0;
      final successStreak = exerciseSuccessStreak[exerciseName] ?? 0;
      if (failureStreak > 0) {
        return lastWeight;
      }
      if (successStreak >= 3) {
        final increase = lastWeight * 0.05;
        return (lastWeight + increase).roundToDouble();
      }
      return lastWeight;
    }
    return defaultWeight;
  }

  bool shouldIncreaseWeight(String exerciseName) {
    final successStreak = exerciseSuccessStreak[exerciseName] ?? 0;
    final failureStreak = exerciseFailureStreak[exerciseName] ?? 0;
    return successStreak >= 3 && failureStreak == 0;
  }

  double getSafeWeightIncrease(String exerciseName) {
    final currentWeight = exerciseWeightHistory[exerciseName] ?? 0;
    if (currentWeight <= 0) return 0;
    double increasePercentage = 0.05;
    final exerciseNameLower = exerciseName.toLowerCase();
    if (exerciseNameLower.contains('deadlift') || exerciseNameLower.contains('squat') || exerciseNameLower.contains('bench press')) {
      increasePercentage = 0.03;
    }
    return (currentWeight * increasePercentage).roundToDouble();
  }

  List<WorkoutSession> getExerciseHistory(String exerciseName) {
    return workoutHistory[exerciseName] ?? [];
  }

  double getExerciseProgress(String exerciseName) {
    final history = getExerciseHistory(exerciseName);
    if (history.isEmpty) return 0.0;
    double totalProgress = 0.0;
    int sessionCount = 0;
    for (int i = 1; i < history.length; i++) {
      final current = history[i];
      final previous = history[i - 1];
      final currentWeight = current.exercises.isNotEmpty ? current.exercises.first.weight : 0.0;
      final previousWeight = previous.exercises.isNotEmpty ? previous.exercises.first.weight : 0.0;
      if (currentWeight > previousWeight) {
        totalProgress += 1.0;
      }
      final completionRate = (current.completedSets / (current.exercises.isNotEmpty ? current.exercises.first.sets : 1)) * (current.completedReps / (current.exercises.isNotEmpty ? current.exercises.first.reps : 1));
      totalProgress += completionRate;
      sessionCount++;
    }
    return sessionCount > 0 ? totalProgress / sessionCount : 0.0;
  }

  String getCurrentWorkoutString() {
    if (currentWorkout.isEmpty) {
      return "No workout currently set. Let me create one for you!";
    }
    return currentWorkout.map((exercise) {
      String weightText = exercise.weight > 0 ? ' @ ${exercise.weight} lbs' : ' @ bodyweight';
      return '${exercise.name}: ${exercise.sets} × ${exercise.reps}$weightText';
    }).join('\n');
  }
  // ... (continue with more methods and getters in the next batch) ...
  // --- END METHODS AND GETTERS ---

  void _checkForRankPromotion() {
    int divisionProgression = totalWorkoutsCompleted ~/ 5;
    FitnessRank newRank = _getRankFromProgression(divisionProgression);
    newRank = _checkForDemotion(newRank);
    if (newRank != currentRank) {
      currentRank = newRank;
    }
  }

  FitnessRank _getRankFromProgression(int progression) {
    List<FitnessRank> allRanks = FitnessRank.values.reversed.toList();
    int rankIndex = (2 - progression).clamp(0, allRanks.length - 1);
    return allRanks[rankIndex];
  }

  FitnessRank _checkForDemotion(FitnessRank baseRank) {
    DateTime now = DateTime.now();
    int daysSinceLastWorkout = now.difference(lastWorkoutDate).inDays;
    if (daysSinceLastWorkout >= 7) {
      int weeksInactive = daysSinceLastWorkout ~/ 7;
      List<FitnessRank> allRanks = FitnessRank.values.reversed.toList();
      int currentIndex = allRanks.indexOf(baseRank);
      int newIndex = (currentIndex + weeksInactive).clamp(0, allRanks.length - 1);
      return allRanks[newIndex];
    }
    return baseRank;
  }

  String getRankDisplayName() {
    return currentRank.displayName;
  }

  Color getRankColor() {
    return currentRank.color;
  }

  String getRankIconPath() {
    return currentRank.iconPath;
  }

  int getWorkoutsUntilPromotion() {
    int currentProgress = totalWorkoutsCompleted % 5;
    return 5 - currentProgress;
  }

  String getWorkoutSummary() {
    return currentWorkout.map((e) => '${e.name}: ${e.sets} sets × ${e.reps} reps @ ${e.weight} lbs').join('\n');
  }

  // --- FINAL MIGRATED METHODS: AI, PERSISTENCE, RESET, HELPERS ---

  // Exercise Instructions Methods
  Future<ExerciseInstructions?> getExerciseInstructions(String exerciseName) async {
    final preloaded = ExerciseDatabase.getInstructions(exerciseName);
    if (preloaded != null) {
      return preloaded;
    }
    final key = exerciseName.toLowerCase().trim();
    if (customExerciseInstructions.containsKey(key)) {
      return customExerciseInstructions[key];
    }
    try {
      final instructions = await _generateExerciseInstructionsWithAI(exerciseName);
      if (instructions != null) {
        customExerciseInstructions[key] = instructions;
        await saveUserData();
        return instructions;
      }
    } catch (e) {}
    return null;
  }

  Future<ExerciseInstructions?> _generateExerciseInstructionsWithAI(String exerciseName) async {
    final prompt = '''
Please provide detailed instructions for the exercise "$exerciseName". Format your response as follows:

DESCRIPTION: [Brief description of the exercise and what muscles it targets]

STEPS:
1. [First step]
2. [Second step]
3. [Third step]
4. [etc...]

TIPS:
- [Important form tip]
- [Safety tip]
- [Performance tip]
- [etc...]

DIFFICULTY: [Beginner/Intermediate/Advanced]

EQUIPMENT: [Equipment needed, or "None" if bodyweight]

Keep the response concise but comprehensive. Focus on proper form and safety.
''';
    try {
      const String apiKey = 'YOUR_GEMINI_API_KEY_HERE';
      if (apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        return null;
      }
      final String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prompt}]
          }]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return _parseAIInstructionResponse(content, exerciseName);
        }
      }
    } catch (e) {}
    return null;
  }

  ExerciseInstructions? _parseAIInstructionResponse(String response, String exerciseName) {
    try {
      final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();
      String description = '';
      List<String> steps = [];
      List<String> tips = [];
      String difficulty = 'Medium';
      String equipment = 'Unknown';
      String currentSection = '';
      for (String line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('DESCRIPTION:')) {
          description = trimmed.substring(12).trim();
          currentSection = 'description';
        } else if (trimmed.startsWith('STEPS:')) {
          currentSection = 'steps';
        } else if (trimmed.startsWith('TIPS:')) {
          currentSection = 'tips';
        } else if (trimmed.startsWith('DIFFICULTY:')) {
          difficulty = trimmed.substring(11).trim();
          currentSection = '';
        } else if (trimmed.startsWith('EQUIPMENT:')) {
          equipment = trimmed.substring(10).trim();
          currentSection = '';
        } else if (currentSection == 'steps' && (trimmed.startsWith(RegExp(r'\d+\.')) || trimmed.startsWith('-'))) {
          steps.add(trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), '').replaceFirst(RegExp(r'^-\s*'), ''));
        } else if (currentSection == 'tips' && trimmed.startsWith('-')) {
          tips.add(trimmed.substring(1).trim());
        } else if (currentSection == 'description' && !trimmed.startsWith(RegExp(r'[A-Z]+:'))) {
          description += ' ' + trimmed;
        }
      }
      if (description.isNotEmpty && steps.isNotEmpty) {
        return ExerciseInstructions(
          name: exerciseName,
          description: description.trim(),
          steps: steps,
          tips: tips,
          difficulty: difficulty,
          equipment: equipment,
        );
      }
    } catch (e) {}
    return null;
  }

  // Exercise JSON helpers
  Map<String, dynamic> _exerciseToJson(Exercise exercise) {
    return {
      'name': exercise.name,
      'muscles': exercise.muscles,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'weight': exercise.weight,
    };
  }

  Exercise _exerciseFromJson(Map<String, dynamic> json) {
    final exercise = Exercise(json['name'] ?? '', json['muscles'] ?? '');
    exercise.sets = json['sets'] ?? 0;
    exercise.reps = json['reps'] ?? 0;
    exercise.weight = (json['weight'] ?? 0).toDouble();
    return exercise;
  }

  // Data Persistence Methods
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? 'Fitness Warrior';
    currentWeight = prefs.getDouble('currentWeight') ?? 0.0;
    goalWeight = prefs.getDouble('goalWeight') ?? 0.0;
    height = prefs.getDouble('height') ?? 0.0;
    age = prefs.getInt('age') ?? 0;
    fitnessGoal = prefs.getString('fitnessGoal') ?? 'Build Muscle';
    String? nutritionGoalsJson = prefs.getString('nutritionGoals');
    if (nutritionGoalsJson != null) {
      try {
        nutritionGoals = NutritionGoals.fromJson(jsonDecode(nutritionGoalsJson));
      } catch (e) {}
    } else {
      int legacyCalorieGoal = prefs.getInt('calorieGoal') ?? 2200;
      if (nutritionGoals.calories != legacyCalorieGoal) {
        nutritionGoals = NutritionGoals(
          calories: legacyCalorieGoal,
          protein: 150.0,
          carbs: 220.0,
          fat: 75.0,
        );
      }
    }
    sleepGoal = prefs.getDouble('sleepGoal') ?? 8.0;
    hoursSlept = prefs.getDouble('hoursSlept') ?? 7.5;
    totalWorkoutsCompleted = prefs.getInt('totalWorkoutsCompleted') ?? 6;
    String? lastWorkoutString = prefs.getString('lastWorkoutDate');
    if (lastWorkoutString != null) {
      lastWorkoutDate = DateTime.parse(lastWorkoutString);
    }
    String? rankString = prefs.getString('currentRank');
    if (rankString != null) {
      currentRank = FitnessRank.values.firstWhere(
        (rank) => rank.name == rankString,
        orElse: () => FitnessRank.tinIII,
      );
    }
    String? lastNutritionUpdateString = prefs.getString('lastNutritionUpdate');
    if (lastNutritionUpdateString != null) {
      lastNutritionUpdate = DateTime.parse(lastNutritionUpdateString);
    }
    String? lastSleepWeekUpdateString = prefs.getString('lastSleepWeekUpdate');
    if (lastSleepWeekUpdateString != null) {
      lastSleepWeekUpdate = DateTime.parse(lastSleepWeekUpdateString);
    }
    // Load weekSleep data
    List<String>? weekSleepJson = prefs.getStringList('weekSleep');
    if (weekSleepJson != null) {
      weekSleep = weekSleepJson.map((json) {
        final data = jsonDecode(json);
        return SleepEntry(data['day'], data['hours'].toDouble());
      }).toList();
    }
    for (String muscle in muscleLastWorked.keys) {
      String? muscleWorkoutString = prefs.getString('muscle_${muscle}_lastWorked');
      if (muscleWorkoutString != null) {
        muscleLastWorked[muscle] = DateTime.parse(muscleWorkoutString);
      }
    }
    final Map<String, Object?> prefsMap = prefs.getKeys().fold<Map<String, Object?>>({}, (map, key) {
      if (key.startsWith('exercise_pref_')) {
        String exerciseName = key.substring('exercise_pref_'.length);
        map[exerciseName] = prefs.getInt(key);
      }
      return map;
    });
    exercisePreferences = prefsMap.cast<String, int>();
    List<String>? customWorkoutJson = prefs.getStringList('custom_workout_pool');
    if (customWorkoutJson != null) {
      customWorkoutPool = customWorkoutJson.map((json) => _exerciseFromJson(jsonDecode(json))).toList();
    }
    List<String>? upperBodyJson = prefs.getStringList('upper_body_favorites');
    if (upperBodyJson != null) {
      upperBodyFavorites = upperBodyJson.map((json) => _exerciseFromJson(jsonDecode(json))).toList();
    }
    List<String>? lowerBodyJson = prefs.getStringList('lower_body_favorites');
    if (lowerBodyJson != null) {
      lowerBodyFavorites = lowerBodyJson.map((json) => _exerciseFromJson(jsonDecode(json))).toList();
    }
    List<String>? savedWorkoutsJson = prefs.getStringList('saved_workouts');
    if (savedWorkoutsJson != null) {
      savedWorkouts = savedWorkoutsJson.map((json) => SavedWorkout.fromJson(jsonDecode(json))).toList();
    }
    List<String>? customInstructionsJson = prefs.getStringList('custom_exercise_instructions');
    if (customInstructionsJson != null) {
      customExerciseInstructions.clear();
      for (String json in customInstructionsJson) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          final String key = data['key'];
          final ExerciseInstructions instructions = ExerciseInstructions.fromJson(data['instructions']);
          customExerciseInstructions[key] = instructions;
        } catch (e) {}
      }
    }
    hasActiveWorkout = prefs.getBool('hasActiveWorkout') ?? false;
    String? workoutStartString = prefs.getString('workoutStartTime');
    if (workoutStartString != null) {
      workoutStartTime = DateTime.parse(workoutStartString);
    }
    workoutElapsedSeconds = prefs.getInt('workoutElapsedSeconds') ?? 0;
    String? progressDataString = prefs.getString('exerciseProgressData');
    if (progressDataString != null) {
      try {
        exerciseProgressData = Map<String, dynamic>.from(jsonDecode(progressDataString));
      } catch (e) {
        exerciseProgressData = {};
      }
    }
    List<String>? currentWorkoutJson = prefs.getStringList('current_workout');
    if (currentWorkoutJson != null) {
      currentWorkout = currentWorkoutJson.map((json) => _exerciseFromJson(jsonDecode(json))).toList();
    }
    for (String key in availableEquipment.keys) {
      bool isAvailable = prefs.getBool('equipment_${key}_available') ?? false;
      availableEquipment[key]!.isAvailable = isAvailable;
      double? maxWeight = prefs.getDouble('equipment_${key}_maxWeight');
      if (maxWeight != null) {
        availableEquipment[key]!.maxWeight = maxWeight;
      }
      List<String>? weightsString = prefs.getStringList('equipment_${key}_weights');
      if (weightsString != null) {
        availableEquipment[key]!.availableWeights = weightsString.map((w) => double.parse(w)).toList();
      }
    }
    String? weightHistoryJson = prefs.getString('exerciseWeightHistory');
    if (weightHistoryJson != null) {
      try {
        exerciseWeightHistory = Map<String, double>.from(jsonDecode(weightHistoryJson));
      } catch (e) {
        exerciseWeightHistory = {};
      }
    }
    final Map<String, Object?> prefsMap2 = prefs.getKeys().fold<Map<String, Object?>>({}, (map, key) {
      if (key.startsWith('workout_history_')) {
        String exerciseName = key.substring('workout_history_'.length);
        map[exerciseName] = prefs.getStringList(key);
      }
      return map;
    });
    for (String exerciseName in prefsMap2.keys) {
      List<String>? sessionsJson = prefs.getStringList('workout_history_$exerciseName');
      if (sessionsJson != null) {
        workoutHistory[exerciseName] = sessionsJson.map((json) => WorkoutSession.fromJson(jsonDecode(json))).toList();
      }
    }
    String? successStreakJson = prefs.getString('exerciseSuccessStreak');
    if (successStreakJson != null) {
      try {
        exerciseSuccessStreak = Map<String, int>.from(jsonDecode(successStreakJson));
      } catch (e) {
        exerciseSuccessStreak = {};
      }
    }
    String? failureStreakJson = prefs.getString('exerciseFailureStreak');
    if (failureStreakJson != null) {
      try {
        exerciseFailureStreak = Map<String, int>.from(jsonDecode(failureStreakJson));
      } catch (e) {
        exerciseFailureStreak = {};
      }
    }
    final Map<String, Object?> prefsMap3 = prefs.getKeys().fold<Map<String, Object?>>({}, (map, key) {
      if (key.startsWith('last_exercise_attempt_')) {
        String exerciseName = key.substring('last_exercise_attempt_'.length);
        map[exerciseName] = prefs.getString(key);
      }
      return map;
    });
    for (String exerciseName in prefsMap3.keys) {
      String? attemptDateString = prefs.getString('last_exercise_attempt_$exerciseName');
      if (attemptDateString != null) {
        try {
          lastExerciseAttempt[exerciseName] = DateTime.parse(attemptDateString);
        } catch (e) {}
      }
    }
    final beforeFoods = todaysFoods.length;
    final beforeSleep = weekSleep.length;
    _checkAndResetDailyNutrition();
    _checkAndResetWeeklySleep();
    if (todaysFoods.length == 0 && beforeFoods > 0) await saveUserData();
    if (weekSleep.length == 0 && beforeSleep > 0) await saveUserData();
    notifyListeners();
  }

  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setDouble('currentWeight', currentWeight);
    await prefs.setDouble('goalWeight', goalWeight);
    await prefs.setDouble('height', height);
    await prefs.setInt('age', age);
    await prefs.setString('fitnessGoal', fitnessGoal);
    await prefs.setInt('calorieGoal', nutritionGoals.calories);
    await prefs.setString('nutritionGoals', jsonEncode(nutritionGoals.toJson()));
    await prefs.setDouble('sleepGoal', sleepGoal);
    await prefs.setDouble('hoursSlept', hoursSlept);
    await prefs.setInt('totalWorkoutsCompleted', totalWorkoutsCompleted);
    await prefs.setString('lastWorkoutDate', lastWorkoutDate.toIso8601String());
    await prefs.setString('currentRank', currentRank.name);
    await prefs.setString('lastNutritionUpdate', lastNutritionUpdate.toIso8601String());
    await prefs.setString('lastSleepWeekUpdate', lastSleepWeekUpdate.toIso8601String());
    // Save weekSleep data
    List<String> weekSleepJson = weekSleep.map((sleep) => jsonEncode({
      'day': sleep.day,
      'hours': sleep.hours,
    })).toList();
    await prefs.setStringList('weekSleep', weekSleepJson);
    for (String muscle in muscleLastWorked.keys) {
      await prefs.setString('muscle_${muscle}_lastWorked', muscleLastWorked[muscle]!.toIso8601String());
    }
    for (String exerciseName in exercisePreferences.keys) {
      await prefs.setInt('exercise_pref_$exerciseName', exercisePreferences[exerciseName]!);
    }
    await prefs.setStringList('custom_workout_pool', customWorkoutPool.map((ex) => jsonEncode(_exerciseToJson(ex))).toList());
    await prefs.setStringList('upper_body_favorites', upperBodyFavorites.map((ex) => jsonEncode(_exerciseToJson(ex))).toList());
    await prefs.setStringList('lower_body_favorites', lowerBodyFavorites.map((ex) => jsonEncode(_exerciseToJson(ex))).toList());
    await prefs.setStringList('saved_workouts', savedWorkouts.map((workout) => jsonEncode(workout.toJson())).toList());
    await prefs.setStringList('custom_exercise_instructions', customExerciseInstructions.entries.map((entry) => jsonEncode({'key': entry.key, 'instructions': entry.value.toJson(),})).toList());
    await prefs.setBool('hasActiveWorkout', hasActiveWorkout);
    if (workoutStartTime != null) {
      await prefs.setString('workoutStartTime', workoutStartTime!.toIso8601String());
    }
    await prefs.setInt('workoutElapsedSeconds', workoutElapsedSeconds);
    await prefs.setString('exerciseProgressData', jsonEncode(exerciseProgressData));
    await prefs.setStringList('current_workout', currentWorkout.map((ex) => jsonEncode(_exerciseToJson(ex))).toList());
    for (String key in availableEquipment.keys) {
      await prefs.setBool('equipment_${key}_available', availableEquipment[key]!.isAvailable);
      if (availableEquipment[key]!.maxWeight != null) {
        await prefs.setDouble('equipment_${key}_maxWeight', availableEquipment[key]!.maxWeight!);
      }
      if (availableEquipment[key]!.availableWeights.isNotEmpty) {
        await prefs.setStringList('equipment_${key}_weights', availableEquipment[key]!.availableWeights.map((w) => w.toString()).toList());
      }
    }
    await prefs.setString('exerciseWeightHistory', jsonEncode(exerciseWeightHistory));
    for (String exerciseName in workoutHistory.keys) {
      await prefs.setStringList('workout_history_$exerciseName', workoutHistory[exerciseName]!.map((session) => jsonEncode(session.toJson())).toList());
    }
    await prefs.setString('exerciseSuccessStreak', jsonEncode(exerciseSuccessStreak));
    await prefs.setString('exerciseFailureStreak', jsonEncode(exerciseFailureStreak));
    for (String exerciseName in lastExerciseAttempt.keys) {
      await prefs.setString('last_exercise_attempt_$exerciseName', lastExerciseAttempt[exerciseName]!.toIso8601String());
    }
  }

  // Reset all user data to fresh first-time user state
  Future<void> resetToFirstTimeUser({bool blank = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _resetToDefaults(blank: blank);
      await saveUserData();
      await loadUserData();
      notifyListeners();
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _resetToDefaults(blank: blank);
      } catch (fallbackError) {
        rethrow;
      }
    }
  }

  Future<void> hardResetToFirstTimeUser() async {
    await resetToFirstTimeUser(blank: true);
  }

  void _resetToDefaults({bool blank = false}) {
    try {
      if (blank) {
        username = '';
        currentWeight = 0.0;
        goalWeight = 0.0;
        height = 0.0;
        age = 0;
        fitnessGoal = '';
        joinDate = DateTime.now();
        nutritionGoals = NutritionGoals(calories: 0, protein: 0, carbs: 0, fat: 0);
        todaysFoods = [];
        recentFoods = [];
        favoriteFoods = [];
        quickAddFoods = [];
        foodSearchHistory = {};
        sleepGoal = 0.0;
        hoursSlept = 0.0;
        weekSleep = [];
        totalWorkoutsCompleted = 0;
        lastWorkoutDate = DateTime.now();
        currentRank = FitnessRank.tinIII;
        availableEquipment = {};
        muscleLastWorked = {};
        exercisePreferences = {};
        currentWorkout = [];
        customWorkoutPool = [];
        upperBodyFavorites = [];
        lowerBodyFavorites = [];
        savedWorkouts = [];
        customExerciseInstructions = {};
        exerciseWeightHistory = {};
        workoutHistory = {};
        exerciseSuccessStreak = {};
        exerciseFailureStreak = {};
        lastExerciseAttempt = {};
        hasActiveWorkout = false;
        workoutStartTime = null;
        workoutElapsedSeconds = 0;
        exerciseProgressData = {};
        return;
      }
      currentWorkout = [
        Exercise('Push-ups', 'Chest, Triceps, Shoulders'),
        Exercise('Squats', 'Legs, Glutes'),
        Exercise('Pull-ups', 'Back, Biceps'),
        Exercise('Plank', 'Core'),
      ];
      nutritionGoals = NutritionGoals(
        calories: 2200,
        protein: 150.0,
        carbs: 220.0,
        fat: 75.0,
      );
      todaysFoods = [];
      recentFoods = [];
      favoriteFoods = [];
      quickAddFoods = [];
      foodSearchHistory = {};
      sleepGoal = 8.0;
      hoursSlept = 7.5;
      weekSleep = [];
      totalWorkoutsCompleted = 0;
      lastWorkoutDate = DateTime.now();
      currentRank = FitnessRank.tinIII;
      availableEquipment = {
        'dumbbells': EquipmentItem('Dumbbells', false, maxWeight: 50),
        'barbells': EquipmentItem('Barbells', false, maxWeight: 135),
        'pullup_bar': EquipmentItem('Pull-up Bar', false),
        'flat_bench': EquipmentItem('Flat Bench', false),
        'adjustable_bench': EquipmentItem('Adjustable Bench (Incline/Decline)', false),
        'bench_press': EquipmentItem('Bench Press Station', false, maxWeight: 225),
        'squat_rack': EquipmentItem('Squat Rack', false, maxWeight: 315),
        'cable_machine': EquipmentItem('Cable Machine', false, maxWeight: 200),
        'leg_press': EquipmentItem('Leg Press Machine', false, maxWeight: 400),
        'lat_pulldown': EquipmentItem('Lat Pulldown Machine', false, maxWeight: 150),
        'rowing_machine': EquipmentItem('Rowing Machine', false),
        'treadmill': EquipmentItem('Treadmill', false),
        'stationary_bike': EquipmentItem('Stationary Bike', false),
        'kettlebells': EquipmentItem('Kettlebells', false, maxWeight: 35),
        'resistance_bands': EquipmentItem('Resistance Bands', false),
        'medicine_ball': EquipmentItem('Medicine Ball', false, maxWeight: 20),
        'foam_roller': EquipmentItem('Foam Roller', false),
        'yoga_mat': EquipmentItem('Yoga Mat', false),
        'ab_wheel': EquipmentItem('Ab Wheel', false),
      };
      username = 'Fitness Warrior';
      currentWeight = 0.0;
      goalWeight = 0.0;
      height = 0.0;
      age = 0;
      fitnessGoal = 'Build Muscle';
      joinDate = DateTime.now();
      muscleLastWorked = {
        'chest': DateTime.now().subtract(const Duration(days: 3)),
        'back': DateTime.now().subtract(const Duration(days: 3)),
        'shoulders': DateTime.now().subtract(const Duration(days: 2)),
        'biceps': DateTime.now().subtract(const Duration(days: 2)),
        'triceps': DateTime.now().subtract(const Duration(days: 2)),
        'legs': DateTime.now().subtract(const Duration(days: 4)),
        'glutes': DateTime.now().subtract(const Duration(days: 3)),
        'core': DateTime.now().subtract(const Duration(days: 1)),
        'calves': DateTime.now().subtract(const Duration(days: 3)),
        'forearms': DateTime.now().subtract(const Duration(days: 3)),
      };
      exercisePreferences = {};
      customWorkoutPool = [];
      upperBodyFavorites = [];
      lowerBodyFavorites = [];
      savedWorkouts = [];
      customExerciseInstructions = {};
      exerciseWeightHistory = {};
      workoutHistory = {};
      exerciseSuccessStreak = {};
      exerciseFailureStreak = {};
      lastExerciseAttempt = {};
      hasActiveWorkout = false;
      workoutStartTime = null;
      workoutElapsedSeconds = 0;
      exerciseProgressData = {};
    } catch (e) {
      currentWorkout = [Exercise('Push-ups', 'Chest, Triceps, Shoulders')];
      nutritionGoals = NutritionGoals(calories: 2200, protein: 150.0, carbs: 220.0, fat: 75.0);
      hasActiveWorkout = false;
      exerciseProgressData = {};
    }
  }

  // --- Automatic Resets ---
  void _checkAndResetDailyNutrition() {
    final now = DateTime.now();
    if (now.year != lastNutritionUpdate.year || now.month != lastNutritionUpdate.month || now.day != lastNutritionUpdate.day) {
      todaysFoods = [];
      lastNutritionUpdate = now;
    }
  }

  void _checkAndResetWeeklySleep() {
    final now = DateTime.now();
    int weekNumber(DateTime d) {
      final firstDayOfYear = DateTime(d.year, 1, 1);
      final daysOffset = firstDayOfYear.weekday - 1;
      final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
      return ((d.difference(firstMonday).inDays) / 7).floor() + 1;
    }
    if (weekNumber(now) != weekNumber(lastSleepWeekUpdate) || now.year != lastSleepWeekUpdate.year) {
      weekSleep = [
        SleepEntry('Monday', 0.0),
        SleepEntry('Tuesday', 0.0),
        SleepEntry('Wednesday', 0.0),
        SleepEntry('Thursday', 0.0),
        SleepEntry('Friday', 0.0),
        SleepEntry('Saturday', 0.0),
        SleepEntry('Sunday', 0.0),
      ];
      lastSleepWeekUpdate = now;
    }
  }
} 