import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api.themoviedb.org/3";
  //ganti dengan APIKey masing-masing
  static const String apiKey = "0c399a4ef7d694edce5e2294ea55075b";
  //1. mengambil list movie yang saat ini tayang
  Future<List<Map<String, dynamic>>> getAllMovies() async {
    final response = await http.get(
      Uri.parse("$baseUrl/movie/now_playing?api_key=$apiKey"),
    );
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  //2. mengambil list movie yang sedang trending minggu ini
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse("$baseUrl/trending/movie/week?api_key=$apiKey"),
    );
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  //3. mengambil list popular movie
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse("$baseUrl/movie/popular?api_key=$apiKey"),
    );
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  //4. mengambil list movie melalui pencarian
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/search/movie?query=$query&api_key=$apiKey"),
    );
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class DogApi {
  static const _base = 'https://dog.ceo/api';

  /// Mengambil satu URL gambar anjing acak.
  Future<String> fetchRandomImage() async {
    // note: `/random` returns a single image url; `/random/3` returns a
    // JSON array of strings, which would make `data['message']` a List.
    final urlString = '$_base/breeds/image/random';
    // debug logs to help track down bad URL values on web
    // (FormatException in screenshot indicated the string started with "GET ").
    print('[DogApi] fetching: "$urlString"');
    for (var i = 0; i < urlString.length; i++) {
      print('[DogApi] url[$i] = ${urlString.codeUnitAt(i)}');
    }

    final uri = Uri.parse(urlString);
    final res = await http.get(uri);
    print('[DogApi] response ${res.statusCode} body=${res.body}');

    final data = json.decode(res.body) as Map<String, dynamic>;
    final message = data['message'] as String;
    print('[DogApi] message="$message"');
    return message;
  }
}
