import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/services/favorite_service.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  late final FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _favoriteService = FavoriteService();
    _isFavorite = _favoriteService.favorites.any(
      (m) => m.id == widget.movie.id,
    );
    // listen for external changes (in case user toggled from another screen)
    _favoriteService.notifier.addListener(_updateFavoriteState);
  }

  @override
  void dispose() {
    _favoriteService.notifier.removeListener(_updateFavoriteState);
    super.dispose();
  }

  void _updateFavoriteState() {
    final currentlyFav = _favoriteService.favorites.any(
      (m) => m.id == widget.movie.id,
    );
    if (currentlyFav != _isFavorite) {
      setState(() {
        _isFavorite = currentlyFav;
      });
    }
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.remove(widget.movie);
    } else {
      await _favoriteService.add(widget.movie);
    }
    // favorite service will notify listeners and update state
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'Overview:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(movie.overview),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Text(
                    'Release Date:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(movie.releaseDate),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 10),
                  const Text(
                    'Rating:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(movie.voteAverage.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
