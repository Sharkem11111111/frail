import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../games/chess_puzzle.dart';


class StandaloneChessScreen extends StatelessWidget {
  const StandaloneChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Puzzles'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.withOpacity(0.8),
              Colors.orange.withOpacity(0.4),
            ],
          ),
        ),
        child: const SafeArea(
          child: ChessPuzzleGame(
            timeRemaining: 300, // 5 minutes for practice
            onFinishRest: _finishPractice,
          ),
        ),
      ),
    );
  }

  static void _finishPractice() {
    // Just a placeholder - in practice mode we don't need to do anything special
  }
}





class EquipmentToggleCard extends StatefulWidget {
  final String equipmentKey;
  final EquipmentItem equipment;
  final Function(bool) onToggle;
  final Function(double) onWeightChanged;
  final Function(double) onSpecificWeightAdded;
  final Function(double) onSpecificWeightRemoved;

  const EquipmentToggleCard({
    super.key,
    required this.equipmentKey,
    required this.equipment,
    required this.onToggle,
    required this.onWeightChanged,
    required this.onSpecificWeightAdded,
    required this.onSpecificWeightRemoved,
  });

  @override
  State<EquipmentToggleCard> createState() => _EquipmentToggleCardState();
}

class _EquipmentToggleCardState extends State<EquipmentToggleCard> {
  late TextEditingController _weightController;
  late TextEditingController _specificWeightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.equipment.maxWeight?.toString() ?? '',
    );
    _specificWeightController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _specificWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.equipment.isAvailable 
            ? Colors.green.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.equipment.isAvailable 
              ? Colors.green.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Switch(
                value: widget.equipment.isAvailable,
                onChanged: widget.onToggle,
                activeColor: Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.equipment.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: widget.equipment.isAvailable 
                            ? Colors.black87 
                            : Colors.grey[600],
                      ),
                    ),
                    if (widget.equipment.isAvailable && widget.equipment.maxWeight != null)
                      Text(
                        widget.equipment.getWeightDescription(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.equipment.isAvailable && widget.equipment.maxWeight != null)
                Icon(
                  Icons.fitness_center,
                  color: Colors.green[600],
                  size: 20,
                ),
            ],
          ),
          
          // Weight Configuration (only for weighted equipment)
          if (widget.equipment.isAvailable && widget.equipment.maxWeight != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Different UI for multiple weights vs single max weight
                  if (widget.equipment.supportsMultipleWeights)
                    _buildMultipleWeightsSection()
                  else
                    _buildSingleMaxWeightSection(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMultipleWeightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Weight Pairs (lbs)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        
        // Add new weight section
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _specificWeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add weight',
                  suffixText: ' lbs',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                double? weight = double.tryParse(_specificWeightController.text);
                if (weight != null && weight > 0) {
                  widget.onSpecificWeightAdded(weight);
                  _specificWeightController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Quick add buttons
        Text(
          'Quick Add:',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: _getQuickWeightOptions().map((weight) => 
            ElevatedButton(
              onPressed: () {
                widget.onSpecificWeightAdded(weight.toDouble());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(40, 28),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: Text('$weight'),
            ),
          ).toList(),
        ),
        
        // Current weights display
        if (widget.equipment.availableWeights.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Your Available Weights:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: widget.equipment.availableWeights.map((weight) =>
              Chip(
                label: Text('${weight.toInt()} lbs'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => widget.onSpecificWeightRemoved(weight),
                backgroundColor: Colors.green.withOpacity(0.1),
                side: BorderSide(color: Colors.green.withOpacity(0.3)),
                labelStyle: const TextStyle(fontSize: 11),
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleMaxWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Weight Available (lbs)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter max weight',
                  suffixText: ' lbs',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  double? weight = double.tryParse(value);
                  if (weight != null) {
                    widget.onWeightChanged(weight);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            // Quick weight buttons
            ...(_getQuickWeightOptions()).take(3).map((weight) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ElevatedButton(
                onPressed: () {
                  _weightController.text = weight.toString();
                  widget.onWeightChanged(weight.toDouble());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(40, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text('$weight'),
              ),
            )).toList(),
          ],
        ),
      ],
    );
  }

  List<int> _getQuickWeightOptions() {
    String equipmentName = widget.equipment.name.toLowerCase();
    if (equipmentName.contains('dumbbell')) {
      return [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
    } else if (equipmentName.contains('barbell') || equipmentName.contains('bench press')) {
      return [135, 155, 185, 205, 225, 275, 315];
    } else if (equipmentName.contains('kettlebell')) {
      return [10, 15, 20, 25, 30, 35, 40, 50];
    } else if (equipmentName.contains('medicine ball')) {
      return [6, 8, 10, 12, 15, 20, 25];
    } else {
      return [50, 100, 150, 200];
    }
  }
}

// AI Trainer Chat Screen



