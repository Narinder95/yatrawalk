import 'package:flutter/material.dart';

import '../../../models/sankalp_model.dart';

class SankalpListTile extends StatelessWidget {
  final Sankalp sankalp;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const SankalpListTile({
    super.key,
    required this.sankalp,
    required this.onToggleComplete,
    required this.onToggleActive,
    required this.onDelete,
  });

  Color get _statusColor {
    if (sankalp.isComplete) {
      return Colors.green;
    } else if (sankalp.isActive) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String get _statusLabel {
    if (sankalp.isComplete) {
      return 'Completed';
    } else if (sankalp.isActive) {
      return 'In Progress';
    } else {
      return 'Paused';
    }
  }

  IconData get _statusIcon {
    if (sankalp.isComplete) {
      return Icons.check_circle;
    } else if (sankalp.isActive) {
      return Icons.local_fire_department;
    } else {
      return Icons.pause_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: _statusColor.withValues(alpha: 0.05),
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
                  sankalp.emoji ?? '🎯',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sankalp.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _statusIcon,
                            size: 14,
                            color: _statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: _statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(sankalp.createdDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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
              sankalp.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Toggle active/paused
                if (!sankalp.isComplete)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onToggleActive,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: sankalp.isActive
                            ? Colors.orange
                            : Colors.grey.shade500,
                        side: BorderSide(
                          color: sankalp.isActive
                              ? Colors.orange
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(
                        sankalp.isActive ? Icons.pause : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(
                        sankalp.isActive ? 'Pause' : 'Resume',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),

                if (!sankalp.isComplete) const SizedBox(width: 8),

                // Toggle complete
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onToggleComplete,
                    style: FilledButton.styleFrom(
                      backgroundColor: sankalp.isComplete
                          ? Colors.green.shade600
                          : Colors.green.shade100,
                      foregroundColor: sankalp.isComplete
                          ? Colors.white
                          : Colors.green.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      sankalp.isComplete
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 16,
                    ),
                    label: Text(
                      sankalp.isComplete ? 'Completed' : 'Mark Done',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Delete
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Sankalp?'),
                        content: const Text(
                          'This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
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

            // Completion date if completed
            if (sankalp.isComplete && sankalp.completedDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.celebration, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Completed on ${_formatDate(sankalp.completedDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
