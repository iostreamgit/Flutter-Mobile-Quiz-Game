import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  Map<String, dynamic> _scores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresString = prefs.getString('best_scores');
      setState(() {
        _scores = scoresString != null ? json.decode(scoresString) : {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading scores: $e')),
      );
    }
  }

  Future<void> _resetScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('best_scores');
      setState(() {
        _scores = {};
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting scores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.ranking),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: localizations.resetScores,
            onPressed: () {
              _showResetDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scores.isEmpty
              ? Center(child: Text(localizations.noScores))
              : ListView.builder(
                  itemCount: sortedScores.length,
                  itemBuilder: (context, index) {
                    final entry = sortedScores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(entry.key),
                        subtitle: Text(
                            '${localizations.bestScore}: ${entry.value}'),
                        trailing: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showResetDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.resetScores),
        content: Text(localizations.confirmReset),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              _resetScores();
              Navigator.pop(context);
            },
            child: Text(localizations.reset),
          ),
        ],
      ),
    );
  }
}