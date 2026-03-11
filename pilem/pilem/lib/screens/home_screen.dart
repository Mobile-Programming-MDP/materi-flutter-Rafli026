import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_services.dart';
import 'package:pilem/services/favorite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final FavoriteService _favoriteService = FavoriteService();

  List<Movie> _allMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];

  Future<void> _loadMovies() async {
    final List<Map<String, dynamic>> allMoviesData = await _apiService
        .getAllMovies();
    final List<Map<String, dynamic>> trendingMoviesData = await _apiService
        .getTrendingMovies();
    final List<Map<String, dynamic>> popularMoviesData = await _apiService
        .getPopularMovies();

    setState(() {
      _allMovies = allMoviesData.map((json) => Movie.fromJson(json)).toList();
      _trendingMovies = trendingMoviesData
          .map((json) => Movie.fromJson(json))
          .toList();
      _popularMovies = popularMoviesData
          .map((json) => Movie.fromJson(json))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _favoriteService.notifier.addListener(() => setState(() {}));
    _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilem")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoviesList("All Movies", _allMovies),
            _buildMoviesList("Trending Movies", _trendingMovies),
            _buildMoviesList("Popular Movies", _popularMovies),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesList(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menampilkan Title Kategori Movies
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        //Menapilkan thumnail dan judul movies
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (BuildContext build, int index) {
              final Movie movie = movies[index];
              final bool isFav = _favoriteService.favorites.any(
                (m) => m.id == movie.id,
              );
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(movie: movie),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () {
                                if (isFav) {
                                  _favoriteService.remove(movie);
                                } else {
                                  _favoriteService.add(movie);
                                }
                              },
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.title.length > 14
                            ? '${movie.title.substring(0, 10)}...'
                            : movie.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
