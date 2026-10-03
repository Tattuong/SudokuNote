import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/navigation/app_navigator.dart';
import '../core/sudoku/sudoku_engine.dart';
import '../providers/game_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/coin_balance_chip.dart';
import 'play_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    return FtrScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'appName'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      Text(AppStrings.t(context, 'appTagline'), style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const CoinBalanceChip(variant: CoinChipVariant.header),
                const IconButton(onPressed: AppTabs.goSettings, icon: Icon(Icons.settings_outlined, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 22),
            Text(AppStrings.t(context, 'chooseDifficulty'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 4),
            Text(AppStrings.t(context, 'chooseDifficultyHint'), style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            if (game.hasSavedGame)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DifficultyCard(
                  icon: Icons.play_arrow_rounded,
                  title: AppStrings.t(context, 'continueGame'),
                    subtitle: label(context, game.puzzle!.difficulty),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayScreen())),
                ),
              ),
            for (final d in SudokuDifficulty.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DifficultyCard(
                  icon: Icons.grid_view_rounded,
                  title: label(context, d),
                  subtitle: _hint(context, d),
                  onTap: () async {
                    await context.read<GameProvider>().start(d);
                    if (!context.mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayScreen()));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String label(BuildContext context, SudokuDifficulty d) => AppStrings.t(context, switch (d) {
        SudokuDifficulty.easy => 'diffEasy',
        SudokuDifficulty.medium => 'diffMedium',
        SudokuDifficulty.hard => 'diffHard',
        SudokuDifficulty.expert => 'diffExpert',
      });

  static String _hint(BuildContext context, SudokuDifficulty d) => AppStrings.t(context, switch (d) {
        SudokuDifficulty.easy => 'diffEasyHint',
        SudokuDifficulty.medium => 'diffMediumHint',
        SudokuDifficulty.hard => 'diffHardHint',
        SudokuDifficulty.expert => 'diffExpertHint',
      });
}

class _DifficultyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _DifficultyCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFE8EEF8), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
