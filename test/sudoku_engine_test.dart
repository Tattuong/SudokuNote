import 'package:flutter_test/flutter_test.dart';
import 'package:sudokunote/core/sudoku/puzzle_catalog.dart';
import 'package:sudokunote/core/sudoku/sudoku_engine.dart';

void main() {
  test('every catalog puzzle has one solution and the rated difficulty', () {
    expect(PuzzleCatalog.all, isNotEmpty);
    for (final puzzle in PuzzleCatalog.all) {
      expect(SudokuEngine.countSolutions(puzzle.givens), 1);
      expect(SudokuEngine.solve(puzzle.givens), puzzle.solution);
      expect(SudokuEngine.rate(puzzle.givens), puzzle.difficulty);
      expect(SudokuEngine.isComplete(List<int>.from(puzzle.solution)), isTrue);
    }
    expect(PuzzleCatalog.of(SudokuDifficulty.easy), isNotEmpty);
    expect(PuzzleCatalog.of(SudokuDifficulty.medium), isNotEmpty);
    expect(PuzzleCatalog.of(SudokuDifficulty.hard), isNotEmpty);
    expect(PuzzleCatalog.of(SudokuDifficulty.expert), isNotEmpty);
  });
}
