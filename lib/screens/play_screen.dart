import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/shop_item.dart';
import '../providers/game_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/sudoku_board.dart';
import 'home_screen.dart';
import 'result_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final game = context.read<GameProvider>();
    game.resumeClock();
    if (context.read<ShopProvider>().featureOn(ShopCatalog.featAwake)) {
      WakelockPlus.enable();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      game.tick();
      if (game.finished) {
        _timer?.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ResultScreen()));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.puzzle;
    if (puzzle == null) return const SizedBox.shrink();
    final diff = HomeScreen.label(context, puzzle.difficulty);
    final hints = context.select<ShopProvider, bool>((s) => s.featureOn(ShopCatalog.featHint));
    return FtrScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
                  Expanded(
                    child: Column(
                      children: [
                        Text(AppStrings.t(context, 'playTitle'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
                        Text('${AppStrings.t(context, 'statDifficulty')}: $diff', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: game.toggleNoteMode,
                    icon: Icon(Icons.grid_on_rounded, color: game.noteMode ? AppColors.primary : AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SudokuBoard(game: game),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Tool(icon: Icons.undo_rounded, label: AppStrings.t(context, 'undo'), onTap: game.undo),
                  _Tool(icon: Icons.backspace_outlined, label: AppStrings.t(context, 'erase'), onTap: game.erase),
                  _Tool(
                    icon: Icons.edit_outlined,
                    label: AppStrings.t(context, 'notes'),
                    active: game.noteMode,
                    onTap: game.toggleNoteMode,
                  ),
                  if (hints)
                    _Tool(
                      icon: Icons.lightbulb_outline_rounded,
                      label: '${AppStrings.t(context, 'hint')} ${game.hintsLeft}',
                      active: game.hintsLeft > 0,
                      onTap: game.useHint,
                    ),
                ],
              ),
              const Spacer(),
              for (final row in [1, 6])
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      for (var n = row; n < row + 5 && n <= 9; n++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _Key(n: n, onTap: () => game.input(n)),
                          ),
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

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _Tool({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final int n;
  final VoidCallback onTap;
  const _Key({required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 52,
          child: Center(child: Text('$n', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary))),
        ),
      ),
    );
  }
}
