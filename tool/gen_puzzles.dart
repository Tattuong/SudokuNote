import 'dart:math';

import 'package:sudokunote/core/sudoku/sudoku_engine.dart';

void main() {
  final random = Random(288);
  for (final d in SudokuDifficulty.values) {
    var made = 0;
    while (made < 3) {
      final p = SudokuEngine.generate(d, random, attempts: 8);
      if (p == null) {
        stderr('miss ${d.name}');
        continue;
      }
      print('${d.name}|${SudokuEngine.encode(p.givens)}|${SudokuEngine.encode(p.solution)}');
      made++;
    }
  }
}

void stderr(String s) => print('// $s');
