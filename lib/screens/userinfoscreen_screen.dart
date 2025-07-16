import 'package:flutter/material.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  FitnessDataProvider get dataProvider => context.watch<FitnessDataProvider>();
  
  late TextEditingController _usernameController;
  late TextEditingController _currentWeightController;
  late TextEditingController _goalWeightController;
  late TextEditingController _heightFeetController;
  late TextEditingController _heightInchesController;
  late TextEditingController _ageController;

  final List<String> fitnessGoals = [
    'Build Muscle',
    'Lose Weight', 
    'Get Stronger',
    'Improve Endurance',
    'Maintain Weight',
    'General Fitness'
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: dataProvider.username.isNotEmpty ? dataProvider.username : ''
    );
    _currentWeightController = TextEditingController(
      text: dataProvider.currentWeight > 0 ? dataProvider.currentWeight.toString() : ''
    );
    _goalWeightController = TextEditingController(
      text: dataProvider.goalWeight > 0 ? dataProvider.goalWeight.toString() : ''
    );
    // Convert total inches back to feet and inches for display
    int totalInches = dataProvider.height.toInt();
    int feet = totalInches ~/ 12;
    int inches = totalInches % 12;
    
    _heightFeetController = TextEditingController(
      text: feet > 0 ? feet.toString() : ''
    );
    _heightInchesController = TextEditingController(
      text: inches > 0 ? inches.toString() : ''
    );
    _ageController = TextEditingController(
      text: dataProvider.age > 0 ? dataProvider.age.toString() : ''
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      dataProvider.username.isNotEmpty ? dataProvider.username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dataProvider.username.isNotEmpty ? dataProvider.username : 'Your Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dataProvider.getBMI() > 0)
                    Text(
                      'BMI: ${dataProvider.getBMI().toStringAsFixed(1)} (${dataProvider.getBMICategory()})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),

            // Profile Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Basic Information
                  _buildSectionCard(
                    'Basic Information',
                    Icons.person,
                    [
                      _buildTextField(
                        'Username',
                        _usernameController,
                        'Enter your name',
                        onChanged: (value) => dataProvider.updateUsername(value),
                      ),
                      _buildNumberField(
                        'Age',
                        _ageController,
                        'Enter your age',
                        suffix: 'years',
                        onChanged: (value) {
                          int? age = int.tryParse(value);
                          if (age != null) dataProvider.updateAge(age);
                        },
                      ),
                      _buildHeightField(),
                    ],
                  ),

                  // Weight Information
                  _buildSectionCard(
                    'Weight & Goals',
                    Icons.monitor_weight,
                    [
                      _buildNumberField(
                        'Current Weight',
                        _currentWeightController,
                        'Enter current weight',
                        suffix: ' lbs',
                        onChanged: (value) {
                          double? weight = double.tryParse(value);
                          if (weight != null) dataProvider.updateWeight(weight);
                        },
                      ),
                      _buildNumberField(
                        'Goal Weight',
                        _goalWeightController,
                        'Enter goal weight',
                        suffix: ' lbs',
                        onChanged: (value) {
                          double? weight = double.tryParse(value);
                          if (weight != null) dataProvider.updateGoalWeight(weight);
                        },
                      ),
                      _buildDropdownField(
                        'Fitness Goal',
                        dataProvider.fitnessGoal,
                        fitnessGoals,
                        onChanged: (value) {
                          if (value != null) dataProvider.updateFitnessGoal(value);
                        },
                      ),
                    ],
                  ),

                  // Progress Summary
                  if (dataProvider.currentWeight > 0)
                    _buildProgressCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, String hint, 
      {String? suffix, String? helpText, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          helperText: helpText,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, {Function(String?)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: options.contains(value) ? value : options.first,
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildHeightField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Height',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _heightFeetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '6',
                    suffixText: 'ft',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  onChanged: _updateHeightFromFeetInches,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _heightInchesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '0',
                    suffixText: 'in',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  onChanged: _updateHeightFromFeetInches,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Enter feet and inches separately',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _updateHeightFromFeetInches(String value) {
    int feet = int.tryParse(_heightFeetController.text) ?? 0;
    int inches = int.tryParse(_heightInchesController.text) ?? 0;
    
    // Validate inches (should be 0-11)
    if (inches > 11) {
      inches = 11;
      _heightInchesController.text = '11';
    }
    
    // Convert to total inches and update data manager
    double totalInches = (feet * 12 + inches).toDouble();
    dataProvider.updateHeight(totalInches);
  }

  Widget _buildProgressCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Progress Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Current', '${dataProvider.currentWeight.toInt()} lbs'),
                _buildStatItem('Goal', '${dataProvider.goalWeight.toInt()} lbs'),
                _buildStatItem('BMI', dataProvider.getBMI().toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dataProvider.getWeightProgressText(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Profile saved successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}
