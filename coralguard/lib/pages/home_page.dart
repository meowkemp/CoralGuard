// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/analysis_results.dart';
import '../widgets/navbar.dart';
import '../widgets/input_section.dart';
import '../widgets/results_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAnalyzing = false;
  bool _showResults = false;
  String? _error;

  AnalysisResults? _results;

  final ScrollController _scrollController = ScrollController();

  final String lightCoralImg =
      "https://images.unsplash.com/photo-1583212292454-1fe6229603b7?q=80&w=2000";
  final String darkCoralImg =
      "https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=2000";

  final String backendBaseUrl = "http://127.0.0.1:8000";

  Future<Map<String, dynamic>> _callAnalyze({
    required Uint8List imageBytes,
    required double tempC,
  }) async {
    final uri = Uri.parse("$backendBaseUrl/analyze");

    final request = http.MultipartRequest("POST", uri);
    request.fields["temp_c"] = tempC.toStringAsFixed(1);
    request.files.add(
      http.MultipartFile.fromBytes("file", imageBytes, filename: "reef.jpg"),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception("Backend error ${streamed.statusCode}: $body");
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<void> _handleAnalyze(double tempC, Uint8List imageBytes) async {
    setState(() {
      _isAnalyzing = true;
      _showResults = false;
      _error = null;
    });

    try {
      final json = await _callAnalyze(imageBytes: imageBytes, tempC: tempC);
      final results = AnalysisResults.fromBackend(json);

      if (!mounted) return;
      setState(() {
        _results = results;
        _isAnalyzing = false;
        _showResults = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutQuart,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _showResults = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Column(
            children: [
              const Navbar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 950),
                      child: Column(
                        children: [
                          InputSection(onAnalyze: _handleAnalyze),

                          const SizedBox(height: 50),

                          if (_isAnalyzing) _buildLoadingIndicator(),

                          if (_error != null)
                            _ErrorBox(text: _error!),

                          if (_showResults && _results != null)
                            ResultsSection(results: _results!),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1500),
      child: Container(
        key: ValueKey<bool>(_showResults),
        decoration: BoxDecoration(
          color:
              _showResults ? const Color(0xFF021024) : const Color(0xFFE3F2FD),
          image: DecorationImage(
            image: NetworkImage(_showResults ? darkCoralImg : lightCoralImg),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _showResults
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.4),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                _showResults
                    ? const Color(0xFF021024)
                    : const Color(0xFFE3F2FD),
              ],
              stops: const [0.2, 0.9],
              radius: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(strokeWidth: 6),
          SizedBox(height: 25),
          Text("AI DIGITAL TWIN SIMULATION",
              style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          SizedBox(height: 8),
          Text("Analyzing Coral Pigmentation...", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(text, style: TextStyle(color: Colors.red.shade900)),
    );
  }
}