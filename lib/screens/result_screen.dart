import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/game_provider.dart';
import '../widgets/app_scaffold.dart';
import 'home_screen.dart';
import 'play_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.puzzle;
    if (puzzle == null) return const SizedBox.shrink();
    final diff = HomeScreen.label(context, puzzle.difficulty);
    return FtrScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.emoji_events_rounded, size: 92, color: AppColors.primaryLight),
              const SizedBox(height: 12),
              Text(AppStrings.t(context, 'doneTitle'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(AppStrings.t(context, 'doneBody'), style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    _Row(Icons.grid_view_rounded, AppStrings.t(context, 'statDifficulty'), diff),
                    _Row(Icons.check_circle_outline, AppStrings.t(context, 'statFilled'), '${game.filledCount} / 81'),
                    _Row(Icons.edit_outlined, AppStrings.t(context, 'statNotes'), '${game.noteCount}'),
                    _Row(Icons.star_rounded, AppStrings.t(context, 'statResult'), AppStrings.t(context, 'resultGreat')),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await context.read<GameProvider>().start(puzzle.difficulty);
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PlayScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.t(context, 'nextGame')),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: Color(0xFFE3EAF3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(AppStrings.t(context, 'otherDifficulty')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
        ],
      ),
    );
  }
}
