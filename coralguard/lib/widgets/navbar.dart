import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      decoration: const BoxDecoration(
        color: Color(0xFF1E51A4), // Deep blue matching your design
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.waves, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          const Text(
            "CoralGuard",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _navItem("Home"),
          _navItem("About"),
          _navItem("Support"),
        ],
      ),
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: TextButton(
        onPressed: () {},
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}