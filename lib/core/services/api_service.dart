import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movieapp/core/models/movie.dart';
import 'package:movieapp/utils/constants.dart';

class ApiService {
  // Esta función devolverá una 'Future<List<Movie>>'.
  // 'Future' significa que es una operación asíncrona (toma tiempo).
  Future<List<Movie>> getPopularMovies() async {
    // Construimos la URL completa para la petición
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.popularMoviesEndpoint}?api_key=${ApiConstants.apiKey}',
    );

    // Hacemos la petición GET y esperamos ('await') la respuesta
    final response = await http.get(url);

    // Verificamos si la respuesta fue exitosa (código 200)
    if (response.statusCode == 200) {
      // Decodificamos la respuesta JSON
      final data = json.decode(response.body);
      // Extraemos la lista de resultados
      final List results = data['results'];
      // Mapeamos la lista de JSON a una lista de objetos Movie
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      print('Error en la petición. Código: ${response.statusCode}');
      print('Razón: ${response.reasonPhrase}');
      print('Respuesta del servidor: ${response.body}');
      // Si algo salió mal, lanzamos un error
      throw Exception('Fallo al cargar las películas');
    }
  }


  Future<String> login(String email, String password) async {
    final url = Uri.parse('https://reqres.in/api/login');

    final body = json.encode({'email': email, 'password': password});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // La cabecera que descubrimos que era necesaria
        'x-api-key': 'reqres-free-v1',
      },
      body: body,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      // Si el login es exitoso, devolvemos el token.
      return data['token'];
    } else {
      // Si falla, lanzamos una excepción con el mensaje de error de la API.
      throw Exception(data['error'] ?? 'Ocurrió un error desconocido');
    }
  }
}
