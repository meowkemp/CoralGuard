import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Coral Reef Analysis Results", 
             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E51A4))),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Wrap( // Wrap works better for responsive results
              alignment: WrapAlignment.center,
              spacing: 40,
              runSpacing: 40,
              children: [
                _buildRiskGauge(78),
                _buildForecastChart(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildRecommendations(),
      ],
    );
  }

  Widget _buildRiskGauge(double score) {
    return Column(
      children: [
        const Text("Bleaching Risk Score", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(
          height: 200,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0, maximum: 100, showLabels: false, showTicks: false,
                axisLineStyle: const AxisLineStyle(thickness: 0.2, cornerStyle: CornerStyle.bothCurve, thicknessUnit: GaugeSizeUnit.factor),
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: 33, color: Colors.green, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor),
                  GaugeRange(startValue: 33, endValue: 66, color: Colors.orange, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor),
                  GaugeRange(startValue: 66, endValue: 100, color: Colors.red, startWidth: 0.2, endWidth: 0.2, sizeUnit: GaugeSizeUnit.factor),
                ],
                pointers: <GaugePointer>[NeedlePointer(value: score, needleLength: 0.6)],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(widget: Text('$score', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), angle: 90, positionFactor: 0.5)
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastChart() {
    return Column(
      children: [
        const Text("14-Day Health Forecast", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 3), FlSpot(2, 2), FlSpot(5, 5), FlSpot(8, 3), FlSpot(11, 4), FlSpot(14, 2)],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recommended Actions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _bulletPoint("Reduce water temperature if possible."),
            _bulletPoint("Limit human activity around the reef."),
            _bulletPoint("Monitor the reef closely for further changes."),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E51A4), foregroundColor: Colors.white),
                onPressed: () {}, 
                icon: const Icon(Icons.save), 
                label: const Text("Save to Firestore")
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}