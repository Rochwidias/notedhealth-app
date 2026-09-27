import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.icon});

  final String title;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'Layar $title — menyusul',
              style: TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
