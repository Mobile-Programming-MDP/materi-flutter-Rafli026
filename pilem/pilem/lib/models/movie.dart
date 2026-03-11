class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: json['vote_average'].toDouble() ?? 0.0,
    );
  }
}

import 'package:flutter/material.dart';
import 'services/dog_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog API Demo',
      theme: ThemeData(useMaterial3: true),
      home: const DogHome(),
    );
  }
}

class DogHome extends StatefulWidget {
  const DogHome({super.key});
  @override
  State<DogHome> createState() => _DogHomeState();
}

class _DogHomeState extends State<DogHome> {
  final DogApi _api = DogApi();
  String? _imageUrl;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final url = await _api.fetchRandomImage();
      setState(() {
        _imageUrl = url;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog API Demo')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
            ? Text('Error: $_error')
            : (_imageUrl != null
                  ? Image.network(_imageUrl!)
                  : const Text('No image')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetch,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
