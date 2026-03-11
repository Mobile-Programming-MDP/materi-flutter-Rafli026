import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class FavoriteService {
  FavoriteService._internal() {
    _loadFromPrefs();
  }

  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;

  static const String _prefsKey = 'favorites';

  final ValueNotifier<List<Movie>> notifier = ValueNotifier<List<Movie>>([]);

  List<Movie> get favorites => notifier.value;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_prefsKey);
    if (stored != null) {
      notifier.value = stored
          .map((s) => Movie.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = notifier.value
        .map(
          (m) => jsonEncode({
            'id': m.id,
            'title': m.title,
            'overview': m.overview,
            'poster_path': m.posterPath,
            'backdrop_path': m.backdropPath,
            'release_date': m.releaseDate,
            'vote_average': m.voteAverage,
          }),
        )
        .toList();
    await prefs.setStringList(_prefsKey, encoded);
  }

  Future<void> add(Movie movie) async {
    if (!favorites.any((m) => m.id == movie.id)) {
      notifier.value = [...favorites, movie];
      await _saveToPrefs();
    }
  }

  Future<void> remove(Movie movie) async {
    notifier.value = favorites.where((m) => m.id != movie.id).toList();
    await _saveToPrefs();
  }

  Future<bool> isFavorite(int id) async {
    return favorites.any((m) => m.id == id);
  }
}
