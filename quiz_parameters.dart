import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../l10n/app_localizations.dart';
import 'quiz_screen.dart';
import '../screens/settings_provider.dart';

class QuizParametersScreen extends ConsumerStatefulWidget {
  const QuizParametersScreen({super.key});

  @override
  ConsumerState<QuizParametersScreen> createState() => _QuizParametersScreenState();
}

class _QuizParametersScreenState extends ConsumerState<QuizParametersScreen> {
  List<String> _categories = [];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<int> _questionNumbers = [5, 10, 15, 20];
  
  // Removed unused timeLimits and selectedTimeLimit variables
  String? _selectedCategory;
  String? _selectedDifficulty;
  int _selectedQuestionNumber = 10;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = _difficulties[0];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    const url = 'https://opentdb.com/api_category.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<dynamic> categoryList = data['trivia_categories'];
      
      setState(() {
        _categories = categoryList.map((cat) => cat['name'] as String).toList();
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories[0];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.selectParameters),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.selectParameters),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.errorFetching),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCategories,
                child: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectParameters),
        actions: [
          Switch(
            value: settings.isDarkMode,
            onChanged: (value) {
              // Fixed: Using notifier to toggle dark mode
              ref.read(settingsProvider.notifier).toggleDarkMode(value);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: localizations.category,
                  border: const OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: localizations.difficulty,
                  border: const OutlineInputBorder(),
                ),
                value: _selectedDifficulty,
                items: _difficulties
                    .map((difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: localizations.numQuestions,
                  border: const OutlineInputBorder(),
                ),
                value: _selectedQuestionNumber,
                items: _questionNumbers
                    .map((number) => DropdownMenuItem(
                          value: number,
                          child: Text(number.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuestionNumber = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_selectedCategory != null && _selectedDifficulty != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          category: _selectedCategory!,
                          difficulty: _selectedDifficulty!,
                          numberOfQuestions: _selectedQuestionNumber,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(localizations.startQuiz),
              ),
            ],
          ),
        ),
      ),
    );
  }
}