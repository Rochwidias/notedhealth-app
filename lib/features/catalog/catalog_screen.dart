import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'food_data.dart';

/// Katalog menu sehat — frame 09/10. Grid statis + filter.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _tab = 0; // 0 = makanan, 1 = minuman

  @override
  Widget build(BuildContext context) {
    final items = _tab == 0 ? kFoods : kDrinks;
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Makanan Sehat' : 'Minuman Sehat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Makanan')),
                ButtonSegment(value: 1, label: Text('Minuman')),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) => _Card(item: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final FoodItem item;
  const _Card({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/food/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(item.asset, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.fastfood)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${item.kcal} kkal',
                    style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
