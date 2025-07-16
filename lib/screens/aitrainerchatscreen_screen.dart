import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import '../models/fitness_models.dart';
import '../widgets/chatbubble_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AiTrainerChatScreen extends StatefulWidget {
  const AiTrainerChatScreen({super.key});

  @override
  State<AiTrainerChatScreen> createState() => _AiTrainerChatScreenState();
}

class _AiTrainerChatScreenState extends State<AiTrainerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final List<String> _aiActions = [];
  List<ChatSession> _chatSessions = [];
  int _currentSessionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedSessions = prefs.getStringList('chat_sessions');
    if (savedSessions != null && savedSessions.isNotEmpty) {
      setState(() {
        _chatSessions.clear();
        for (String sessionJson in savedSessions) {
          try {
            final Map<String, dynamic> sessionData = jsonDecode(sessionJson);
            _chatSessions.add(ChatSession.fromJson(sessionData));
          } catch (e) {
            print('Error loading chat session: $e');
          }
        }
        if (_chatSessions.isNotEmpty) {
          _currentSessionIndex = 0;
          _messages.clear();
          _messages.addAll(_chatSessions[_currentSessionIndex].messages);
        }
      });
    } else {
      _createNewSession();
    }
  }

  Future<void> _saveChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    if (_chatSessions.isNotEmpty && _currentSessionIndex < _chatSessions.length) {
      _chatSessions[_currentSessionIndex].messages = List.from(_messages);
      _chatSessions[_currentSessionIndex].lastUpdated = DateTime.now();
      if (_chatSessions[_currentSessionIndex].title == 'New Chat' && _messages.length > 1) {
        final firstUserMessage = _messages.firstWhere((m) => m.isUser, orElse: () => _messages.first);
        String title = firstUserMessage.text.length > 30 
            ? '${firstUserMessage.text.substring(0, 30)}...'
            : firstUserMessage.text;
        _chatSessions[_currentSessionIndex].title = title;
      }
    }
    if (_chatSessions.length > 6) {
      _chatSessions = _chatSessions.sublist(0, 6);
      if (_currentSessionIndex >= _chatSessions.length) {
        _currentSessionIndex = 0;
      }
    }
    final List<String> sessionJsonList = _chatSessions
        .map((session) => json.encode(session.toJson()))
        .toList();
    await prefs.setStringList('chat_sessions', sessionJsonList);
  }

  void _createNewSession() {
    final newSession = ChatSession(
      title: 'New Chat',
      messages: [],
      lastUpdated: DateTime.now(),
    );
    setState(() {
      _chatSessions.insert(0, newSession);
      _currentSessionIndex = 0;
      _messages.clear();
    });
    _addWelcomeMessage();
    _saveChatSessions();
  }

  void _switchToSession(int index) {
    if (index < _chatSessions.length) {
      _saveChatSessions();
      setState(() {
        _currentSessionIndex = index;
        _messages.clear();
        _messages.addAll(_chatSessions[index].messages);
      });
    }
  }

  void _addWelcomeMessage() {
    final dataManager = Provider.of<FitnessDataProvider>(context, listen: false);
    final username = dataManager.username != 'Fitness Warrior' ? dataManager.username : 'there';
    setState(() {
      _messages.add(ChatMessage(
        text: "Hi $username! I'm your AI fitness trainer powered by Google Gemini! 🤖\n\nI can help you:\n• Get workout recommendations\n• Modify exercises if something hurts\n• Adjust your routine based on your progress\n• Answer fitness questions\n\n💡 I know your current workout history and can give personalized advice!\n\nWhat would you like to work on today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  // --- Restore missing methods from backup ---
  void _showSessionList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chat Sessions'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _chatSessions.length,
              itemBuilder: (context, index) {
                final session = _chatSessions[index];
                final isCurrentSession = index == _currentSessionIndex;
                return ListTile(
                  leading: Icon(
                    Icons.chat_bubble,
                    color: isCurrentSession ? Theme.of(context).primaryColor : null,
                  ),
                  title: Text(
                    session.title,
                    style: TextStyle(
                      fontWeight: isCurrentSession ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    ' ${session.messages.length} messages • ${_formatSessionDate(session.lastUpdated)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isCurrentSession ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    _switchToSession(index);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _clearChat() async {
    setState(() {
      _messages.clear();
    });
    _addWelcomeMessage();
    await _saveChatSessions();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _detectAndAddFood(String message) async {
    final messageLower = message.toLowerCase();
    final dataManager = Provider.of<FitnessDataProvider>(context, listen: false);
    final foodKeywords = [
      'ate', 'eating', 'eaten', 'had', 'consumed', 'drank', 'snack',
      'breakfast', 'lunch', 'dinner', 'meal', 'food', 'drank'
    ];
    bool containsFoodKeyword = foodKeywords.any((keyword) => messageLower.contains(keyword));
    if (!containsFoodKeyword) return;
    List<String> potentialFoods = _extractFoodItems(message);
    if (potentialFoods.isEmpty) return;
    
    // Deduplicate food items to prevent multiple additions
    final Set<String> uniqueFoods = potentialFoods.toSet();
    
    for (String foodItem in uniqueFoods) {
      try {
        final nutritionInfo = await _searchFoodNutrition(foodItem);
        if (nutritionInfo != null) {
          dataManager.addFood(nutritionInfo);
          _aiActions.add('🍽️ Added ${nutritionInfo.name} (${nutritionInfo.calories} cal, ${nutritionInfo.protein}g protein) to your daily tracking');
        }
      } catch (e) {
        print('Error searching for food nutrition: $e');
      }
    }
  }

  Future<String> _getGeminiChatResponse(String userMessage) async {
    const String apiKey = 'AIzaSyDRkbPi5aB5xPWHj49vkWGAThS9XN4Srys';
    final String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
    final dataManager = Provider.of<FitnessDataProvider>(context, listen: false);
    // Build chat context from recent messages (last 10)
    final chatHistory = _messages.takeLast(10).map((m) =>
      (m.isUser ? 'USER: ' : 'AI: ') + m.text.trim()
    ).join('\n');
    final String userContext = '''
USER FITNESS CONTEXT:
${dataManager.getMuscleRecoveryStatus()}
Available equipment: ${dataManager.getAvailableEquipmentNames().join(', ')}
${dataManager.getPreferencesForAI()}

CHAT HISTORY (most recent last):
$chatHistory

USER MESSAGE:
$userMessage

TASK: Respond as a helpful, expert AI fitness trainer. Give clear, concise, and friendly advice. If the user asks for a workout, you may suggest one, but otherwise answer their question or provide guidance. If you need to reference the user's fitness data, use the context above.
''';
    try {
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
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String aiResponse = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return aiResponse.trim();
      } else {
        print('Gemini HTTP Error: ${response.statusCode} - ${response.body}');
        return 'Sorry, I could not connect to the AI service.';
      }
    } catch (e) {
      print('Gemini error: $e');
      return 'Sorry, there was an error connecting to the AI service.';
    }
  }

  // Replace _getAiResponse to use Gemini
  Future<String> _getAiResponse(String message) async {
    return await _getGeminiChatResponse(message);
  }

  // --- Add missing methods from backup ---
  List<String> _extractFoodItems(String message) {
    List<String> foodItems = [];
    // Enhanced food patterns to capture brands and quantities
    final foodPatterns = [
      // "X for breakfast/lunch/dinner" - most specific
      RegExp(r'([^,.!?]+)\s+(?:for|as)\s+(?:breakfast|lunch|dinner|meal|snack)', caseSensitive: false),
      // "I ate X" or "I had X" - medium specificity
      RegExp(r'(?:ate|had|consumed|drank)\s+([^,.!?]+)', caseSensitive: false),
      // "I'm eating X" - less specific
      RegExp(r'(?:eating|ate|had)\s+([^,.!?]+)', caseSensitive: false),
      // Brand-specific patterns
      RegExp(r'([a-zA-Z\s]+)\s+(?:greek yogurt|protein|bar|bread|cereal|milk)', caseSensitive: false),
      // Quantity patterns
      RegExp(r'(\d+\s*[a-zA-Z\s]+)', caseSensitive: false),
    ];
    
    // Track processed positions to avoid overlapping matches
    final Set<int> processedPositions = {};
    
    for (RegExp pattern in foodPatterns) {
      final matches = pattern.allMatches(message);
      for (Match match in matches) {
        // Check if this match overlaps with already processed positions
        bool hasOverlap = false;
        for (int i = match.start; i < match.end; i++) {
          if (processedPositions.contains(i)) {
            hasOverlap = true;
            break;
          }
        }
        
        if (!hasOverlap) {
          String foodItem = match.group(1)?.trim() ?? '';
          if (foodItem.isNotEmpty && foodItem.length > 2) {
            // Clean up the food item but preserve brand names
            foodItem = foodItem.replaceAll(RegExp(r'\b(?:a|an|some|the|with|and|or)\b', caseSensitive: false), '').trim();
            if (foodItem.isNotEmpty) {
              foodItems.add(foodItem);
              // Mark these positions as processed
              for (int i = match.start; i < match.end; i++) {
                processedPositions.add(i);
              }
            }
          }
        }
      }
    }
    
    // If no patterns matched, try to extract common food words and brands
    if (foodItems.isEmpty) {
      final commonFoods = [
        'apple', 'banana', 'orange', 'chicken', 'rice', 'pasta', 'bread', 'milk', 'yogurt',
        'eggs', 'bacon', 'salad', 'soup', 'pizza', 'burger', 'sandwich', 'steak', 'fish',
        'salmon', 'tuna', 'beef', 'pork', 'turkey', 'cheese', 'butter', 'oil', 'nuts',
        'almonds', 'peanuts', 'walnuts', 'avocado', 'tomato', 'lettuce', 'carrots',
        'broccoli', 'spinach', 'kale', 'potato', 'sweet potato', 'quinoa', 'oatmeal',
        'cereal', 'granola', 'protein shake', 'smoothie', 'juice', 'coffee', 'tea',
        'water', 'soda', 'beer', 'wine', 'chocolate', 'candy', 'cookie', 'cake',
        'ice cream', 'yogurt', 'cottage cheese', 'peanut butter', 'jelly', 'jam',
        // Brand names
        'chobani', 'fage', 'dannon', 'siggi', 'optimum nutrition', 'myprotein', 'dymatize',
        'cheerios', 'frosted flakes', 'special k', 'clif', 'quest', 'rxbar', 'ezekiel',
        'silver hills', 'dave killer'
      ];
      final words = message.toLowerCase().split(RegExp(r'\s+'));
      for (String word in words) {
        if (commonFoods.contains(word) && word.length > 2) {
          foodItems.add(word);
        }
      }
    }
    return foodItems;
  }

  Future<FoodEntry?> _searchFoodNutrition(String foodItem) async {
    try {
      // Use USDA Food Database API for real nutrition data
      final String apiKey = 'DEMO_KEY'; // Replace with your USDA API key
      final String baseUrl = 'https://api.nal.usda.gov/fdc/v1';
      
      // Search for the food item
      final searchResponse = await http.get(
        Uri.parse('$baseUrl/foods/search?api_key=$apiKey&query=${Uri.encodeComponent(foodItem)}&pageSize=5'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (searchResponse.statusCode == 200) {
        final Map<String, dynamic> searchData = jsonDecode(searchResponse.body);
        final List<dynamic> foods = searchData['foods'] ?? [];
        
        if (foods.isNotEmpty) {
          // Get the first (most relevant) result
          final Map<String, dynamic> food = foods[0];
          final int fdcId = food['fdcId'];
          
          // Get detailed nutrition information
          final detailResponse = await http.get(
            Uri.parse('$baseUrl/food/$fdcId?api_key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
          );
          
          if (detailResponse.statusCode == 200) {
            final Map<String, dynamic> detailData = jsonDecode(detailResponse.body);
            final List<dynamic> nutrients = detailData['foodNutrients'] ?? [];
            
            // Extract nutrition values
            double calories = 0.0;
            double protein = 0.0;
            double carbs = 0.0;
            double fat = 0.0;
            
            for (final nutrient in nutrients) {
              final String name = nutrient['nutrientName']?.toString().toLowerCase() ?? '';
              final double value = (nutrient['value'] ?? 0.0).toDouble();
              
              if (name.contains('energy') || name.contains('calories')) {
                calories = value;
              } else if (name.contains('protein')) {
                protein = value;
              } else if (name.contains('carbohydrate') || name.contains('total carbohydrate')) {
                carbs = value;
              } else if (name.contains('total lipid') || name.contains('fat')) {
                fat = value;
              }
            }
            
            // Determine meal type based on food name
            MealType mealType = _determineMealType(foodItem);
            
            return FoodEntry(
              foodItem,
              calories.round(),
              protein: protein,
              carbs: carbs,
              fat: fat,
              mealType: mealType,
            );
          }
        }
      }
      
      // Fallback to local database if API fails
      return _getFallbackNutrition(foodItem);
      
    } catch (e) {
      print('Error searching USDA API: $e');
      // Fallback to local database
      return _getFallbackNutrition(foodItem);
    }
  }
  
  FoodEntry _getFallbackNutrition(String foodItem) {
    // Local fallback database for common foods
    final Map<String, Map<String, dynamic>> fallbackDB = {
      'eggs': {'calories': 155, 'protein': 13.0, 'carbs': 1.1, 'fat': 11.0},
      'egg': {'calories': 155, 'protein': 13.0, 'carbs': 1.1, 'fat': 11.0},
      'chicken': {'calories': 165, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6},
      'rice': {'calories': 111, 'protein': 2.6, 'carbs': 23.0, 'fat': 0.9},
      'apple': {'calories': 52, 'protein': 0.3, 'carbs': 14.0, 'fat': 0.2},
      'banana': {'calories': 89, 'protein': 1.1, 'carbs': 23.0, 'fat': 0.3},
      'yogurt': {'calories': 59, 'protein': 10.0, 'carbs': 3.6, 'fat': 0.4},
      'milk': {'calories': 42, 'protein': 3.4, 'carbs': 5.0, 'fat': 1.0},
      'bread': {'calories': 265, 'protein': 9.0, 'carbs': 49.0, 'fat': 3.2},
      'salad': {'calories': 20, 'protein': 2.0, 'carbs': 4.0, 'fat': 0.2},
    };
    
    final foodLower = foodItem.toLowerCase().trim();
    final nutrition = fallbackDB[foodLower];
    
    if (nutrition != null) {
      return FoodEntry(
        foodItem,
        nutrition['calories'],
        protein: nutrition['protein'],
        carbs: nutrition['carbs'],
        fat: nutrition['fat'],
        mealType: _determineMealType(foodItem),
      );
    }
    
    // Generic fallback
    return FoodEntry(
      foodItem,
      100,
      protein: 5.0,
      carbs: 15.0,
      fat: 2.0,
      mealType: _determineMealType(foodItem),
    );
  }
  
  MealType _determineMealType(String foodItem) {
    final foodLower = foodItem.toLowerCase();
    if (foodLower.contains('breakfast') || foodLower.contains('cereal') || 
        foodLower.contains('yogurt') || foodLower.contains('eggs') || 
        foodLower.contains('toast') || foodLower.contains('pancake')) {
      return MealType.breakfast;
    } else if (foodLower.contains('lunch') || foodLower.contains('sandwich') || 
               foodLower.contains('salad') || foodLower.contains('soup')) {
      return MealType.lunch;
    } else if (foodLower.contains('dinner') || foodLower.contains('steak') || 
               foodLower.contains('pasta') || foodLower.contains('rice')) {
      return MealType.dinner;
    } else {
      return MealType.snack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chatSessions.isNotEmpty ? _chatSessions[_currentSessionIndex].title : 'AI Trainer'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _showSessionList,
            tooltip: 'Sessions',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewSession,
            tooltip: 'New chat',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearChat,
            tooltip: 'Clear current chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI trainer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _messageController.clear();
    _saveChatSessions();
    _scrollToBottom();
    await _detectAndAddFood(message);
    try {
      final response = await _getAiResponse(message);
      String finalResponse = response;
      if (_aiActions.isNotEmpty) {
        finalResponse += '\n\n✅ ACTIONS PERFORMED:\n${_aiActions.join('\n')}';
        _aiActions.clear();
      }
      setState(() {
        _messages.add(ChatMessage(
          text: finalResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _saveChatSessions();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I'm having trouble connecting right now. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  // ... Gemini API and other helper methods go here ...
}

extension ListTakeLast<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - (n < length ? n : length));
}
