import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../models/weight_entry.dart';
import '../../widgets/svg_icon.dart';
import '../profile/prefs_store.dart';
import 'weight_repository.dart';
import 'weight_sheet.dart';

/// Layar Berat — frame 07 mockup: angka, BMI, grafik 7/30, riwayat.
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
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final history = ref.watch(weightHistoryProvider);
    final latest = ref.watch(latestWeightProvider);
    final prefs = ref.watch(prefsProvider);
    final bmi = prefs.bmi(latest?.valueKg);

    final cutoff =
        DateTime.now().subtract(Duration(days: _days - 1));
    final points = history
        .where((e) => e.date.compareTo(dateKeyOf(cutoff)) >= 0)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Berat badan',
                  style: AppText.display(22, color: text)),
              const SizedBox(height: 12),
              if (latest == null)
                _EmptyWeightCard(
                    onAdd: () => showWeightSheet(context))
              else ...[
                Center(
                  child: Column(
                    children: [
                      Text('${fmtKg(latest.valueKg)} kg',
                          style: AppText.display(44, color: text)),
                      Text(
                        'Terakhir ${_fmtDate(latest.date)}',
                        style: AppText.body(12.5, color: muted),
                      ),
                    ],
                  ),
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
                    onPressed: () {},
                    child:
                        const Text('Isi tinggi badan untuk lihat BMI'),
                  ),
                const SizedBox(height: 16),
                // Segmen 7/30.
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
                            style: AppText.body(12.5, color: muted),
                          ),
                        )
                      : LineChart(_chartData(points, theme)),
                ),
                const SizedBox(height: 16),
                Text('Riwayat',
                    style: AppText.display(17, color: text)),
                const SizedBox(height: 8),
                for (var i = 0; i < history.length; i++)
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => showWeightSheet(context),
        child: SvgIcon('i-plus', size: 24, color: Colors.white),
      ),
    );
  }

  LineChartData _chartData(
      List<WeightEntry> points, ThemeData theme) {
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
    final pad = ((maxY - minY).abs() < 0.5)
        ? 1.0
        : (maxY - minY) * 0.3;
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
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.15),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onPick(i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == index
                        ? theme.colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: i == index
                        ? [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    options[i],
                    textAlign: TextAlign.center,
                    style: AppText.body(13,
                        color: i == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        weight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
    // Posisi marker 15–35 → persen 0–100.
    final pos = ((bmi - 15) / 20).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon('i-height',
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('BMI — INDEKS MASSA TUBUH',
                  style: AppText.body(11,
                      color: theme.colorScheme.onSurfaceVariant,
                      weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(bmi.toStringAsFixed(1).replaceAll('.', ','),
                  style: AppText.display(30,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  bmi < 18.5
                      ? 'Kurus'
                      : bmi < 25
                          ? 'Normal'
                          : bmi < 30
                              ? 'Berlebih'
                              : 'Obesitas',
                  style: AppText.body(12,
                      color: theme.colorScheme.onPrimaryContainer,
                      weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BmiBar(pos: pos),
          const SizedBox(height: 6),
          Text(
            'Kurus <18,5 · Normal 18,5–24,9 · Berlebih 25–29,9 · Obesitas ≥30',
            style: AppText.body(10.5,
                color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(
            '${fmtKg(weightKg)} kg ÷ ${(heightCm / 100).toStringAsFixed(2).replaceAll('.', ',')} m²',
            style: AppText.body(10.5,
                color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BmiBar extends StatelessWidget {
  const _BmiBar({required this.pos});

  final double pos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                    scheme.primary,
                    const Color(0xFFFFD64A),
                    scheme.error,
                  ],
                  stops: const [0.0, 0.45, 0.7, 1.0],
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
                  color: scheme.surface,
                  border: Border.all(
                      color: scheme.onSurface, width: 3),
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
    final diff =
        prev == null ? null : entry.valueKg - prev!.valueKg;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(_fmtDate(entry.date),
                style: AppText.body(13.5,
                    color: theme.colorScheme.onSurface,
                    weight: FontWeight.w600)),
          ),
          if (diff != null && diff.abs() >= 0.05)
            Text(
              diff < 0
                  ? '▼ ${fmtKg(-diff)}'
                  : '▲ ${fmtKg(diff)}',
              style: AppText.body(12,
                  color: diff < 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  weight: FontWeight.w700),
            ),
          const SizedBox(width: 10),
          Text('${fmtKg(entry.valueKg)} kg',
              style: AppText.display(16,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(width: 4),
          Text('kg', style: AppText.body(11, color: muted)),
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          SvgIcon('i-scale',
              size: 44, color: theme.colorScheme.primary),
          const SizedBox(height: 10),
          Text('Belum ada catatan',
              style: AppText.body(15,
                  color: theme.colorScheme.onSurface,
                  weight: FontWeight.w800)),
          Text('Catat timbangan pertamamu hari ini.',
              style: AppText.body(12.5,
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAdd,
            child: const Text('Catat berat'),
          ),
        ],
      ),
    );
  }
}
