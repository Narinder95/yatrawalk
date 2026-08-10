import 'package:flutter/material.dart';

import '../../../models/mantra_model.dart';

class MantraListTile extends StatelessWidget {
  final Mantra mantra;
  final bool isRecited;
  final VoidCallback onAddTap;
  final VoidCallback onShareTap;

  const MantraListTile({
    super.key,
    required this.mantra,
    required this.isRecited,
    required this.onAddTap,
    required this.onShareTap,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mantra':
        return const Color(0xFF7B68EE);
      case 'Pooja':
        return const Color(0xFFFF6B6B);
      case 'Affirmation':
        return const Color(0xFF4ECDC4);
      default:
        return const Color(0xFF999999);
    }
  }

  String _getEmojiForCategory(String category) {
    switch (category) {
      case 'Mantra':
        return '🙏';
      case 'Pooja':
        return '🔔';
      case 'Affirmation':
        return '✨';
      default:
        return '📿';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(mantra.category);
    final emoji = _getEmojiForCategory(mantra.category);

    return Container(
      decoration: BoxDecoration(
        color: isRecited ? const Color(0xFFF0F8F0) : const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecited ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon/Image container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mantra.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1810),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      mantra.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            if (!isRecited) ...[
              IconButton(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.deepOrange,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onShareTap,
                icon: const Icon(Icons.share_outlined),
                color: Colors.deepOrange,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
