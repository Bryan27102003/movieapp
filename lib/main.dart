import 'package:flutter/material.dart';
import 'package:movieapp/core/providers/movie_provider.dart';
import 'package:movieapp/ui/screens/login_screen.dart';
import 'package:movieapp/ui/theme/app_theme.dart'; // <-- IMPORTAMOS NUESTRO TEMA
import 'package:provider/provider.dart';

void main() {
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      title: 'Cinépolis App',
      debugShowCheckedModeBanner: false,
      
      // --- APLICAMOS NUESTRO TEMA UNIVERSAL ---
      theme: AppTheme.lightTheme,       // Tema para el modo claro.
      darkTheme: AppTheme.darkTheme,     // Tema para el modo oscuro.
      themeMode: ThemeMode.system,     // ¡La magia! Se adapta al sistema.
      
      home: const LoginScreen(),
    );
  }
}
