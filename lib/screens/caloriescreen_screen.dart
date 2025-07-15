import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';
import 'nutritiongoalsscreen_screen.dart';
import 'addfoodscreen_screen.dart';

class CalorieScreen extends StatefulWidget {
  const CalorieScreen({super.key});

  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> with TickerProviderStateMixin {
  final FitnessDataManager dataManager = FitnessDataManager();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    dataManager.onCaloriesChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today', icon: Icon(Icons.today)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NutritionGoalsScreen()),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFoodScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
    );
  }

  Widget _buildTodayTab() {
    final progress = dataManager.caloriesConsumed / dataManager.calorieGoal;
    
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Nutrition Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildNutritionCard(
                  'Calories',
                  '${dataManager.caloriesConsumed}',
                  '${dataManager.calorieGoal}',
                  progress,
                  Colors.blue,
                  'cal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutritionCard(
                  'Protein',
                  '${dataManager.proteinConsumed.toInt()}',
                  '${dataManager.nutritionGoals.protein.toInt()}',
                  dataManager.proteinConsumed / dataManager.nutritionGoals.protein,
                  Colors.red,
                  'g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutritionCard(
                  'Carbs',
                  '${dataManager.carbsConsumed.toInt()}',
                  '${dataManager.nutritionGoals.carbs.toInt()}',
                  dataManager.carbsConsumed / dataManager.nutritionGoals.carbs,
                  Colors.orange,
                  'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutritionCard(
                  'Fat',
                  '${dataManager.fatConsumed.toInt()}',
                  '${dataManager.nutritionGoals.fat.toInt()}',
                  dataManager.fatConsumed / dataManager.nutritionGoals.fat,
                  Colors.green,
                  'g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Add Section
          if (dataManager.quickAddFoods.isNotEmpty) ...[
            Text(
              'Quick Add',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dataManager.quickAddFoods.length,
                itemBuilder: (context, index) {
                  final food = dataManager.quickAddFoods[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${food.name}\n${food.calories} cal'),
                      onSelected: (selected) {
                        if (selected) {
                          dataManager.addFood(food.copyWith(timestamp: DateTime.now()));
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Meals Section
          ...MealType.values.map((mealType) => _buildMealSection(mealType)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
                child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
            'Weekly Nutrition Trends',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Coming Soon!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                    Text(
                    'Charts showing your nutrition trends, macro ratios, and goal progress over time.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.analytics, size: 48, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
    String title,
    String consumed,
    String goal,
    double progress,
    Color color,
    String unit,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
            const SizedBox(height: 4),
            Text(
              '$consumed$unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 4),
            Text(
              'Goal: $goal$unit',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(MealType mealType) {
    final foods = dataManager.foodsByMeal[mealType] ?? [];
    final calories = dataManager.caloriesByMeal[mealType] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Row(
              children: [
                Icon(mealType.icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  mealType.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '$calories cal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (foods.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    'No foods logged for ${mealType.displayName.toLowerCase()}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...foods.map((food) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getMealColor(mealType).withOpacity(0.1),
                child: Icon(mealType.icon, color: _getMealColor(mealType)),
              ),
              title: Text(food.name),
              subtitle: Text(
                'P: ${food.protein.toInt()}g • C: ${food.carbs.toInt()}g • F: ${food.fat.toInt()}g',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${food.calories} cal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatTime(food.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              onLongPress: () => _showFoodOptions(food),
            ),
          )),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getMealColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month}/${dateTime.day}';
  }

  void _showFoodOptions(FoodEntry food) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Add to Favorites'),
            onTap: () {
              dataManager.addToFavorites(food);
              Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: const Text('Add to Quick Add'),
            onTap: () {
              dataManager.addToQuickAdd(food);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to quick add!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Remove'),
            onTap: () {
              dataManager.removeFoodEntry(food);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Food removed')),
              );
            },
                ),
              ],
            ),
         );
   }
 }
