import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
// ganti dengan APIKEY kamu
static const String apiKey = '0c399a4ef7d694edce5e2294ea55075b';
//1.Menggambil list movie yang saat ini sedang tayang di bioskop
  Future<List<Map<String, dynamic>>> getAllMovies() 
  async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey'),
    );
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }
  // 2.mengambil list movie yang sedang trending minggu ini
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
    );
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }
 
//  3. Mengambil list populer movie
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
    );
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 4. Mengambil list movie melalui pencarian
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data
    ['results']);
  }
}