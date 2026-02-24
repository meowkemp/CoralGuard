import 'package:flutter/material.dart';

class InputSection extends StatefulWidget {
  final VoidCallback onAnalyze; // This notifies the HomePage
  const InputSection({super.key, required this.onAnalyze});

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  double _currentTemp = 28.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload Coral Reef Image", 
                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E51A4))),
            const SizedBox(height: 20),
            
            // Image Placeholder
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1546026423-cc4642628d2b?q=80&w=1000'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text("Select Image"),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Divider(),
            ),
            
            Text("Set Water Temperature: ${_currentTemp.toStringAsFixed(1)}°C", 
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Slider(
              value: _currentTemp,
              min: 20, max: 35,
              activeColor: const Color(0xFF1E51A4),
              onChanged: (value) => setState(() => _currentTemp = value),
            ),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E51A4),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onAnalyze, // Trigger the scroll and analysis
                child: const Text("Analyze Reef Health"),
              ),
            )
          ],
        ),
      ),
    );
  }
}