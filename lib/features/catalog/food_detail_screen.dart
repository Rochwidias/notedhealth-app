import 'package:flutter/material.dart';

import 'food_data.dart';

/// Detail menu — frame 11. Info + tombol "saya makan ini" (snackbar dulu).
class FoodDetailScreen extends StatelessWidget {
  final String id;
  const FoodDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final item = findFood(id);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Menu tidak ditemukan.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(item.asset, height: 220, width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(height: 120)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(item.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              Chip(label: Text('${item.kcal} kkal')),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.desc),
          const SizedBox(height: 14),
          const Text('Bahan utama', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ...item.ingredients.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(b),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('💡 ${item.tip}'),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dicatat! Pelacakan kalori penuh menyusul.')),
            ),
            child: const Text('Tandai: saya makan ini'),
          ),
        ],
      ),
    );
  }
}
