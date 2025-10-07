import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movieapp/core/models/movie.dart';
import 'package:movieapp/utils/constants.dart';

class ApiService {
  Future<String> login(String email, String password) async {
    final url = Uri.parse('https://reqres.in/api/login');
    
    final body = json.encode({
      'email': email,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': 'reqres-free-v1'
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return data['token'];
    } else {
      throw Exception(data['error'] ?? 'Ocurrió un error desconocido');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.popularMoviesEndpoint}?api_key=${ApiConstants.apiKey}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Fallo al cargar las películas');
    }
  }

  // --- NUEVO: FUNCIÓN PARA BUSCAR PELÍCULAS ---
  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.searchMoviesEndpoint}?api_key=${ApiConstants.apiKey}&query=$query');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Fallo al buscar películas');
    }
  }
}
