import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/sankalp_model.dart';
import '../../services/sankalp_service.dart';
import 'widgets/sankalp_list_tile.dart';
import 'widgets/suggested_sankalp_card.dart';

class SankalpScreen extends StatefulWidget {
  const SankalpScreen({super.key});

  @override
  State<SankalpScreen> createState() => _SankalpScreenState();
}

class _SankalpScreenState extends State<SankalpScreen> {
  List<Sankalp> _userSankalps = [];
  List<Sankalp> _suggestedSankalps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSankalps();
  }

  Future<void> _loadSankalps() async {
    try {
      final userSankalps = await SankalpService.getUserSankalps();
      final suggestedSankalps = SankalpService.getSuggestedSankalps();

      final activeSankalps = userSankalps.where((s) => s.isActive).toList();
      print('Loaded ${userSankalps.length} sankalps (${activeSankalps.length} active)');
      for (var s in userSankalps) {
        print('  - ${s.title}: active=${s.isActive}, complete=${s.isComplete}');
      }

      if (!mounted) return;
      setState(() {
        _userSankalps = userSankalps;
        _suggestedSankalps = suggestedSankalps;
        _loading = false;
      });
    } catch (e) {
      print('Error loading sankalps: $e');
      if (!mounted) return;
      setState(() {
        _userSankalps = [];
        _suggestedSankalps = SankalpService.getSuggestedSankalps();
        _loading = false;
      });
    }
  }

  Future<void> _saveSankalp(Sankalp sankalp) async {
    try {
      print('Saving sankalp: ${sankalp.title}');
      await SankalpService.saveSankalp(sankalp);
      print('Sankalp saved successfully');
      await _loadSankalps();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added: ${sankalp.title} ✨'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving sankalp: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving sankalp: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _createCustomSankalp() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedEmoji = '🎯';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Your Sankalp'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Walk with Faith',
                    label: Text('Sankalp Title'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Describe your intention or resolution...',
                    label: Text('Description'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '🎯',
                    '🙏',
                    '✨',
                    '💪',
                    '🚶',
                    '🧘',
                    '☮️',
                    '❤️',
                    '🌟',
                    '🔥',
                    '🌸',
                    '🦋'
                  ]
                      .map(
                        (emoji) => GestureDetector(
                          onTap: () {
                            setDialogState(() => selectedEmoji = emoji);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedEmoji == emoji
                                    ? Colors.deepOrange
                                    : Colors.grey.shade300,
                                width: selectedEmoji == emoji ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                {
                  'title': titleController.text,
                  'description': descController.text,
                  'emoji': selectedEmoji,
                },
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == null ||
        result['title']?.trim().isEmpty == true ||
        result['description']?.trim().isEmpty == true) {
      return;
    }

    const uuid = Uuid();
    final newSankalp = Sankalp(
      id: uuid.v4(),
      title: result['title']!.trim(),
      description: result['description']!.trim(),
      isComplete: false,
      createdDate: DateTime.now(),
      isActive: true,
      emoji: result['emoji'],
    );

    try {
      print('Creating sankalp: ${result['title']}');
      await SankalpService.saveSankalp(newSankalp);
      print('Sankalp created successfully');
      await _loadSankalps();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created: ${result['title']} ✨'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error creating sankalp: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating sankalp: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleComplete(String sankalpId, bool isComplete) async {
    try {
      await SankalpService.toggleSankalpComplete(sankalpId, isComplete);
      await _loadSankalps();
    } catch (e) {
      print('Error toggling sankalp complete: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(String sankalpId, bool isActive) async {
    try {
      await SankalpService.toggleSankalpActive(sankalpId, isActive);
      await _loadSankalps();
    } catch (e) {
      print('Error toggling sankalp active: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteSankalp(String sankalpId) async {
    try {
      await SankalpService.deleteSankalp(sankalpId);
      await _loadSankalps();
    } catch (e) {
      print('Error deleting sankalp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sankalp deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeSankalps = _userSankalps.where((s) => s.isActive).toList();
    final completedSankalps = _userSankalps.where((s) => s.isComplete).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSankalps,
          child: ListView(
            key: ValueKey(_userSankalps.length),
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              const Text(
                '🎯 Sankalp',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set your intentions and track your progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '🔥',
                      value: activeSankalps.length.toString(),
                      label: 'Active',
                      bgColor: Colors.orange.shade50,
                      borderColor: Colors.orange.shade200,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '✅',
                      value: completedSankalps.length.toString(),
                      label: 'Completed',
                      bgColor: Colors.green.shade50,
                      borderColor: Colors.green.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // User's Sankalps (MOVED TO TOP)
              if (_userSankalps.isNotEmpty) ...[
                Text(
                  '✨ Your Sankalps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                ..._userSankalps
                    .map((sankalp) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SankalpListTile(
                        sankalp: sankalp,
                        onToggleComplete: () => _toggleComplete(
                          sankalp.id,
                          !sankalp.isComplete,
                        ),
                        onToggleActive: () =>
                            _toggleActive(sankalp.id, !sankalp.isActive),
                        onDelete: () => _deleteSankalp(sankalp.id),
                      ),
                    )),
                const SizedBox(height: 32),
              ],

              // Create button
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _createCustomSankalp,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Your Sankalp'),
                ),
              ),
              const SizedBox(height: 24),

              // Suggested Sankalps
              Text(
                '💡 Suggested Sankalps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              if (_suggestedSankalps.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No suggestions available'),
                )
              else
                ..._suggestedSankalps
                    .map((sankalp) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SuggestedSankalpCard(
                        sankalp: sankalp,
                        onAdd: (createdSankalp) => _saveSankalp(createdSankalp),
                      ),
                    )),

              // Empty state message (shown when no user sankalps exist)
              if (_userSankalps.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '✨',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No sankalps yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create one or choose from suggestions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color bgColor;
  final Color borderColor;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
