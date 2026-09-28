import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../core/hive_fast.dart';

/// Set id menu favorit — box Hive `favorites`, satu kunci `ids`.
final favoritesProvider =
    NotifierProvider<FavoritesController, Set<String>>(
        FavoritesController.new);

class FavoritesController extends Notifier<Set<String>> {
  Box get _box => Hive.box('favorites');

  @override
  Set<String> build() {
    final raw = _box.get('ids');
    return Set<String>.from(raw is List ? raw : const <String>[]);
  }

  bool isFav(String id) => state.contains(id);

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (!next.remove(id)) next.add(id);
    state = next;
    detachHive(_box.put('ids', next.toList()), 'favorites/toggle');
  }
}
