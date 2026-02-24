import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();

  // Background Image URLs (You can replace these with your own local assets later)
  final String lightCoralImg = "https://images.unsplash.com/photo-1583212292454-1fe6229603b7?q=80&w=2000";
  final String darkCoralImg = "https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=2000";

  void _handleAnalyze() async {
    setState(() {
      _isAnalyzing = true;
      _showResults = false;
    });

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showResults = true;
      });

      // Smooth scroll to results
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutQuart,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Stack to layer the backgrounds behind the content
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND LAYER
          _buildAnimatedBackground(),

          // 2. CONTENT LAYER
          Column(
            children: [
              const Navbar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 950),
                      child: Column(
                        children: [
                          // Input Section
                          InputSection(onAnalyze: _handleAnalyze),

                          const SizedBox(height: 50),

                          if (_isAnalyzing) _buildLoadingIndicator(),

                          // Results Section (Appears after analysis)
                          if (_showResults) const ResultsSection(),
                          
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
          color: _showResults ? const Color(0xFF021024) : const Color(0xFFE3F2FD),
          image: DecorationImage(
            image: NetworkImage(_showResults ? darkCoralImg : lightCoralImg),
            fit: BoxFit.cover,
            // Low opacity and color filter ensures it's not "messy"
            colorFilter: ColorFilter.mode(
              _showResults 
                ? Colors.black.withOpacity(0.5) 
                : Colors.white.withOpacity(0.4), 
              BlendMode.dstATop
            ),
          ),
        ),
        child: Container(
          // This gradient makes the image "glow" only in the center
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                _showResults ? const Color(0xFF021024) : const Color(0xFFE3F2FD),
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
      child: Column(
        children: const [
          CircularProgressIndicator(strokeWidth: 6),
          SizedBox(height: 25),
          Text("AI DIGITAL TWIN SIMULATION", 
               style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 8),
          Text("Analyzing Coral Pigmentation...", 
               style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}