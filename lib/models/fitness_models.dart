import 'package:flutter/material.dart';

// Exercise Model
class Exercise {
  String name;
  String muscles;
  int sets;
  int reps;
  double weight;
  bool isCompleted;
  int completedSets;
  int completedReps;

  Exercise(this.name, this.muscles, {
    this.sets = 3,
    this.reps = 8,
    this.weight = 0.0,
    this.isCompleted = false,
    this.completedSets = 0,
    this.completedReps = 0,
  });

  Exercise copyWith({
    String? name,
    String? muscles,
    int? sets,
    int? reps,
    double? weight,
    bool? isCompleted,
    int? completedSets,
    int? completedReps,
  }) {
    return Exercise(
      name ?? this.name,
      muscles ?? this.muscles,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      completedSets: completedSets ?? this.completedSets,
      completedReps: completedReps ?? this.completedReps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscles': muscles,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'completedSets': completedSets,
      'completedReps': completedReps,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      json['name'] ?? '',
      json['muscles'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 8,
      weight: json['weight'] ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
      completedSets: json['completedSets'] ?? 0,
      completedReps: json['completedReps'] ?? 0,
    );
  }
}

// Food Entry Model
enum MealType { 
  breakfast, 
  lunch, 
  dinner, 
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.wb_cloudy;
      case MealType.dinner:
        return Icons.nightlight_round;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}

class FoodEntry {
  String name;
  int calories;
  double protein;
  double carbs;
  double fat;
  double fiber;
  double sodium;
  MealType mealType;
  bool isFavorite;
  DateTime timestamp;
  String? notes;

  FoodEntry(this.name, this.calories, {
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sodium = 0.0,
    this.mealType = MealType.snack,
    this.isFavorite = false,
    DateTime? timestamp,
    this.notes,
  }) : timestamp = timestamp ?? DateTime.now();

  FoodEntry copyWith({
    String? name,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sodium,
    MealType? mealType,
    bool? isFavorite,
    DateTime? timestamp,
    String? notes,
  }) {
    return FoodEntry(
      name ?? this.name,
      calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      mealType: mealType ?? this.mealType,
      isFavorite: isFavorite ?? this.isFavorite,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
      'mealType': mealType.index,
      'isFavorite': isFavorite,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      json['name'] ?? '',
      json['calories'] ?? 0,
      protein: json['protein'] ?? 0.0,
      carbs: json['carbs'] ?? 0.0,
      fat: json['fat'] ?? 0.0,
      fiber: json['fiber'] ?? 0.0,
      sodium: json['sodium'] ?? 0.0,
      mealType: MealType.values[json['mealType'] ?? 0],
      isFavorite: json['isFavorite'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }
}

// Food Item Model
class FoodItem {
  final String name;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final List<String> categories;
  final List<String> searchTerms;

  FoodItem({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.categories,
    required this.searchTerms,
  });

  FoodEntry toFoodEntry({
    required double servingSize, // in grams
    required MealType mealType,
    String? notes,
    bool isFavorite = false,
  }) {
    final multiplier = servingSize / 100.0;
    return FoodEntry(
      name,
      (caloriesPer100g * multiplier).round(),
      protein: proteinPer100g * multiplier,
      carbs: carbsPer100g * multiplier,
      fat: fatPer100g * multiplier,
      mealType: mealType,
    );
  }
}

// Food Database
class FoodDatabase {
  static final List<FoodItem> _foodItems = [
    FoodItem(
      name: 'Chicken Breast',
      caloriesPer100g: 165,
      proteinPer100g: 31.0,
      carbsPer100g: 0.0,
      fatPer100g: 3.6,
      categories: ['protein', 'meat', 'poultry'],
      searchTerms: ['chicken', 'breast', 'protein', 'lean'],
    ),
    FoodItem(
      name: 'Salmon',
      caloriesPer100g: 208,
      proteinPer100g: 25.0,
      carbsPer100g: 0.0,
      fatPer100g: 12.0,
      categories: ['protein', 'fish', 'omega3'],
      searchTerms: ['salmon', 'fish', 'protein', 'healthy'],
    ),
    FoodItem(
      name: 'Brown Rice',
      caloriesPer100g: 111,
      proteinPer100g: 2.6,
      carbsPer100g: 23.0,
      fatPer100g: 0.9,
      categories: ['carbs', 'grain', 'complex'],
      searchTerms: ['rice', 'brown', 'carbs', 'grain'],
    ),
    FoodItem(
      name: 'Sweet Potato',
      caloriesPer100g: 86,
      proteinPer100g: 1.6,
      carbsPer100g: 20.0,
      fatPer100g: 0.1,
      categories: ['carbs', 'vegetable', 'complex'],
      searchTerms: ['sweet', 'potato', 'carbs', 'vegetable'],
    ),
    FoodItem(
      name: 'Broccoli',
      caloriesPer100g: 34,
      proteinPer100g: 2.8,
      carbsPer100g: 7.0,
      fatPer100g: 0.4,
      categories: ['vegetable', 'fiber', 'vitamins'],
      searchTerms: ['broccoli', 'vegetable', 'green', 'healthy'],
    ),
    FoodItem(
      name: 'Greek Yogurt',
      caloriesPer100g: 59,
      proteinPer100g: 10.0,
      carbsPer100g: 3.6,
      fatPer100g: 0.4,
      categories: ['protein', 'dairy', 'probiotic'],
      searchTerms: ['yogurt', 'greek', 'protein', 'dairy'],
    ),
    FoodItem(
      name: 'Eggs',
      caloriesPer100g: 155,
      proteinPer100g: 13.0,
      carbsPer100g: 1.1,
      fatPer100g: 11.0,
      categories: ['protein', 'breakfast', 'versatile'],
      searchTerms: ['eggs', 'protein', 'breakfast', 'versatile'],
    ),
    FoodItem(
      name: 'Oatmeal',
      caloriesPer100g: 68,
      proteinPer100g: 2.4,
      carbsPer100g: 12.0,
      fatPer100g: 1.4,
      categories: ['carbs', 'breakfast', 'fiber'],
      searchTerms: ['oatmeal', 'oats', 'breakfast', 'carbs'],
    ),
    FoodItem(
      name: 'Banana',
      caloriesPer100g: 89,
      proteinPer100g: 1.1,
      carbsPer100g: 23.0,
      fatPer100g: 0.3,
      categories: ['fruit', 'carbs', 'potassium'],
      searchTerms: ['banana', 'fruit', 'carbs', 'potassium'],
    ),
    FoodItem(
      name: 'Almonds',
      caloriesPer100g: 579,
      proteinPer100g: 21.0,
      carbsPer100g: 22.0,
      fatPer100g: 50.0,
      categories: ['nuts', 'protein', 'healthy fats'],
      searchTerms: ['almonds', 'nuts', 'protein', 'healthy fats'],
    ),
  ];

  static List<FoodItem> getAllFoodItems() {
    return _foodItems;
  }

  static List<FoodItem> searchFoodItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _foodItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
             item.searchTerms.any((term) => term.toLowerCase().contains(lowercaseQuery)) ||
             item.categories.any((category) => category.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static List<FoodItem> getFoodItemsByCategory(String category) {
    return _foodItems.where((item) {
      return item.categories.contains(category.toLowerCase());
    }).toList();
  }

  // Additional methods for compatibility
  static List<FoodItem> getAllFoods() {
    return _foodItems;
  }

  static List<FoodItem> searchFoods(String query) {
    return searchFoodItems(query);
  }

  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final item in _foodItems) {
      categories.addAll(item.categories);
    }
    return categories.toList();
  }

  static List<FoodItem> getFoodsByCategory(String category) {
    return getFoodItemsByCategory(category);
  }
}

// Nutrition Goals Model
class NutritionGoals {
  int calories;
  double protein;
  double carbs;
  double fat;
  double fiber;
  double sodium;

  NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 25.0,
    this.sodium = 2300.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
    };
  }

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0.0,
      carbs: json['carbs'] ?? 0.0,
      fat: json['fat'] ?? 0.0,
      fiber: json['fiber'] ?? 25.0,
      sodium: json['sodium'] ?? 2300.0,
    );
  }
}

// Sleep Entry Model
class SleepEntry {
  String day;
  double hours;

  SleepEntry(this.day, this.hours);
}

// Fitness Rank Enum
enum FitnessRank {
  tinIII('Tin III', Colors.grey, 'assets/icons/tin.png'),
  tinII('Tin II', Colors.grey, 'assets/icons/tin.png'),
  tinI('Tin I', Colors.grey, 'assets/icons/tin.png'),
  ironIII('Iron III', Colors.orange, 'assets/icons/iron.png'),
  ironII('Iron II', Colors.orange, 'assets/icons/iron.png'),
  ironI('Iron I', Colors.orange, 'assets/icons/iron.png'),
  bronzeIII('Bronze III', Colors.brown, 'assets/icons/bronze.png'),
  bronzeII('Bronze II', Colors.brown, 'assets/icons/bronze.png'),
  bronzeI('Bronze I', Colors.brown, 'assets/icons/bronze.png'),
  silverIII('Silver III', Colors.grey, 'assets/icons/silver.png'),
  silverII('Silver II', Colors.grey, 'assets/icons/silver.png'),
  silverI('Silver I', Colors.grey, 'assets/icons/silver.png'),
  goldIII('Gold III', Colors.yellow, 'assets/icons/gold.png'),
  goldII('Gold II', Colors.yellow, 'assets/icons/gold.png'),
  goldI('Gold I', Colors.yellow, 'assets/icons/gold.png'),
  platinumIII('Platinum III', Colors.blue, 'assets/icons/platinum.png'),
  platinumII('Platinum II', Colors.blue, 'assets/icons/platinum.png'),
  platinumI('Platinum I', Colors.blue, 'assets/icons/platinum.png'),
  diamondIII('Diamond III', Colors.cyan, 'assets/icons/diamond.png'),
  diamondII('Diamond II', Colors.cyan, 'assets/icons/diamond.png'),
  diamondI('Diamond I', Colors.cyan, 'assets/icons/diamond.png'),
  master('Master', Colors.purple, 'assets/icons/master.png'),
  grandmaster('Grandmaster', Colors.red, 'assets/icons/grandmaster.png'),
  challenger('Challenger', Colors.deepPurple, 'assets/icons/challenger.png');

  const FitnessRank(this.displayName, this.color, this.iconPath);
  final String displayName;
  final Color color;
  final String iconPath;
}

// Equipment Item Model
class EquipmentItem {
  String name;
  bool isAvailable;
  double maxWeight;
  List<double> availableWeights;
  bool supportsMultipleWeights;

  EquipmentItem(this.name, this.isAvailable, {
    this.maxWeight = 0.0,
    List<double>? availableWeights,
    this.supportsMultipleWeights = false,
  }) : availableWeights = availableWeights?.toList() ?? [];

  String getWeightDescription() {
    if (availableWeights.isEmpty) {
      return 'Bodyweight';
    }
    return availableWeights.map((w) => '${w.toInt()} lbs').join(', ');
  }
}

// Exercise Instructions Model
class ExerciseInstructions {
  String name;
  String description;
  List<String> steps;
  List<String> tips;
  String difficulty;
  String equipment;

  ExerciseInstructions({
    required this.name,
    required this.description,
    required this.steps,
    required this.tips,
    required this.difficulty,
    required this.equipment,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'steps': steps,
      'tips': tips,
      'difficulty': difficulty,
      'equipment': equipment,
    };
  }

  factory ExerciseInstructions.fromJson(Map<String, dynamic> json) {
    return ExerciseInstructions(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      difficulty: json['difficulty'] ?? '',
      equipment: json['equipment'] ?? '',
    );
  }
}

// Workout Session Model
class WorkoutSession {
  String name;
  DateTime date;
  List<Exercise> exercises;
  int durationMinutes;
  bool completed;
  int completedSets;
  int completedReps;

  WorkoutSession({
    required this.name,
    required this.date,
    required this.exercises,
    required this.durationMinutes,
    this.completed = false,
    this.completedSets = 0,
    this.completedReps = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'durationMinutes': durationMinutes,
      'completed': completed,
      'completedSets': completedSets,
      'completedReps': completedReps,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      name: json['name'] ?? '',
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
      durationMinutes: json['durationMinutes'] ?? 0,
      completed: json['completed'] ?? false,
      completedSets: json['completedSets'] ?? 0,
      completedReps: json['completedReps'] ?? 0,
    );
  }
}

// Saved Workout Model
class SavedWorkout {
  String id;
  String name;
  String description;
  List<Exercise> exercises;
  DateTime createdDate;

  SavedWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory SavedWorkout.fromJson(Map<String, dynamic> json) {
    return SavedWorkout(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

// Chat Message Model
class ChatMessage {
  String text;
  bool isUser;
  DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// Chat Session Model
class ChatSession {
  String title;
  List<ChatMessage> messages;
  DateTime lastUpdated;

  ChatSession({
    required this.title,
    required this.messages,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      title: json['title'] ?? '',
      messages: (json['messages'] as List?)
          ?.map((m) => ChatMessage.fromJson(m))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

// Workout History Model
class WorkoutHistory {
  final String name;
  final DateTime date;
  final int durationMinutes;
  final List<String> exercises;
  final bool completed;
  final DateTime startTime;
  final DateTime endTime;
  final List<ExerciseDetail> exerciseDetails;

  WorkoutHistory(this.name, this.date, this.durationMinutes, this.exercises, this.completed, this.startTime, this.endTime, this.exerciseDetails);
}

// Exercise Detail Model
class ExerciseDetail {
  final String name;
  final int sets;
  final int reps;
  final double weight;

  ExerciseDetail(this.name, this.sets, this.reps, this.weight);
}

// Exercise Progress Model
class ExerciseProgress {
  Exercise exercise;
  int currentSet;
  int repsCompleted;
  int setsCompleted;
  bool isCompleted;

  ExerciseProgress({
    required this.exercise,
    required this.currentSet,
    required this.repsCompleted,
    required this.setsCompleted,
    required this.isCompleted,
  });
}

// Achievement Model
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });
}

// Exercise Database (Static)
class ExerciseDatabase {
  static final Map<String, ExerciseInstructions> _instructions = {
    'push-ups': ExerciseInstructions(
      name: 'Push-ups',
      description: 'A classic bodyweight exercise that targets chest, triceps, and shoulders.',
      steps: [
        'Start in a plank position with hands slightly wider than shoulders',
        'Lower your body until chest nearly touches the ground',
        'Push back up to the starting position',
        'Keep your core tight throughout the movement'
      ],
      tips: [
        "Keep your body in a straight line",
        "Don't let your hips sag",
        "Breathe steadily throughout the movement"
      ],
      difficulty: 'Beginner',
      equipment: 'None',
    ),
    'squats': ExerciseInstructions(
      name: 'Squats',
      description: 'A fundamental lower body exercise that targets quads, glutes, and hamstrings.',
      steps: [
        'Stand with feet shoulder-width apart',
        'Lower your body as if sitting back into a chair',
        'Keep your knees behind your toes',
        'Return to standing position'
      ],
      tips: [
        "Keep your chest up",
        "Push through your heels",
        "Don't let your knees cave inward"
      ],
      difficulty: 'Beginner',
      equipment: 'None',
    ),
    // Add more exercises as needed
  };

  static ExerciseInstructions? getInstructions(String exerciseName) {
    return _instructions[exerciseName.toLowerCase()];
  }
}
