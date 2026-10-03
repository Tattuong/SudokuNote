import 'dart:math';

enum SudokuDifficulty { easy, medium, hard, expert }

class SudokuPuzzle {
  final String id;
  final SudokuDifficulty difficulty;
  final List<int> givens;
  final List<int> solution;

  const SudokuPuzzle({
    required this.id,
    required this.difficulty,
    required this.givens,
    required this.solution,
  });
}

class SudokuEngine {
  static const size = 81;

  static int rowOf(int i) => i ~/ 9;
  static int colOf(int i) => i % 9;
  static int boxOf(int i) => (rowOf(i) ~/ 3) * 3 + colOf(i) ~/ 3;

  static List<int> parse(String s) {
    final out = List<int>.filled(size, 0);
    for (var i = 0; i < size && i < s.length; i++) {
      final c = s.codeUnitAt(i);
      if (c >= 49 && c <= 57) out[i] = c - 48;
    }
    return out;
  }

  static String encode(List<int> grid) => grid.map((n) => n == 0 ? '.' : '$n').join();

  static bool isValidPlacement(List<int> grid, int index, int value) {
    final r = rowOf(index);
    final c = colOf(index);
    final b = boxOf(index);
    for (var i = 0; i < size; i++) {
      if (i == index || grid[i] != value) continue;
      if (rowOf(i) == r || colOf(i) == c || boxOf(i) == b) return false;
    }
    return true;
  }

  static bool isComplete(List<int> grid) {
    if (grid.any((n) => n == 0)) return false;
    for (var i = 0; i < size; i++) {
      final v = grid[i];
      grid[i] = 0;
      final ok = isValidPlacement(grid, i, v);
      grid[i] = v;
      if (!ok) return false;
    }
    return true;
  }

  /// Counts solutions up to [limit]. Returns 0, 1, or [limit] when more exist.
  static int countSolutions(List<int> grid, {int limit = 2}) {
    final copy = List<int>.from(grid);
    var found = 0;
    bool search() {
      final i = _bestEmpty(copy);
      if (i < 0) {
        found++;
        return found >= limit;
      }
      for (var n = 1; n <= 9; n++) {
        if (!isValidPlacement(copy, i, n)) continue;
        copy[i] = n;
        if (search()) return true;
        copy[i] = 0;
      }
      return false;
    }

    search();
    return found;
  }

  static List<int>? solve(List<int> grid) {
    final copy = List<int>.from(grid);
    bool search() {
      final i = _bestEmpty(copy);
      if (i < 0) return true;
      for (var n = 1; n <= 9; n++) {
        if (!isValidPlacement(copy, i, n)) continue;
        copy[i] = n;
        if (search()) return true;
        copy[i] = 0;
      }
      return false;
    }

    return search() ? copy : null;
  }

  static int _bestEmpty(List<int> grid) {
    var best = -1;
    var bestCount = 10;
    for (var i = 0; i < size; i++) {
      if (grid[i] != 0) continue;
      var count = 0;
      for (var n = 1; n <= 9; n++) {
        if (isValidPlacement(grid, i, n)) count++;
      }
      if (count < bestCount) {
        bestCount = count;
        best = i;
        if (count <= 1) break;
      }
    }
    return best;
  }

  /// Naked singles, then hidden singles. Returns filled grid or null if stuck.
  static List<int>? solveBySingles(List<int> grid, {bool hidden = true}) {
    final copy = List<int>.from(grid);
    var changed = true;
    while (changed) {
      if (copy.every((n) => n != 0)) return copy;
      changed = false;
      for (var i = 0; i < size; i++) {
        if (copy[i] != 0) continue;
        final opts = [for (var n = 1; n <= 9; n++) if (isValidPlacement(copy, i, n)) n];
        if (opts.length == 1) {
          copy[i] = opts.first;
          changed = true;
        }
      }
      if (changed || !hidden) continue;
      for (var unit = 0; unit < 27; unit++) {
        final cells = _unit(unit);
        for (var n = 1; n <= 9; n++) {
          if (cells.any((i) => copy[i] == n)) continue;
          final spots = cells.where((i) => copy[i] == 0 && isValidPlacement(copy, i, n)).toList();
          if (spots.length == 1) {
            copy[spots.first] = n;
            changed = true;
          }
        }
      }
    }
    return copy.every((n) => n != 0) ? copy : null;
  }

  static List<int> _unit(int unit) {
    if (unit < 9) return [for (var c = 0; c < 9; c++) unit * 9 + c];
    if (unit < 18) {
      final col = unit - 9;
      return [for (var r = 0; r < 9; r++) r * 9 + col];
    }
    final box = unit - 18;
    final br = (box ~/ 3) * 3;
    final bc = (box % 3) * 3;
    return [for (var r = 0; r < 3; r++) for (var c = 0; c < 3; c++) (br + r) * 9 + bc + c];
  }

  static SudokuDifficulty? rate(List<int> givens) {
    if (countSolutions(givens) != 1) return null;
    if (solveBySingles(givens, hidden: false) != null) return SudokuDifficulty.easy;
    if (solveBySingles(givens, hidden: true) != null) return SudokuDifficulty.medium;
    final clues = givens.where((n) => n != 0).length;
    return clues >= 28 ? SudokuDifficulty.hard : SudokuDifficulty.expert;
  }

  static SudokuPuzzle? generate(SudokuDifficulty difficulty, Random random, {int attempts = 40}) {
    final (minClues, maxClues) = switch (difficulty) {
      SudokuDifficulty.easy => (40, 46),
      SudokuDifficulty.medium => (32, 36),
      SudokuDifficulty.hard => (28, 31),
      SudokuDifficulty.expert => (24, 27),
    };
    for (var attempt = 0; attempt < attempts; attempt++) {
      final solved = _filled(random);
      final puzzle = List<int>.from(solved);
      final order = List<int>.generate(size, (i) => i)..shuffle(random);
      var clues = size;
      for (final i in order) {
        if (clues <= minClues) break;
        final saved = puzzle[i];
        puzzle[i] = 0;
        clues--;
        if (countSolutions(puzzle) != 1) {
          puzzle[i] = saved;
          clues++;
        }
      }
      if (clues < minClues || clues > maxClues) continue;
      final rated = rate(puzzle);
      if (rated != difficulty) continue;
      return SudokuPuzzle(
        id: '${difficulty.name}-${random.nextInt(1 << 30)}',
        difficulty: difficulty,
        givens: List<int>.from(puzzle),
        solution: solved,
      );
    }
    return null;
  }

  static List<int> _filled(Random random) {
    final grid = List<int>.filled(size, 0);
    for (var box = 0; box < 3; box++) {
      final nums = List<int>.generate(9, (i) => i + 1)..shuffle(random);
      var k = 0;
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          grid[(box * 3 + r) * 9 + box * 3 + c] = nums[k++];
        }
      }
    }
    final solved = solve(grid);
    if (solved == null) return _filled(random);
    return solved;
  }
}
