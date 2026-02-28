// lib/models/analysis_results.dart

class RecommendationItem {
  final String title;
  final String why;
  final String priority; // HIGH / MEDIUM / LOW (or empty)

  RecommendationItem({
    required this.title,
    required this.why,
    required this.priority,
  });

  factory RecommendationItem.fromJson(Map<dynamic, dynamic> json) {
    return RecommendationItem(
      title: (json['title'] ?? '').toString(),
      why: (json['why'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
    );
  }
}

class AnalysisResults {
  // Core UI fields
  final int riskScore; // 0..100 (stress * 100)
  final List<double> forecast; // length 15 (day0..14), each 0..100

  /// Backward-compatible list for older UI widgets (titles only).
  /// You can keep using this in existing widgets without breaking anything.
  final List<String> actions;

  // Extra fields for better UI (Gemini)
  final String aiSummary;
  final List<RecommendationItem> aiRecommendations;

  // Optional extra fields (nice for displaying later)
  final double stress; // 0..1
  final String riskLevel; // LOW/MEDIUM/HIGH/UNKNOWN
  final double healthNow; // 0..100
  final double healthDay14; // 0..100

  // Optional features (Vision/local)
  final Map<String, dynamic>? features; // vision_features or image_features

  AnalysisResults({
    required this.riskScore,
    required this.forecast,
    required this.actions,
    required this.aiSummary,
    required this.aiRecommendations,
    required this.stress,
    required this.riskLevel,
    required this.healthNow,
    required this.healthDay14,
    this.features,
  });

  factory AnalysisResults.fromBackend(Map<String, dynamic> json) {
    // --- core metrics (safe parsing) ---
    final stressVal = (json['stress'] as num?)?.toDouble() ?? 0.0;
    final riskScore = (stressVal * 100).round().clamp(0, 100);

    final riskLevel = (json['risk_level'] ?? 'UNKNOWN').toString();
    final healthNow = (json['health_now'] as num?)?.toDouble() ?? 0.0;
    final healthDay14 = (json['health_day14'] as num?)?.toDouble() ?? 0.0;

    // --- forecast ---
    final rawForecast = json['forecast_14d'];
    final forecastList = <double>[];

    if (rawForecast is List) {
      for (final e in rawForecast) {
        if (e is Map && e['health'] != null) {
          final v = (e['health'] as num).toDouble();
          forecastList.add(v);
        } else if (e is num) {
          // fallback: if backend ever returns just numbers
          forecastList.add(e.toDouble());
        }
      }
    }

    final forecast = _normalize15(forecastList);

    // --- AI analysis (Gemini) ---
    String aiSummary = '';
    final aiRecommendations = <RecommendationItem>[];

    final ai = json['ai_analysis'];
    if (ai is Map) {
      // summary
      final s = ai['summary'];
      if (s != null) aiSummary = s.toString();

      // recommendations
      final recs = ai['recommendations'];
      if (recs is List) {
        for (final r in recs) {
          if (r is Map) {
            aiRecommendations.add(RecommendationItem.fromJson(r));
          }
        }
      }
    }

    // --- Backward-compatible actions list (titles only) ---
    final actions = <String>[];
    for (final r in aiRecommendations) {
      if (r.title.trim().isNotEmpty) actions.add(r.title.trim());
    }

    // Fallback: if no titles, use summary as a single “action”
    if (actions.isEmpty && aiSummary.trim().isNotEmpty) {
      actions.add(aiSummary.trim());
    }

    // Final fallback: demo-safe defaults
    final finalActions = actions.isNotEmpty
        ? actions
        : <String>[
            "Monitor reef conditions regularly.",
            "Track water temperature trends closely.",
            "Reduce local disturbances where possible.",
          ];

    // --- features (supports both keys) ---
    Map<String, dynamic>? feats;

    final vf = json['vision_features'];
    final imf = json['image_features'];

    if (vf is Map<String, dynamic>) {
      feats = vf;
    } else if (imf is Map<String, dynamic>) {
      feats = imf;
    } else if (vf is Map) {
      feats = Map<String, dynamic>.from(vf);
    } else if (imf is Map) {
      feats = Map<String, dynamic>.from(imf);
    }

    return AnalysisResults(
      riskScore: riskScore,
      forecast: forecast,
      actions: finalActions,
      aiSummary: aiSummary,
      aiRecommendations: aiRecommendations,
      stress: stressVal,
      riskLevel: riskLevel,
      healthNow: healthNow,
      healthDay14: healthDay14,
      features: feats,
    );
  }

  static List<double> _normalize15(List<double> input) {
    if (input.length >= 15) return input.take(15).toList();

    final out = List<double>.from(input);
    while (out.length < 15) {
      out.add(out.isEmpty ? 0.0 : out.last);
    }
    return out;
  }
}