import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/settings_provider.dart';

class HistoricalStatsScreen extends StatelessWidget {
  const HistoricalStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = Provider.of<SettingsProvider>(context);

    const double spentThisMonth = 94.20;
    final double budgetPercent =
        (spentThisMonth / settings.monthlyBudgetCash).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('historicalData')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Monthly Budget Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('monthlyBudget'),
                          style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(budgetPercent * 100).toStringAsFixed(0)}% Used',
                          style: GoogleFonts.jetBrainsMono(
                            color: budgetPercent > 0.85
                                ? AppColors.amber
                                : AppColors.lime,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${spentThisMonth.toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Cap: \$${settings.monthlyBudgetCash.toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppColors.textDim,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: budgetPercent,
                        minHeight: 8,
                        backgroundColor: AppColors.bg2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budgetPercent > 0.85
                              ? AppColors.amber
                              : AppColors.lime,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Load Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('deviceBreakdown'),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _BreakdownBar(
                        label: 'HVAC & Climate',
                        percent: 0.42,
                        color: AppColors.lime,
                        kwh: '227.6 kWh'),
                    const SizedBox(height: 12),
                    const _BreakdownBar(
                        label: 'Industrial Motors',
                        percent: 0.24,
                        color: AppColors.cyan,
                        kwh: '130.0 kWh'),
                    const SizedBox(height: 12),
                    const _BreakdownBar(
                        label: 'Lighting Circuits',
                        percent: 0.18,
                        color: AppColors.amber,
                        kwh: '97.5 kWh'),
                    const SizedBox(height: 12),
                    const _BreakdownBar(
                        label: 'Server & IT Systems',
                        percent: 0.16,
                        color: AppColors.green,
                        kwh: '86.9 kWh'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Carbon Offset Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_rounded,
                          color: AppColors.green, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Carbon Offset',
                            style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '142.8 kg CO₂e Saved',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Equiv. to 6.2 mature trees planted',
                            style:
                                TextStyle(color: AppColors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final String kwh;

  const _BreakdownBar({
    required this.label,
    required this.percent,
    required this.color,
    required this.kwh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text(kwh,
                style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textDim, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: AppColors.bg2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
