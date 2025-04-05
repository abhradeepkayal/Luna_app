import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CategoryTile({super.key, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white.withAlpha((0.1 * 255).toInt()),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFDF6EE), // creamy-white
              fontSize: 20,
              fontFamily: 'AtkinsonHyperlegible',
            ),
          ),
        ),
      ),
    );
  }
}
