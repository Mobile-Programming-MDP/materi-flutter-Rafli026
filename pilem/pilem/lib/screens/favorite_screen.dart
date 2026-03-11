import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _favoriteService = FavoriteService();
    _favoriteService.notifier.addListener(_onChange);
  }

  @override
  void dispose() {
    _favoriteService.notifier.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Movie> favs = _favoriteService.favorites;
    if (favs.isEmpty) {
      return const Center(
        child: Text('No favorite movies yet.', style: TextStyle(fontSize: 18)),
      );
    }
    return ListView.builder(
      itemCount: favs.length,
      itemBuilder: (context, index) {
        final movie = favs[index];
        return ListTile(
          leading: Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
          title: Text(movie.title),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _favoriteService.remove(movie),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(movie: movie),
              ),
            );
          },
        );
      },
    );
  }
}
