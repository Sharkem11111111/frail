import 'package:flutter/material.dart';
import '../data/fitness_data_manager.dart';
import '../models/fitness_models.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FitnessDataManager dataManager = FitnessDataManager();
  List<FoodItem> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    searchResults = FoodDatabase.getAllFoods();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      searchResults = FoodDatabase.searchFoods(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Search', icon: Icon(Icons.search)),
            Tab(text: 'Recent', icon: Icon(Icons.history)),
            Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
            Tab(text: 'Manual', icon: Icon(Icons.edit)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildRecentTab(),
          _buildFavoritesTab(),
          _buildManualTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: _performSearch,
          ),
        ),
        
        // Category Filter Chips
        if (!isSearching) ...[
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: FoodDatabase.getAllCategories().map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          searchResults = FoodDatabase.getFoodsByCategory(category);
                        });
                      } else {
                        setState(() {
                          searchResults = FoodDatabase.getAllFoods();
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Search Results
            Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchResults.length,
                itemBuilder: (context, index) {
              final foodItem = searchResults[index];
                  return Card(
                    child: ListTile(
                  title: Text(foodItem.name),
                  subtitle: Text(
                    '${foodItem.caloriesPer100g} cal/100g • P: ${foodItem.proteinPer100g.toInt()}g • C: ${foodItem.carbsPer100g.toInt()}g • F: ${foodItem.fatPer100g.toInt()}g',
                  ),
                  trailing: const Icon(Icons.add),
                  onTap: () => _showServingSizeDialog(foodItem),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataManager.recentFoods.length,
      itemBuilder: (context, index) {
        final food = dataManager.recentFoods[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.history, color: Colors.blue),
            ),
                      title: Text(food.name),
            subtitle: Text('${food.calories} cal'),
            trailing: const Icon(Icons.add),
            onTap: () => _addRecentFood(food),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataManager.favoriteFoods.length,
      itemBuilder: (context, index) {
        final food = dataManager.favoriteFoods[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.favorite, color: Colors.red),
            ),
            title: Text(food.name),
            subtitle: Text('${food.calories} cal'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    dataManager.removeFromFavorites(food.name);
                    setState(() {});
                  },
                ),
                const Icon(Icons.add),
              ],
            ),
            onTap: () => _addRecentFood(food),
          ),
        );
      },
    );
  }

  Widget _buildManualTab() {
    return _ManualFoodEntry(dataManager: dataManager);
  }

  void _showServingSizeDialog(FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (context) => _ServingSizeDialog(
        foodItem: foodItem,
        onAdd: (foodEntry) {
          dataManager.addFood(foodEntry);
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${foodEntry.name}!')),
                  );
                },
              ),
    );
  }

  void _addRecentFood(FoodEntry food) {
    final newEntry = food.copyWith(timestamp: DateTime.now());
    dataManager.addFood(newEntry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${food.name}!')),
    );
  }
}

// Serving Size Dialog
class _ServingSizeDialog extends StatefulWidget {
  final FoodItem foodItem;
  final Function(FoodEntry) onAdd;

  const _ServingSizeDialog({
    required this.foodItem,
    required this.onAdd,
  });

  @override
  State<_ServingSizeDialog> createState() => __ServingSizeDialogState();
}

class __ServingSizeDialogState extends State<_ServingSizeDialog> {
  final TextEditingController _servingController = TextEditingController(text: '100');
  MealType selectedMealType = MealType.snack;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _servingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servingSize = double.tryParse(_servingController.text) ?? 100.0;
    final multiplier = servingSize / 100.0;
    final calories = (widget.foodItem.caloriesPer100g * multiplier).round();
    final protein = widget.foodItem.proteinPer100g * multiplier;
    final carbs = widget.foodItem.carbsPer100g * multiplier;
    final fat = widget.foodItem.fatPer100g * multiplier;

    return AlertDialog(
      title: Text(widget.foodItem.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Serving Size
            TextField(
              controller: _servingController,
              decoration: const InputDecoration(
                labelText: 'Serving Size (g)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Meal Type Selection
            const Text('Meal Type:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((mealType) {
                return ChoiceChip(
                  label: Text(mealType.displayName),
                  selected: selectedMealType == mealType,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedMealType = mealType);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Nutrition Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition (${servingSize.toInt()}g):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Calories: $calories'),
                    Text('Protein: ${protein.toStringAsFixed(1)}g'),
                    Text('Carbs: ${carbs.toStringAsFixed(1)}g'),
                    Text('Fat: ${fat.toStringAsFixed(1)}g'),
          ],
        ),
      ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final foodEntry = widget.foodItem.toFoodEntry(
              servingSize: servingSize,
              mealType: selectedMealType,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            );
            widget.onAdd(foodEntry);
          },
          child: const Text('Add Food'),
        ),
      ],
    );
  }
}

// Manual Food Entry Widget
class _ManualFoodEntry extends StatefulWidget {
  final FitnessDataManager dataManager;

  const _ManualFoodEntry({required this.dataManager});

  @override
  State<_ManualFoodEntry> createState() => __ManualFoodEntryState();
}

class __ManualFoodEntryState extends State<_ManualFoodEntry> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();
  MealType selectedMealType = MealType.snack;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name*',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a food name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Calories
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter calories';
                }
                if (int.tryParse(value!) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Macronutrients
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Protein (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbs (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: 'Fat (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meal Type
            const Text('Meal Type:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((mealType) {
                return ChoiceChip(
                  label: Text(mealType.displayName),
                  selected: selectedMealType == mealType,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedMealType = mealType);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addManualFood,
                child: const Text('Add Food'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addManualFood() {
    if (_formKey.currentState?.validate() ?? false) {
      final foodEntry = FoodEntry(
        _nameController.text.trim(),
        int.parse(_caloriesController.text),
        protein: double.tryParse(_proteinController.text) ?? 0.0,
        carbs: double.tryParse(_carbsController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        mealType: selectedMealType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      widget.dataManager.addFood(foodEntry);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${foodEntry.name}!')),
      );
    }
  }
}
