// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/analysis_results.dart';

class RecommendationsCard extends StatelessWidget {
  final AnalysisResults results;

  const RecommendationsCard({super.key, required this.results});

  Color _priorityColor(String p) {
    switch (p.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = results.aiSummary.trim();
    final recs = results.aiRecommendations;

    // If Gemini didn't return anything, fallback to old actions list
    final fallbackItems = results.actions.isNotEmpty
        ? results.actions
        : [
            "Monitor reef conditions regularly.",
            "Track water temperature trends closely.",
            "Reduce local disturbances where possible.",
          ];

    final hasGemini = summary.isNotEmpty || recs.isNotEmpty;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AI Reef Assessment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ===== Summary =====
            if (hasGemini && summary.isNotEmpty) ...[
              Text(
                summary,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],

            // ===== Recommendations (Gemini) =====
            if (recs.isNotEmpty) ...[
              ...recs.map((rec) {
                final priority = rec.priority.trim().isEmpty
                    ? 'INFO'
                    : rec.priority.trim().toUpperCase();
                final color = _priorityColor(priority);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Priority badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              rec.title.trim().isEmpty ? "Recommendation" : rec.title.trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: color.withOpacity(0.5)),
                            ),
                            child: Text(
                              priority,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Why
                      if (rec.why.trim().isNotEmpty)
                        Text(
                          rec.why.trim(),
                          style: const TextStyle(fontSize: 13),
                        ),
                    ],
                  ),
                );
              // ignore: unnecessary_to_list_in_spreads
              }).toList(),
            ] else ...[
              // ===== Fallback (no Gemini) =====
              const Text(
                "Recommended Actions:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...fallbackItems.map(
                (text) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("•  "),
                      Expanded(child: Text(text)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}