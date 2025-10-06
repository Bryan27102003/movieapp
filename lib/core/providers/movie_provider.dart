import 'package:flutter/material.dart';
import 'package:movieapp/core/models/movie.dart';
import 'package:movieapp/core/services/api_service.dart';

// La clase extiende ChangeNotifier. Esto le da la habilidad de notificar
// a sus "oyentes" (la UI) cuando algo cambia.
class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Hacemos las variables privadas y exponemos getters públicos
  // para proteger el estado.
  bool _isLoading = false;
  List<Movie> _popularMovies = [];

  bool get isLoading => _isLoading;
  List<Movie> get popularMovies => _popularMovies;

  // Esta es la función que nuestra UI llamará para obtener los datos.
  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    notifyListeners(); // Notifica a la UI que estamos cargando.

    try {
      _popularMovies = await _apiService.getPopularMovies();
    } catch (e) {
      // Aquí podríamos manejar el error de forma más elegante
      print(e);
    }

    _isLoading = false;
    notifyListeners(); // Notifica que terminamos de cargar y que hay nuevos datos.
  }
}