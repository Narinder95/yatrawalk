import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/sankalp_model.dart';

class SuggestedSankalpCard extends StatefulWidget {
  final Sankalp sankalp;
  final Function(Sankalp) onAdd;

  const SuggestedSankalpCard({
    super.key,
    required this.sankalp,
    required this.onAdd,
  });

  @override
  State<SuggestedSankalpCard> createState() => _SuggestedSankalpCardState();
}

class _SuggestedSankalpCardState extends State<SuggestedSankalpCard> {
  bool _isEditing = false;
  bool _isAdded = false;
  bool _isCompleted = false;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedEmoji;
  late Sankalp _createdSankalp;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.sankalp.title);
    _descController =
        TextEditingController(text: widget.sankalp.description);
    _selectedEmoji = widget.sankalp.emoji ?? '🎯';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    setState(() => _isEditing = true);
  }

  void _exitEditMode() {
    setState(() => _isEditing = false);
    _titleController.text = widget.sankalp.title;
    _descController.text = widget.sankalp.description;
    _selectedEmoji = widget.sankalp.emoji ?? '🎯';
  }

  void _confirmAdd() async {
    _createdSankalp = Sankalp(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      isComplete: false,
      createdDate: DateTime.now(),
      isActive: true,
      emoji: _selectedEmoji,
    );

    setState(() {
      _isEditing = false;
      _isAdded = true;
    });

    // Save to service via callback
    widget.onAdd(_createdSankalp);
  }

  void _resetCard() {
    setState(() {
      _isAdded = false;
      _isEditing = false;
      _isCompleted = false;
      _titleController.text = widget.sankalp.title;
      _descController.text = widget.sankalp.description;
      _selectedEmoji = widget.sankalp.emoji ?? '🎯';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdded) {
      return _buildAddedMode();
    }

    if (_isEditing) {
      return _buildEditMode();
    }

    return _buildViewMode();
  }

  Widget _buildViewMode() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepOrange.shade200,
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade50,
            Colors.amber.shade50,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.sankalp.emoji ?? '🎯',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sankalp.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Suggested',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.deepOrange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.sankalp.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _enterEditMode,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Sankalp',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddedMode() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCompleted ? Colors.green.shade400 : Colors.green.shade300,
          width: 2,
        ),
        color: _isCompleted ? Colors.green.shade100 : Colors.green.shade50,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with emoji and title
            Row(
              children: [
                Text(
                  _createdSankalp.emoji ?? '🎯',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _createdSankalp.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: _isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: _isCompleted
                              ? Colors.green.shade700
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _isCompleted
                                ? Icons.check_circle
                                : Icons.local_fire_department,
                            size: 14,
                            color:
                                _isCompleted ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isCompleted ? 'Completed' : 'In Progress',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _isCompleted ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              _createdSankalp.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            if (!_isCompleted)
              Row(
                children: [
                  // Pause button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sankalp paused'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.pause, size: 16),
                      label: const Text(
                        'Pause',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Mark Done button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() => _isCompleted = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sankalp marked as completed! 🎉'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text(
                        'Mark Done',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete button
                  IconButton(
                    onPressed: () {
                      _resetCard();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sankalp removed'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade400,
                    tooltip: 'Delete sankalp',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              )
            else
              // Completed state - show celebration and reset button
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🎉 Completed!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Undo button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isCompleted = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Marked as in progress'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.undo, size: 16),
                          label: const Text(
                            'Undo',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Delete button
                      IconButton(
                        onPressed: () {
                          _resetCard();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sankalp removed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade400,
                        tooltip: 'Delete sankalp',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade300,
          width: 2,
        ),
        color: Colors.green.shade50,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji picker
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
                        setState(() => _selectedEmoji = emoji);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedEmoji == emoji
                                ? Colors.green.shade600
                                : Colors.grey.shade300,
                            width: _selectedEmoji == emoji ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: _selectedEmoji == emoji
                              ? Colors.green.shade100
                              : Colors.white,
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
            const SizedBox(height: 16),

            // Title field
            TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Sankalp title',
                label: const Text('Title'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 12),

            // Description field
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your intention...',
                label: const Text('Description'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _exitEditMode,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _confirmAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Add to My Sankalps'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
