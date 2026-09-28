import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/ico_chip.dart';
import 'favorites_store.dart';
import 'food_card.dart';
import 'food_data.dart';

/// Kumpulan menu favorit — grid seperti katalog, diakses dari Profil
/// atau tombol hati di AppBar katalog.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final favIds = ref.watch(favoritesProvider);
    final items = [
      for (final f in [...kFoods, ...kDrinks])
        if (favIds.contains(f.id)) f,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Favorit')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/catalog'),
            child: Text(tr(context, 'Katalog')),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const IcoChip(icon: 'i-heart', tone: IcoTone.violet, size: 56),
                    const SizedBox(height: 12),
                    Text(tr(context, 'Belum ada favorit'),
                        style: AppText.display(20.8,
                            color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 6),
                    Text(
                      tr(context, 'Ketuk hati di menu untuk simpan di sini.'),
                      textAlign: TextAlign.center,
                      style: AppText.body(14.08, color: muted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/catalog'),
                      child: Text(tr(context, 'Buka katalog')),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: 0.88,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) => FoodCard(item: items[i]),
            ),
    );
  }
}
