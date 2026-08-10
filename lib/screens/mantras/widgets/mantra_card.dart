import 'package:flutter/material.dart';

import '../../../models/mantra_model.dart';
import 'audio_player_widget.dart';

class MantraCard extends StatefulWidget {
  final Mantra mantra;
  final bool isRecited;
  final VoidCallback onMarkRecited;

  const MantraCard({
    super.key,
    required this.mantra,
    required this.isRecited,
    required this.onMarkRecited,
  });

  @override
  State<MantraCard> createState() => _MantraCardState();
}

class _MantraCardState extends State<MantraCard> {
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isRecited
          ? const Color(0xFFF0F8F0)
          : const Color(0xFFFFFAF5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mantra.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.mantra.category),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.mantra.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isRecited)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.mantra.text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF2C1810),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            if (widget.mantra.audioUrl != null) ...[
              const SizedBox(height: 12),
              AudioPlayerWidget(audioUrl: widget.mantra.audioUrl!),
            ],
            if (widget.mantra.meaning != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _showMeaning = !_showMeaning),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E6D2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: Color(0xFF8B6F47),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Meaning',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B6F47),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _showMeaning
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                            color: Color(0xFF8B6F47),
                          ),
                        ],
                      ),
                      if (_showMeaning) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.mantra.meaning!,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: widget.isRecited ? null : widget.onMarkRecited,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.isRecited
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF5E6),
                  foregroundColor: widget.isRecited
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFC17A47),
                ),
                child: Text(
                  widget.isRecited ? 'Recited Today ✨' : 'Mark as Recited',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.isRecited
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFC17A47),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
