// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/analysis_results.dart';
import 'recommendations_card.dart';

class ResultsSection extends StatelessWidget {
  final AnalysisResults results;

  const ResultsSection({super.key, required this.results});

  Color _riskColor(int score) {
    if (score >= 70) return Colors.red;
    if (score >= 40) return Colors.orange;
    return Colors.green;
  }

  Color _levelColor(String level) {
    switch (level.toUpperCase()) {
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
    final delta14 = (results.healthDay14 - results.healthNow); // negative = decline
    final deltaText = delta14 >= 0
        ? "+${delta14.toStringAsFixed(1)}"
        : delta14.toStringAsFixed(1);

    final level = results.riskLevel.isNotEmpty ? results.riskLevel : "UNKNOWN";

    return Column(
      children: [
        // ====== MAIN RESULTS CARD ======
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Coral Reef Analysis Results",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E51A4),
                  ),
                ),
                const SizedBox(height: 16),

                // Risk score + risk level badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Bleaching Risk Score: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "${results.riskScore}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _riskColor(results.riskScore),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _levelColor(level).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _levelColor(level).withOpacity(0.5)),
                      ),
                      child: Text(
                        level.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _levelColor(level),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Stress + health now/day14
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _metricChip(
                      label: "Stress",
                      value: results.stress.toStringAsFixed(3),
                      color: Colors.blueGrey,
                    ),
                    _metricChip(
                      label: "Health Now",
                      value: results.healthNow.toStringAsFixed(1),
                      color: Colors.blueGrey,
                    ),
                    _metricChip(
                      label: "Day 14",
                      value: results.healthDay14.toStringAsFixed(1),
                      color: Colors.blueGrey,
                    ),
                    _metricChip(
                      label: "Δ(14d)",
                      value: deltaText,
                      color: delta14 < 0 ? Colors.red : Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Forecast quick view (chips)
                const Text(
                  "14-Day Health Forecast (0–100):",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    results.forecast.length,
                    (i) => Chip(
                      label: Text("D$i: ${results.forecast[i].toStringAsFixed(1)}"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ====== RECOMMENDATIONS ======
        // Updated: pass the full results so RecommendationsCard can show summary + why + priority
        RecommendationsCard(results: results),
      ],
    );
  }

  Widget _metricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}