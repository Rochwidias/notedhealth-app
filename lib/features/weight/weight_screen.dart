import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/weight_entry.dart';
import '../../widgets/ico_chip.dart';
import '../../widgets/svg_icon.dart';
import '../profile/prefs_store.dart';
import 'weight_repository.dart';
import 'weight_sheet.dart';

/// Layar Berat — frame 07 mockup: stat, strip selisih, BMI, grafik, riwayat.
class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key});

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;
    final history = ref.watch(weightHistoryProvider);
    final latest = ref.watch(latestWeightProvider);
    final prefs = ref.watch(prefsProvider);
    final bmi = prefs.bmi(latest?.valueKg);

    final cutoff = DateTime.now().subtract(Duration(days: _days - 1));
    final points = history
        .where((e) => e.date.compareTo(dateKeyOf(cutoff)) >= 0)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Berat Badan')),
      body: SafeArea(
        top: false,
        child: latest == null
            ? _EmptyWeightCard(onAdd: () => showWeightSheet(context))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stat grid: Sekarang + Target.
                    Row(
                      children: [
                        Expanded(
                          child: _WStat(
                            icon: 'i-scale',
                            tone: IcoTone.violet,
                            label: 'Sekarang',
                            big: '${fmtKg(latest.valueKg)} kg',
                            sub: history.length > 1
                                ? _sinceCaption(
                                    latest.valueKg,
                                    history[1].valueKg,
                                    success,
                                    danger)
                                : 'catatan pertamamu',
                            subColor: history.length > 1
                                ? latest.valueKg <= history[1].valueKg
                                    ? success
                                    : danger
                                : muted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _WStat(
                            icon: 'i-target',
                            tone: IcoTone.amber,
                            label: 'Target',
                            big: prefs.targetKg == null
                                ? '—'
                                : '${fmtKg(prefs.targetKg!)} kg',
                            sub: prefs.targetKg == null
                                ? 'atur di Profil'
                                : _etaCaption(history, latest, prefs.targetKg!),
                            subColor: muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Strip selisih ke target.
                    if (prefs.targetKg != null)
                      _SelisihStrip(
                        now: latest.valueKg,
                        target: prefs.targetKg!,
                      ),
                    const SizedBox(height: 12),
                    if (bmi != null)
                      _BmiCard(
                        bmi: bmi,
                        weightKg: latest.valueKg,
                        heightCm: prefs.heightCm!,
                      )
                    else
                      OutlinedButton(
                        onPressed: () => context.go('/profile'),
                        child: const Text(
                            'Isi tinggi badan untuk lihat BMI'),
                      ),
                    const SizedBox(height: 14),
                    _SectionHeader(title: 'Grafik'),
                    const SizedBox(height: 8),
                    _Seg(
                      options: const ['7 hari', '30 hari'],
                      index: _days == 7 ? 0 : 1,
                      onPick: (i) =>
                          setState(() => _days = i == 0 ? 7 : 30),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 210,
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: theme.colorScheme.outline),
                      ),
                      child: points.length < 2
                          ? Center(
                              child: Text(
                                'Butuh ≥2 catatan untuk grafik.',
                                style:
                                    AppText.body(12.5, color: muted),
                              ),
                            )
                          : LineChart(_chartData(points, theme)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _trendCaption(points),
                      textAlign: TextAlign.center,
                      style: AppText.body(11.5, color: muted),
                    ),
                    const SizedBox(height: 14),
                    _SectionHeader(title: 'Riwayat', link: 'Semua'),
                    const SizedBox(height: 8),
                    // Satu kartu berisi semua baris riwayat.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < history.length && i < 8;
                              i++) ...[
                            if (i > 0)
                              Divider(
                                color: theme.colorScheme.outline,
                                height: 1,
                              ),
                            _HistoryRow(
                              entry: history[i],
                              prev: i + 1 < history.length
                                  ? history[i + 1]
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showWeightSheet(context),
        child: SvgIcon('i-plus', size: 24, color: Colors.white),
      ),
    );
  }

  LineChartData _chartData(List<WeightEntry> points, ThemeData theme) {
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].valueKg),
    ];
    var minY = spots.first.y;
    var maxY = spots.first.y;
    for (final s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }
    final pad =
        ((maxY - minY).abs() < 0.5) ? 1.0 : (maxY - minY) * 0.3;
    final primary = theme.colorScheme.primary;
    return LineChartData(
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY - pad,
      maxY: maxY + pad,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.outline.withValues(alpha: 0.6),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, _) => Text(
              fmtKg(v),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.round();
              if (i < 0 || i >= points.length) {
                return const SizedBox.shrink();
              }
              if (points.length > 8 && i % 5 != 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _shortDate(points[i].date),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: primary,
          barWidth: 3.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.35),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touched) => touched
              .map((s) => LineTooltipItem(
                    '${fmtKg(s.y)} kg\n${_fmtDate(points[s.x.round()].date)}',
                    const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

String _sinceCaption(
    double now, double before, Color success, Color danger) {
  final d = now - before;
  if (d.abs() < 0.05) return 'tanpa perubahan';
  final sign = d < 0 ? '▼' : '▲';
  return '$sign ${fmtKg(d.abs())} kg sejak kemarin';
}

String _etaCaption(
    List<WeightEntry> history, WeightEntry latest, double target) {
  if (latest.valueKg <= target) return 'target tercapai 🎉';
  if (history.length < 2) return 'butuh catatan rutin';
  final oldest = history.last;
  final days = DateTime.parse(latest.date)
      .difference(DateTime.parse(oldest.date))
      .inDays;
  if (days < 2) return 'butuh catatan rutin';
  final perDay =
      (latest.valueKg - oldest.valueKg) / days; // bisa negatif
  if (perDay >= -0.001) return 'stabil dulu ya';
  final weeks = ((latest.valueKg - target) / (perDay * 7)).ceil();
  if (weeks <= 0) return 'segera sampai';
  return 'estimasi $weeks minggu lagi';
}

String _trendCaption(List<WeightEntry> points) {
  if (points.length < 2) return 'Catat rutin — grafik muncul otomatis.';
  final d = points.last.valueKg - points.first.valueKg;
  if (d.abs() < 0.05) return 'Beratmu stabil di periode ini.';
  return d < 0
      ? 'Turun ${fmtKg(d.abs())} kg di periode ini — konsisten ya!'
      : 'Naik ${fmtKg(d)} kg di periode ini — cek kebiasaanmu.';
}

String dateKeyOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _fmtDate(String ymd) {
  try {
    final d = DateTime.parse(ymd);
    return DateFormat('d MMM yyyy', 'id_ID').format(d);
  } catch (_) {
    return ymd;
  }
}

String _shortDate(String ymd) {
  try {
    final d = DateTime.parse(ymd);
    return DateFormat('d/M', 'id_ID').format(d);
  } catch (_) {
    return '';
  }
}

/// Kartu statistik mini ala mockup `.stat`.
class _WStat extends StatelessWidget {
  const _WStat({
    required this.icon,
    required this.tone,
    required this.label,
    required this.big,
    required this.sub,
    required this.subColor,
  });

  final String icon;
  final IcoTone tone;
  final String label;
  final String big;
  final String sub;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF1E1B2E).withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IcoChip(icon: icon, tone: tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12.16,
                        color: theme.colorScheme.onSurfaceVariant,
                        weight: FontWeight.w800,
                        height: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(big,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  AppText.display(27.2, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(12.16,
                  color: subColor, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Strip "SELISIH KE TARGET" ala mockup.
class _SelisihStrip extends StatelessWidget {
  const _SelisihStrip({required this.now, required this.target});

  final double now;
  final double target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final successSoft =
        isDark ? AppColors.successSoftDark : AppColors.successSoftLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;
    final dangerSoft =
        isDark ? AppColors.dangerSoftDark : AppColors.dangerSoftLight;
    final diff = now - target;
    final down = diff > 0; // masih perlu turun
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          IcoChip(icon: 'i-target', tone: IcoTone.violet),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SELISIH KE TARGET',
                    style: AppText.body(12.16,
                        color: theme.colorScheme.onPrimaryContainer,
                        weight: FontWeight.w800,
                        height: 1.2)),
                const SizedBox(height: 2),
                Text(
                  diff.abs() < 0.05
                      ? 'Tepat di target!'
                      : down
                          ? 'Kurang ${fmtKg(diff)} kg'
                          : 'Lewat ${fmtKg(-diff)} kg',
                  style: AppText.display(
                      20, color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: down ? successSoft : dangerSoft,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              down ? '▼ Turun' : '▲ Naik',
              style: AppText.body(11.84,
                  color: down ? success : danger,
                  weight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.link});

  final String title;
  final String? link;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: AppText.body(16.32,
                  color: theme.colorScheme.onSurface,
                  weight: FontWeight.w800)),
        ),
        if (link != null)
          Text(link!,
              style: AppText.body(13.12,
                  color: theme.colorScheme.primary,
                  weight: FontWeight.w800)),
      ],
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.options,
    required this.index,
    required this.onPick,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryInk =
        isDark ? AppColors.primaryInkDark : AppColors.primaryInkLight;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface2
            : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onPick(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == index
                        ? theme.colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: i == index
                        ? [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black
                                      .withValues(alpha: 0.35)
                                  : const Color(0xFF1E1B2E)
                                      .withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    options[i],
                    textAlign: TextAlign.center,
                    style: AppText.body(12.8,
                        color:
                            i == index ? primaryInk : muted(context),
                        weight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
}

class _BmiCard extends StatelessWidget {
  const _BmiCard({
    required this.bmi,
    required this.weightKg,
    required this.heightCm,
  });

  final double bmi;
  final double weightKg;
  final double heightCm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final successSoft =
        isDark ? AppColors.successSoftDark : AppColors.successSoftLight;
    // Posisi marker 15–35 → persen 0–100.
    final pos = ((bmi - 15) / 20).clamp(0.0, 1.0);
    final cat = bmi < 18.5
        ? 'Kurus'
        : bmi < 25
            ? 'Normal'
            : bmi < 30
                ? 'Berlebih'
                : 'Obesitas';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IcoChip(icon: 'i-height', tone: IcoTone.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMI — INDEKS MASSA TUBUH',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(11.2,
                            color: theme.colorScheme.onSurfaceVariant,
                            weight: FontWeight.w800,
                            height: 1.2)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                            bmi
                                .toStringAsFixed(1)
                                .replaceAll('.', ','),
                            style: AppText.display(32,
                                color:
                                    theme.colorScheme.onSurface)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: successSoft,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(cat,
                              style: AppText.body(11.84,
                                  color: success,
                                  weight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${fmtKg(weightKg)} kg',
                      style: AppText.body(11.5,
                          color:
                              theme.colorScheme.onSurfaceVariant)),
                  Text(
                    '÷ ${(heightCm / 100).toStringAsFixed(2).replaceAll('.', ',')} m²',
                    style: AppText.body(11.5,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BmiBar(pos: pos),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _legend('15', theme.colorScheme.onSurfaceVariant),
              _legend('18,5', const Color(0xFF4CC3FF)),
              _legend('25', success),
              _legend('30', const Color(0xFFC98A00)),
              _legend('35', theme.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kurus <18,5 · Normal 18,5–24,9 · Berlebih 25–29,9 · '
            'Obesitas ≥30 · tinggi dari Profil',
            style: AppText.body(10.5,
                color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _legend(String t, Color c) => Text(t,
      style: AppText.body(11, color: c, weight: FontWeight.w700));
}

class _BmiBar extends StatelessWidget {
  const _BmiBar({required this.pos});

  final double pos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    return SizedBox(
      height: 12,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CC3FF),
                    success,
                    AppColors.accent,
                    isDark
                        ? AppColors.dangerDark
                        : AppColors.dangerLight,
                  ],
                  stops: const [0.0, 0.175, 0.5, 0.75],
                ),
              ),
            ),
            Positioned(
              left: (box.maxWidth - 20) * pos,
              top: 0,
              bottom: 0,
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(
                      color: theme.colorScheme.onSurface, width: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, this.prev});

  final WeightEntry entry;
  final WeightEntry? prev;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diff = prev == null ? null : entry.valueKg - prev!.valueKg;
    final success =
        isDark ? AppColors.successDark : AppColors.successLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(_fmtDate(entry.date),
                style: AppText.body(14.08,
                    color: theme.colorScheme.onSurface,
                    weight: FontWeight.w700)),
          ),
          if (diff != null && diff.abs() >= 0.05)
            Text(
              diff < 0
                  ? '▼ ${fmtKg(-diff)}'
                  : '▲ ${fmtKg(diff)}',
              style: AppText.body(12.8,
                  color: diff < 0 ? success : danger,
                  weight: FontWeight.w800),
            ),
          const SizedBox(width: 10),
          Text('${fmtKg(entry.valueKg)} kg',
              style: AppText.display(16.8,
                  color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _EmptyWeightCard extends StatelessWidget {
  const _EmptyWeightCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            children: [
              const IcoChip(
                  icon: 'i-scale',
                  tone: IcoTone.violet,
                  size: 56),
              const SizedBox(height: 12),
              Text('Belum ada catatan',
                  style: AppText.display(20.8,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 6),
              Text('Catat timbangan pertamamu hari ini.',
                  textAlign: TextAlign.center,
                  style: AppText.body(14.08,
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAdd,
                  child: const Text('Catat berat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
