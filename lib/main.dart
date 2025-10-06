import 'package:flutter/material.dart';
import 'package:movieapp/core/providers/movie_provider.dart';
import 'package:movieapp/ui/screens/login_screen.dart';
import 'package:provider/provider.dart'; // Importa Provider

void main() {
  runApp(const AppState());
}

// Creamos un nuevo widget para gestionar el estado de la app
class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiProvider por si en el futuro queremos añadir más providers
    return MultiProvider(
      providers: [
        // Aquí "proveemos" nuestro MovieProvider
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: const MyApp(),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieApp',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}