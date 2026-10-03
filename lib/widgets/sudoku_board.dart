import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/sudoku/sudoku_engine.dart';
import '../providers/game_provider.dart';
import '../providers/shop_provider.dart';

class SudokuBoard extends StatelessWidget {
  final GameProvider game;
  const SudokuBoard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
            itemCount: 81,
            itemBuilder: (context, i) => _Cell(game: game, index: i),
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final GameProvider game;
  final int index;
  const _Cell({required this.game, required this.index});

  @override
  Widget build(BuildContext context) {
    final selected = game.selected;
    final sameUnit = selected >= 0 &&
        (SudokuEngine.rowOf(selected) == SudokuEngine.rowOf(index) ||
            SudokuEngine.colOf(selected) == SudokuEngine.colOf(index) ||
            SudokuEngine.boxOf(selected) == SudokuEngine.boxOf(index));
    final value = game.values[index];
    final selectedValue = selected >= 0 ? game.values[selected] : 0;
    final sameNumber = value != 0 && value == selectedValue;
    final given = game.isGiven(index);
    final wrong = value != 0 && game.puzzle != null && value != game.puzzle!.solution[index];
    final skin = context.select<ShopProvider, String>((s) => s.activeSkinId);
    final r = SudokuEngine.rowOf(index);
    final c = SudokuEngine.colOf(index);
    Color bg = Colors.white;
    if (index == selected) {
      bg = skin == 'skin_sharp' ? const Color(0xFFC5D4FF) : const Color(0xFFD9E6FF);
    } else if (sameNumber) {
      bg = const Color(0xFFE7EEFF);
    } else if (sameUnit) {
      bg = skin == 'skin_soft' ? const Color(0xFFF7F9FF) : const Color(0xFFF3F7FF);
    }
    final selectedBorder = index == selected && skin == 'skin_sharp';
    return GestureDetector(
      onTap: () => game.select(index),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          boxShadow: index == selected && skin == 'skin_glow'
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 8)]
              : null,
          border: Border(
            right: BorderSide(
              color: selectedBorder || c % 3 == 2 ? AppColors.ink : const Color(0xFFD5DDEB),
              width: selectedBorder ? 2 : (c % 3 == 2 ? 1.6 : 0.6),
            ),
            bottom: BorderSide(
              color: selectedBorder || r % 3 == 2 ? AppColors.ink : const Color(0xFFD5DDEB),
              width: selectedBorder ? 2 : (r % 3 == 2 ? 1.6 : 0.6),
            ),
          ),
        ),
        child: Center(child: value == 0 ? _Notes(notes: game.notes[index]) : Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: given ? FontWeight.w800 : FontWeight.w600,
            color: wrong ? AppColors.error : (given ? AppColors.ink : AppColors.primary),
          ),
        )),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  final Set<int> notes;
  const _Notes({required this.notes});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var n = 1; n <= 9; n++)
          Center(
            child: Text(
              notes.contains(n) ? '$n' : '',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.primaryLight, height: 1),
            ),
          ),
      ],
    );
  }
}
