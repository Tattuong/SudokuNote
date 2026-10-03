import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/services/storage_service.dart';
import '../core/sudoku/puzzle_catalog.dart';
import '../core/sudoku/sudoku_engine.dart';
import '../models/shop_item.dart';
import 'shop_provider.dart';

class MoveSnapshot {
  final List<int> values;
  final List<Set<int>> notes;
  const MoveSnapshot(this.values, this.notes);
}

class GameProvider extends ChangeNotifier {
  static const _saveKey = 'sn_active_game';
  static const _historyKey = 'sn_history';
  static const _usedKey = 'sn_used_puzzles';

  final ShopProvider shop;
  final _random = Random();

  GameProvider(this.shop);

  SudokuPuzzle? puzzle;
  List<int> values = List.filled(81, 0);
  List<Set<int>> notes = List.generate(81, (_) => <int>{});
  int selected = -1;
  bool noteMode = false;
  bool finished = false;
  int mistakes = 0;
  int noteCount = 0;
  int hintsLeft = 3;
  Duration elapsed = Duration.zero;
  DateTime? _started;
  final List<MoveSnapshot> _undo = [];
  List<Map<String, dynamic>> history = [];

  bool get hasSavedGame => puzzle != null && !finished;

  int get filledCount => values.where((n) => n != 0).length;

  Future<void> init() async {
    history = await StorageService.instance.getDataList(_historyKey) ?? [];
    final raw = await StorageService.instance.getString(_saveKey);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final id = map['id'] as String;
    for (final p in PuzzleCatalog.all) {
      if (p.id == id) puzzle = p;
    }
    if (puzzle == null) return;
    values = (map['values'] as List).map((e) => e as int).toList();
    notes = (map['notes'] as List).map((e) => (e as List).map((n) => n as int).toSet()).toList();
    mistakes = map['mistakes'] as int? ?? 0;
    noteCount = map['noteCount'] as int? ?? 0;
    hintsLeft = map['hintsLeft'] as int? ?? 3;
    elapsed = Duration(milliseconds: map['elapsed'] as int? ?? 0);
    selected = map['selected'] as int? ?? -1;
    noteMode = map['noteMode'] as bool? ?? false;
  }

  Future<void> start(SudokuDifficulty difficulty) async {
    final used = (await StorageService.instance.getStringList(_usedKey))?.toSet() ?? {};
    final pool = PuzzleCatalog.of(difficulty);
    final fresh = pool.where((p) => !used.contains(p.id)).toList();
    final pick = (fresh.isEmpty ? pool : fresh)[_random.nextInt(fresh.isEmpty ? pool.length : fresh.length)];
    used.add(pick.id);
    if (used.length > pool.length) used.removeAll(pool.map((p) => p.id));
    await StorageService.instance.saveStringList(_usedKey, used.toList());
    puzzle = pick;
    values = List<int>.from(pick.givens);
    notes = List.generate(81, (_) => <int>{});
    selected = values.indexWhere((n) => n == 0);
    noteMode = false;
    finished = false;
    mistakes = 0;
    noteCount = 0;
    hintsLeft = 3;
    elapsed = Duration.zero;
    _started = DateTime.now();
    _undo.clear();
    await _persist();
    notifyListeners();
  }

  void resumeClock() => _started = DateTime.now();

  void tick() {
    if (finished || _started == null || puzzle == null) return;
    elapsed += DateTime.now().difference(_started!);
    _started = DateTime.now();
    notifyListeners();
  }

  void select(int index) {
    if (puzzle == null) return;
    selected = index;
    notifyListeners();
  }

  void toggleNoteMode() {
    noteMode = !noteMode;
    notifyListeners();
  }

  bool isGiven(int index) => puzzle != null && puzzle!.givens[index] != 0;

  void input(int number) {
    if (puzzle == null || finished || selected < 0 || isGiven(selected)) return;
    if (noteMode && values[selected] != 0) return;
    _pushUndo();
    _click();
    if (noteMode) {
      final cell = notes[selected];
      if (cell.contains(number)) {
        cell.remove(number);
      } else {
        cell.add(number);
        noteCount++;
      }
    } else {
      notes[selected] = {};
      if (number == puzzle!.solution[selected]) {
        values[selected] = number;
        _clearNotes(selected, number);
        if (SudokuEngine.isComplete(values)) {
          finished = true;
          tick();
          _finish();
        }
      } else {
        values[selected] = number;
        mistakes++;
      }
    }
    _persist();
    notifyListeners();
  }

  void useHint() {
    if (puzzle == null || finished || hintsLeft <= 0 || selected < 0 || isGiven(selected)) return;
    if (!shop.featureOn(ShopCatalog.featHint)) return;
    if (values[selected] == puzzle!.solution[selected]) return;
    _pushUndo();
    notes[selected] = {};
    values[selected] = puzzle!.solution[selected];
    hintsLeft--;
    _clearNotes(selected, values[selected]);
    if (SudokuEngine.isComplete(values)) {
      finished = true;
      tick();
      _finish();
    }
    _persist();
    notifyListeners();
  }

  void _click() {
    if (shop.featureOn(ShopCatalog.featSound)) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void erase() {
    if (puzzle == null || finished || selected < 0 || isGiven(selected)) return;
    if (values[selected] == 0 && notes[selected].isEmpty) return;
    _pushUndo();
    values[selected] = 0;
    notes[selected] = {};
    _persist();
    notifyListeners();
  }

  void undo() {
    if (_undo.isEmpty || finished) return;
    final snap = _undo.removeLast();
    values = snap.values;
    notes = snap.notes;
    _persist();
    notifyListeners();
  }

  void _pushUndo() {
    _undo.add(MoveSnapshot(List<int>.from(values), notes.map((n) => {...n}).toList()));
    if (_undo.length > 80) _undo.removeAt(0);
  }

  void _clearNotes(int index, int number) {
    final r = SudokuEngine.rowOf(index);
    final c = SudokuEngine.colOf(index);
    final b = SudokuEngine.boxOf(index);
    for (var i = 0; i < 81; i++) {
      if (SudokuEngine.rowOf(i) == r || SudokuEngine.colOf(i) == c || SudokuEngine.boxOf(i) == b) {
        notes[i].remove(number);
      }
    }
  }

  Future<void> _finish() async {
    history.insert(0, {
      'id': puzzle!.id,
      'difficulty': puzzle!.difficulty.name,
      'filled': 81,
      'notes': noteCount,
      'mistakes': mistakes,
      'ms': elapsed.inMilliseconds,
      'at': DateTime.now().toIso8601String(),
    });
    final cap = shop.maxArchive;
    if (history.length > cap) history = history.sublist(0, cap);
    await StorageService.instance.saveDataList(_historyKey, history);
    await StorageService.instance.remove(_saveKey);
    await shop.rewardForTestComplete();
  }

  Future<void> _persist() async {
    if (puzzle == null || finished) return;
    tick();
    await StorageService.instance.saveString(
      _saveKey,
      jsonEncode({
        'id': puzzle!.id,
        'values': values,
        'notes': notes.map((n) => n.toList()).toList(),
        'mistakes': mistakes,
        'noteCount': noteCount,
        'hintsLeft': hintsLeft,
        'elapsed': elapsed.inMilliseconds,
        'selected': selected,
        'noteMode': noteMode,
      }),
    );
  }

  String formatElapsed() {
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
