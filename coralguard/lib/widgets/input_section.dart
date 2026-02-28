import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputSection extends StatefulWidget {
  final Future<void> Function(double tempC, Uint8List imageBytes) onAnalyze;

  const InputSection({super.key, required this.onAnalyze});

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  double _currentTemp = 28.0;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;

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
            const Text(
              "Upload Coral Reef Image",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E51A4),
              ),
            ),
            const SizedBox(height: 20),

            // Preview
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: _selectedImageBytes == null
                    ? const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1546026423-cc4642628d2b?q=80&w=1000',
                        ),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: MemoryImage(_selectedImageBytes!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? file =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (file == null) return;

                    final bytes = await file.readAsBytes();
                    setState(() => _selectedImageBytes = bytes);
                  },
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text("Select Image"),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedImageBytes = null),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Clear"),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Divider(),
            ),

            Text(
              "Set Water Temperature: ${_currentTemp.toStringAsFixed(1)}°C",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _currentTemp,
              min: 20,
              max: 35,
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
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_selectedImageBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select an image first."),
                      ),
                    );
                    return;
                  }
                  await widget.onAnalyze(_currentTemp, _selectedImageBytes!);
                },
                child: const Text("Analyze Reef Health"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}