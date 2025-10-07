import 'dart:async'; // <-- Importante para el debounce
import 'package:flutter/material.dart';
import 'package:movieapp/core/models/movie.dart';
import 'package:movieapp/core/services/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  List<Movie> _popularMovies = [];
  
  // --- NUEVO: ESTADO PARA LA BÚSQUEDA ---
  List<Movie> _searchedMovies = [];
  bool _isSearching = false;
  Timer? _debounce;

  // --- Getters ---
  bool get isLoading => _isLoading;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchedMovies => _searchedMovies;
  bool get isSearching => _isSearching;

  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _popularMovies = await _apiService.getPopularMovies();
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- NUEVO: LÓGICA DE BÚSQUEDA CON DEBOUNCE ---
  void onSearchChanged(String query) {
    // Si ya hay un timer, lo cancelamos para reiniciarlo
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Creamos un nuevo timer que esperará 500ms antes de buscar
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        // Si el buscador está vacío, limpiamos la búsqueda
        clearSearch();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    _isLoading = true;
    _isSearching = true;
    // Notificamos antes de la llamada para mostrar el loader
    notifyListeners(); 

    try {
      _searchedMovies = await _apiService.searchMovies(query);
    } catch (e) {
      print(e);
      _searchedMovies = []; // Limpiamos en caso de error
    }

    _isLoading = false;
    // Notificamos de nuevo con los resultados (o la lista vacía)
    notifyListeners();
  }

  void clearSearch() {
    _searchedMovies = [];
    _isSearching = false;
    notifyListeners();
  }
}
