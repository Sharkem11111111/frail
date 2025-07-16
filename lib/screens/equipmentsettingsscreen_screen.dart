import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frail/providers/fitness_data_provider.dart';

class EquipmentSettingsScreen extends StatefulWidget {
  const EquipmentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentSettingsScreen> createState() => _EquipmentSettingsScreenState();
}

class _EquipmentSettingsScreenState extends State<EquipmentSettingsScreen> {
  final Map<String, TextEditingController> _weightControllers = {};

  @override
  void dispose() {
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentMap = context.watch<FitnessDataProvider>().availableEquipment;
    final equipmentKeys = equipmentMap.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Settings')),
      body: ListView.builder(
        itemCount: equipmentKeys.length,
        itemBuilder: (context, idx) {
          final key = equipmentKeys[idx];
          final item = equipmentMap[key]!;
          _weightControllers.putIfAbsent(key, () => TextEditingController());
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: item.isAvailable,
                        onChanged: (val) {
                          context.read<FitnessDataProvider>().toggleEquipment(key, val);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.isAvailable ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.isAvailable) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightControllers[key],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Add weight (lbs)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final text = _weightControllers[key]!.text;
                            final weight = double.tryParse(text);
                            if (weight != null && weight > 0) {
                              context.read<FitnessDataProvider>().addSpecificWeight(key, weight);
                              _weightControllers[key]!.clear();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (item.availableWeights.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: item.availableWeights.map((w) => Chip(
                          label: Text('${w.toInt()} lbs'),
                          onDeleted: () {
                            context.read<FitnessDataProvider>().removeSpecificWeight(key, w);
                          },
                        )).toList(),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
