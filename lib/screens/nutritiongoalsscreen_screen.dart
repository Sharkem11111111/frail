import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';

class NutritionGoalsScreen extends StatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  State<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends State<NutritionGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final goals = context.watch<FitnessDataProvider>().nutritionGoals;
    _caloriesController = TextEditingController(text: goals.calories.toString());
    _proteinController = TextEditingController(text: goals.protein.toString());
    _carbsController = TextEditingController(text: goals.carbs.toString());
    _fatController = TextEditingController(text: goals.fat.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Goals'),
        actions: [
          TextButton(
            onPressed: _saveGoals,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Nutrition Goals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Calories
                      TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                          suffixText: 'cal',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumber,
                      ),
                      const SizedBox(height: 16),

                      // Protein
                      TextFormField(
                        controller: _proteinController,
                        decoration: const InputDecoration(
                          labelText: 'Protein',
                          border: OutlineInputBorder(),
                          suffixText: 'g',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumber,
                      ),
                      const SizedBox(height: 16),

                      // Carbs
                      TextFormField(
                        controller: _carbsController,
                        decoration: const InputDecoration(
                          labelText: 'Carbohydrates',
                          border: OutlineInputBorder(),
                          suffixText: 'g',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumber,
                      ),
                      const SizedBox(height: 16),

                      // Fat
                      TextFormField(
                        controller: _fatController,
                        decoration: const InputDecoration(
                          labelText: 'Fat',
                          border: OutlineInputBorder(),
                          suffixText: 'g',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preset Goals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preset Goals',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildPresetButton('Weight Loss', 1800, 140, 180, 60),
                      _buildPresetButton('Maintenance', 2200, 150, 220, 75),
                      _buildPresetButton('Muscle Gain', 2600, 180, 260, 85),
                      _buildPresetButton('Athletic', 2800, 200, 280, 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(String name, int calories, int protein, int carbs, int fat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _setPresetGoals(calories, protein, carbs, fat),
          child: Column(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$calories cal • P: ${protein}g • C: ${carbs}g • F: ${fat}g'),
            ],
          ),
        ),
      ),
    );
  }

  void _setPresetGoals(int calories, int protein, int carbs, int fat) {
    setState(() {
      _caloriesController.text = calories.toString();
      _proteinController.text = protein.toString();
      _carbsController.text = carbs.toString();
      _fatController.text = fat.toString();
    });
  }

  String? _validateNumber(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter a value';
    }
    if (double.tryParse(value!) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  void _saveGoals() {
    if (_formKey.currentState?.validate() ?? false) {
      final newGoals = NutritionGoals(
        calories: int.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
      );

      context.read<FitnessDataProvider>().updateNutritionGoals(newGoals);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nutrition goals updated!')),
      );
    }
  }
}
