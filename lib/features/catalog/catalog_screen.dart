import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/svg_icon.dart';
import 'food_card.dart';
import 'food_data.dart';

/// Katalog menu sehat â€” frame 09/10.
/// Searchbar pill, chips filter, grid 2 kolom foto Pexels.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.initialTab = 0});

  /// 0 = makanan, 1 = minuman (dipakai deep-link /catalog?tab=1).
  final int initialTab;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late int _tab = widget.initialTab; // 0 = makanan, 1 = minuman
  String _query = '';
  String _filter = 'Semua';

  List<String> get _filters => _tab == 0
      ? const ['Semua', 'Sarapan', 'Makan malam', 'Cemilan']
      : const ['Semua', 'Dingin', 'Hangat', '< 50 kkal'];

  List<FoodItem> get _items {
    final base = _tab == 0 ? kFoods : kDrinks;
    return base.where((f) {
      final okQuery =
          _query.isEmpty || f.name.toLowerCase().contains(_query.toLowerCase());
      final okFilter = _filter == 'Semua' || f.tags.contains(_filter);
      return okQuery && okFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0
            ? tr(context, 'Makanan Sehat')
            : tr(context, 'Minuman Sehat')),
        leading: IconButton(
          icon: const SvgIcon('i-back'),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: tr(context, 'Favorit'),
            icon: const SvgIcon('i-heart'),
            onPressed: () => context.push('/favorites'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmen Makanan / Minuman (gaya .seg mockup)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _SegBtn(
                    label: tr(context, 'Makanan'),
                    on: _tab == 0,
                    onTap: () => setState(() {
                      _tab = 0;
                      _filter = 'Semua';
                    }),
                  ),
                  _SegBtn(
                    label: tr(context, 'Minuman'),
                    on: _tab == 1,
                    onTap: () => setState(() {
                      _tab = 1;
                      _filter = 'Semua';
                    }),
                  ),
                ],
              ),
            ),
          ),
          // Searchbar pill (frame 09/10)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: line, width: 2),
              ),
              child: Row(
                children: [
                  SvgIcon('i-search', size: 18, color: muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      cursorColor: theme.colorScheme.primary,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: _tab == 0
                            ? tr(context, 'Cari menuâ€¦')
                            : tr(context, 'Cari minumanâ€¦'),
                        hintStyle: TextStyle(color: muted, fontSize: 14.4),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 14.4),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chips filter
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final f = _filters[i];
                final on = f == _filter;
                return Container(
                  decoration: BoxDecoration(
                    color: on
                        ? (isDark
                            ? AppColors.primarySoftDark
                            : AppColors.primarySoftLight)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: on ? theme.colorScheme.primary : line,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => _filter = f),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        child: Text(
                          tr(context, f),
                          style: TextStyle(
                            fontSize: 12.48,
                            fontWeight: FontWeight.w800,
                            color: on
                                ? theme.colorScheme.primary
                                : muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text(tr(context, 'Tidak ada menu cocok.'),
                        style: TextStyle(color: muted)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 13,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) => FoodCard(item: _items[i]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              tr(context, 'Foto: Pexels â€” bebas lisensi komersial'),
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol dalam segmen (.seg mockup): aktif = surface + primaryInk.
class _SegBtn extends StatelessWidget {
  const _SegBtn({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryInk = isDark ? AppColors.primaryInkDark : AppColors.primaryInkLight;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: on ? (isDark ? AppColors.darkSurface : AppColors.lightSurface) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on
                  ? [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF1E1B2E))
                            .withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
                color: on ? primaryInk : muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
