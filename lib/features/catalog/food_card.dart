import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import 'favorites_store.dart';
import 'food_data.dart';

/// Kartu menu di grid katalog & favorit — frame 09/10.
/// Badge hati kecil di pojok foto bila menu difavoritkan.
class FoodCard extends ConsumerWidget {
  const FoodCard({super.key, required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final fav = ref.watch(favoritesProvider).contains(item.id);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF1E1B2E))
                .withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/food/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.fastfood),
                    ),
                    if (fav)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.dangerDark
                                : AppColors.dangerLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, item.name),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13.76),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.dangerSoftDark
                                : AppColors.dangerSoftLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${item.kcal} kkal',
                            style: TextStyle(
                              fontSize: 11.6,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.dangerDark
                                  : AppColors.dangerLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tr(context, item.portion),
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
